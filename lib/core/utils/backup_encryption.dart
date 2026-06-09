import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-256-GCM encryption for backup files.
///
/// File format: [8 magic][1 version][12 nonce][16 MAC][ciphertext]
///
/// The key is app-level (hardcoded). This protects against casual file access;
/// a determined attacker who decompiles the app could extract the key, but the
/// file is completely opaque to anyone without the app binary.
///
/// Old plain-JSON backups are detected by the absence of the magic header and
/// handled transparently for backwards compatibility.
class BackupEncryption {
  static final _aesGcm = AesGcm.with256bits();

  // 32-byte AES-256 key — unique to this app, never changes.
  static final _key = SecretKey(const <int>[
    0x7A, 0x3F, 0xC2, 0x8E, 0x51, 0xB9, 0x0D, 0x4A,
    0xF6, 0x2C, 0x8B, 0xE3, 0x17, 0x5D, 0x99, 0xA0,
    0x6E, 0xC4, 0x3A, 0xF7, 0x82, 0x1B, 0xD5, 0x0C,
    0x48, 0x9F, 0x6B, 0xE2, 0x35, 0xA7, 0xC8, 0x53,
  ]);

  // ASCII for "FELOOSY!"
  static const _magic = <int>[0x46, 0x45, 0x4C, 0x4F, 0x4F, 0x53, 0x59, 0x21];

  // Byte offsets inside the header (after magic(8) + version(1)).
  static const _nonceOffset = 9;   // 12 bytes
  static const _macOffset   = 21;  // 16 bytes
  static const _dataOffset  = 37;  // ciphertext starts here

  /// True when [bytes] begins with the FELOOSY magic header.
  static bool isEncrypted(List<int> bytes) {
    if (bytes.length <= _dataOffset) return false;
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) return false;
    }
    return true;
  }

  /// Encrypts [plaintext] bytes.
  /// Returns: [magic(8)] [version(1)] [nonce(12)] [mac(16)] [ciphertext]
  static Future<Uint8List> encrypt(List<int> plaintext) async {
    final box = await _aesGcm.encrypt(plaintext, secretKey: _key);
    return Uint8List.fromList([
      ..._magic,
      0x01,               // version
      ...box.nonce,       // 12 bytes — random per call
      ...box.mac.bytes,   // 16 bytes — authentication tag
      ...box.cipherText,
    ]);
  }

  /// Decrypts a blob produced by [encrypt].
  /// Returns null when the magic header is absent (plain file) or decryption fails.
  static Future<List<int>?> decrypt(List<int> bytes) async {
    if (!isEncrypted(bytes)) return null;
    try {
      final nonce      = bytes.sublist(_nonceOffset, _macOffset);
      final mac        = bytes.sublist(_macOffset,   _dataOffset);
      final cipherText = bytes.sublist(_dataOffset);
      final box = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));
      return await _aesGcm.decrypt(box, secretKey: _key);
    } catch (_) {
      return null;
    }
  }
}
