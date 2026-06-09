import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Ed25519-based license key service.
///
/// Key format: "identifier:base64url_signature"
///   - identifier  : the name entered when generating (e.g. "alice")
///   - signature   : Ed25519 sig of UTF-8("feloosy:pro:lifetime:v1:identifier")
///
/// Private key lives only in flutter_secure_storage on the dev device.
/// Only the public key is embedded here for verification in prod builds.
///
/// To revoke a key: add its full string to [_blocklist] and publish an update.
class LicenseService {
  static const _storage = FlutterSecureStorage();
  static final _ed25519 = Ed25519();

  // ── FILL IN after first setup ─────────────────────────────────────────────
  // Open the dev app → Settings → Developer Tools → License Keys
  // Tap "Generate Keypair", copy the displayed bytes, paste them here,
  // then rebuild and redeploy both dev and prod.
  static const List<int> _publicKeyBytes = [];

  // ── Blocklist: add a key string here + publish update to revoke it ────────
  static const Set<String> _blocklist = {};

  /// Public read-only view of the blocklist for the admin screen display.
  static Set<String> get revokedKeys => _blocklist;

  static const _activatedKey  = 'feloosy_license_key';
  static const _privateKeyKey = 'feloosy_license_private';
  static const _publicKeyKey  = 'feloosy_license_public';
  static const _keyLogKey     = 'feloosy_license_log';
  static const _msgPrefix     = 'feloosy:pro:lifetime:v1:';

  // ── Verification (used by prod + dev) ─────────────────────────────────────

  /// Verifies "identifier:base64url_sig" against the embedded public key.
  /// Returns false when the public key is not yet configured.
  static Future<bool> verify(String key) async {
    final k = key.trim();
    if (_publicKeyBytes.isEmpty) return false;
    if (_blocklist.contains(k)) return false;
    try {
      final colon = k.indexOf(':');
      if (colon < 1) return false;
      final identifier = k.substring(0, colon);
      final sigB64     = k.substring(colon + 1);
      final sigBytes   = base64Url.decode(_pad(sigB64));
      final message    = utf8.encode('$_msgPrefix$identifier');
      final pubKey     = SimplePublicKey(_publicKeyBytes, type: KeyPairType.ed25519);
      return await _ed25519.verify(
        message,
        signature: Signature(sigBytes, publicKey: pubKey),
      );
    } catch (_) {
      return false;
    }
  }

  /// Verifies then persists the key. Returns true on success.
  static Future<bool> activate(String key) async {
    if (!await verify(key)) return false;
    await _storage.write(key: _activatedKey, value: key.trim());
    return true;
  }

  /// Re-verifies the stored key on every cold start.
  /// A manually written value that fails Ed25519 check returns false.
  static Future<bool> loadAndVerify() async {
    final stored = await _storage.read(key: _activatedKey);
    if (stored == null) return false;
    return verify(stored);
  }

  // ── Admin — dev device only ───────────────────────────────────────────────

  static Future<bool> hasPrivateKey() async {
    final v = await _storage.read(key: _privateKeyKey);
    return v != null && v.isNotEmpty;
  }

  /// Generates and stores an Ed25519 keypair.
  /// Returns the public key as a Dart list literal to paste into [_publicKeyBytes].
  static Future<String> setupKeypair() async {
    final pair = await _ed25519.newKeyPair();
    final priv = await pair.extractPrivateKeyBytes();
    final pub  = await pair.extractPublicKey();
    await _storage.write(key: _privateKeyKey, value: base64Url.encode(priv));
    await _storage.write(key: _publicKeyKey,  value: base64Url.encode(pub.bytes));
    return '[${pub.bytes.join(', ')}]';
  }

  /// Signs a new license key for [identifier] using the stored private key.
  /// Returns null if no private key has been set up yet.
  static Future<String?> generateKey(String identifier) async {
    final privB64 = await _storage.read(key: _privateKeyKey);
    final pubB64  = await _storage.read(key: _publicKeyKey);
    if (privB64 == null || pubB64 == null) return null;

    final priv   = base64Url.decode(_pad(privB64));
    final pub    = base64Url.decode(_pad(pubB64));
    final pubKey = SimplePublicKey(pub, type: KeyPairType.ed25519);
    final pair   = SimpleKeyPairData(priv, publicKey: pubKey, type: KeyPairType.ed25519);
    final msg    = utf8.encode('$_msgPrefix$identifier');
    final sig    = await _ed25519.sign(msg, keyPair: pair);
    return '$identifier:${base64Url.encode(sig.bytes)}';
  }

  /// Persists a generated key to the dev log (overwrites same identifier).
  static Future<void> logKey(String identifier, String key) async {
    final raw = await _storage.read(key: _keyLogKey);
    final log = raw != null ? (jsonDecode(raw) as List<dynamic>) : <dynamic>[];
    log.removeWhere((e) => (e as Map)['id'] == identifier);
    log.add({'id': identifier, 'key': key});
    await _storage.write(key: _keyLogKey, value: jsonEncode(log));
  }

  /// Returns all logged keys as [{id, key}] maps.
  static Future<List<Map<String, String>>> loadKeyLog() async {
    final raw = await _storage.read(key: _keyLogKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
  }

  static String _pad(String s) {
    final r = s.length % 4;
    return r == 0 ? s : '$s${'=' * (4 - r)}';
  }
}
