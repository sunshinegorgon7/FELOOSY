import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_info.dart';
import '../../services/license_service.dart';
import '../../services/remote_config_service.dart';

/// Dev-only screen for managing Ed25519 license keys.
/// Accessible from Settings → Developer Tools → License Keys.
class LicenseAdminScreen extends StatefulWidget {
  const LicenseAdminScreen({super.key});

  @override
  State<LicenseAdminScreen> createState() => _LicenseAdminScreenState();
}

class _LicenseAdminScreenState extends State<LicenseAdminScreen> {
  bool _loading = true;
  bool _hasKey = false;

  // Setup state
  bool _generating = false;
  String? _publicKeyLiteral;

  // Generator state
  final _idCtrl = TextEditingController();
  bool _signing = false;
  String? _idError;
  List<Map<String, String>> _keyLog = [];

  // Public key retrieval
  bool _loadingPubKey = false;
  String? _retrievedPublicKey;

  // Rotation state
  bool _rotating = false;
  ({String newPublicKeyLiteral, String oldPublicKeyLiteral})? _rotationResult;

  // Remote config test state
  bool _testingConfig = false;
  RemoteConfig? _configTestResult;
  String? _configTestError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final has = await LicenseService.hasPrivateKey();
    final log = has ? await LicenseService.loadKeyLog() : <Map<String, String>>[];
    if (mounted) setState(() { _hasKey = has; _keyLog = log; _loading = false; });
  }

  Future<void> _setupKeypair() async {
    setState(() => _generating = true);
    try {
      final literal = await LicenseService.setupKeypair();
      if (mounted) {
        setState(() {
          _publicKeyLiteral = literal;
          _hasKey = true;
          _generating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _generating = false);
        _snack('Setup failed: $e');
      }
    }
  }

  Future<void> _retrievePublicKey() async {
    setState(() { _loadingPubKey = true; _retrievedPublicKey = null; });
    try {
      final literal = await LicenseService.getPublicKeyLiteral();
      if (mounted) setState(() => _retrievedPublicKey = literal);
    } catch (e) {
      if (mounted) _snack('Failed to read public key: $e');
    } finally {
      if (mounted) setState(() => _loadingPubKey = false);
    }
  }

  Future<void> _generateKey() async {
    final id = _idCtrl.text.trim();
    if (id.isEmpty) {
      setState(() => _idError = 'Enter an identifier');
      return;
    }
    if (id.contains(':')) {
      setState(() => _idError = 'Identifier cannot contain ":"');
      return;
    }
    setState(() { _signing = true; _idError = null; });
    try {
      final key = await LicenseService.generateKey(id);
      if (key == null) {
        _snack('No private key found — run Setup first');
        return;
      }
      await LicenseService.logKey(id, key);
      final log = await LicenseService.loadKeyLog();
      if (mounted) {
        setState(() { _keyLog = log; _idCtrl.clear(); });
        _copyToClipboard(key, label: 'Key for "$id"');
      }
    } catch (e) {
      if (mounted) _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _signing = false);
    }
  }

  Future<void> _deleteKey(String identifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove from log?'),
        content: Text(
          'Remove "$identifier" from the key log?\n\nThe key itself remains valid — this only clears the local record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await LicenseService.deleteKey(identifier);
    final log = await LicenseService.loadKeyLog();
    if (mounted) setState(() => _keyLog = log);
  }

  Future<void> _rotateKeypair() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rotate keypair?'),
        content: const Text(
          'A new signing keypair will be generated. You must update _publicKeyBytes in source '
          'with the new key, and add the old public key to _legacyPublicKeyBytesList so existing '
          'keys continue to work.\n\n'
          'Keys signed by the old private key keep verifying until you remove the old public key '
          'from _legacyPublicKeyBytesList.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Rotate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() { _rotating = true; _rotationResult = null; });
    try {
      final result = await LicenseService.rotateKeypair();
      if (mounted) setState(() { _rotationResult = result; _rotating = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _rotating = false);
        _snack('Rotation failed: $e');
      }
    }
  }

  Future<void> _testRemoteConfig() async {
    setState(() { _testingConfig = true; _configTestResult = null; _configTestError = null; });
    try {
      final result = await RemoteConfigService.fetchForTesting();
      if (mounted) setState(() { _configTestResult = result; _testingConfig = false; });
    } catch (e) {
      if (mounted) setState(() { _testingConfig = false; _configTestError = e.toString(); });
    }
  }

  void _copyToClipboard(String text, {String? label}) {
    Clipboard.setData(ClipboardData(text: text));
    _snack(label != null ? '$label copied' : 'Copied to clipboard');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('License Keys')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _hasKey ? _generatorBody(cs) : _setupBody(cs),
            ),
    );
  }

  // ── Setup state ────────────────────────────────────────────────────────────

  Widget _setupBody(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.key_off_outlined, size: 56),
        const SizedBox(height: 16),
        Text('No keypair found.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Generate a keypair once. The private key stays on this device.\n'
          'After generating, copy the public key bytes into '
          'LicenseService._publicKeyBytes in source code, then rebuild.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: _generating ? null : _setupKeypair,
          child: _generating
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Generate Keypair'),
        ),
        if (_publicKeyLiteral != null) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text('Public key — paste into LicenseService._publicKeyBytes:',
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _monoBox(cs, _publicKeyLiteral!),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                _copyToClipboard(_publicKeyLiteral!, label: 'Public key bytes'),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy bytes'),
          ),
          const SizedBox(height: 8),
          Text(
            'After pasting and rebuilding, you can generate license keys below.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ],
    );
  }

  // ── Generator state ────────────────────────────────────────────────────────

  Widget _generatorBody(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Generate Key ──────────────────────────────────────────────────
        Text('Generate Key', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _idCtrl,
                decoration: InputDecoration(
                  labelText: 'Identifier (e.g. alice)',
                  errorText: _idError,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signing ? null : _generateKey(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _signing ? null : _generateKey,
                child: _signing
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Key is copied automatically. Same identifier always gives the same key.',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),

        // ── Public Key ────────────────────────────────────────────────────
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Text('Public Key', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Paste these bytes into LicenseService._publicKeyBytes in source, then rebuild.',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _loadingPubKey ? null : _retrievePublicKey,
          icon: _loadingPubKey
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.visibility_outlined, size: 18),
          label: const Text('Show Public Key Bytes'),
        ),
        if (_retrievedPublicKey != null) ...[
          const SizedBox(height: 10),
          _monoBox(cs, _retrievedPublicKey!),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _copyToClipboard(_retrievedPublicKey!, label: 'Public key bytes'),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy bytes'),
          ),
        ],

        // ── Rotate Keypair ────────────────────────────────────────────────
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Text('Rotate Keypair', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Generates a new signing keypair. Existing keys keep working as long as '
          'you add the old public key to _legacyPublicKeyBytesList in source before rebuilding.',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _rotating ? null : _rotateKeypair,
          style: OutlinedButton.styleFrom(foregroundColor: cs.error),
          icon: _rotating
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.error))
              : const Icon(Icons.refresh, size: 18),
          label: const Text('Rotate Keypair'),
        ),
        if (_rotationResult != null) ...[
          const SizedBox(height: 16),
          Text(
            '1  New public key → paste as _publicKeyBytes:',
            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 6),
          _monoBox(cs, _rotationResult!.newPublicKeyLiteral),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _copyToClipboard(_rotationResult!.newPublicKeyLiteral, label: 'New public key'),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy new key'),
          ),
          const SizedBox(height: 14),
          Text(
            '2  Old public key → add as entry in _legacyPublicKeyBytesList:',
            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 6),
          _monoBox(cs, _rotationResult!.oldPublicKeyLiteral),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _copyToClipboard(_rotationResult!.oldPublicKeyLiteral, label: 'Old public key'),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy old key'),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Paste both keys into source, then rebuild and publish. '
              'After publishing, raise min_build in your Gist to force users onto the new version.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4),
            ),
          ),
        ],

        // ── Generated Keys log ────────────────────────────────────────────
        if (_keyLog.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text('Generated Keys', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'To revoke a key remotely, add its identifier to revoked_identifiers in your Gist.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          ..._keyLog.reversed.map((entry) => _KeyLogTile(
                identifier: entry['id']!,
                licenseKey: entry['key']!,
                onCopy: () =>
                    _copyToClipboard(entry['key']!, label: '"${entry['id']}"'),
                onDelete: () => _deleteKey(entry['id']!),
              )),
        ],

        // ── Blocklist ─────────────────────────────────────────────────────
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Text('Source Blocklist', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (LicenseService.revokedKeys.isEmpty)
          Text('Empty — add full key strings in source to permanently revoke.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))
        else
          ...LicenseService.revokedKeys.map(
            (k) => ListTile(
              dense: true,
              leading: const Icon(Icons.block, size: 18),
              title: Text(k,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
          ),

        // ── Remote Config ─────────────────────────────────────────────────
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Text('Remote Config (Gist)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const _InfoRow(label: 'Build', value: '$kAppBuildNumber'),
        const SizedBox(height: 4),
        _InfoRow(
          label: 'URL',
          value: kRemoteConfigUrl.isEmpty ? '(not configured)' : kRemoteConfigUrl,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _testingConfig ? null : _testRemoteConfig,
          icon: _testingConfig
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.cloud_download_outlined, size: 18),
          label: const Text('Test Gist'),
        ),
        if (_configTestResult != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ConfigRow(label: 'min_build', value: '${_configTestResult!.minBuild}'),
                const SizedBox(height: 4),
                _ConfigRow(
                  label: 'revoked_identifiers',
                  value: _configTestResult!.revokedIdentifiers.isEmpty
                      ? 'none'
                      : _configTestResult!.revokedIdentifiers.join(', '),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _configTestResult!.isVersionBlocked
                          ? Icons.block
                          : Icons.check_circle_outline,
                      size: 16,
                      color: _configTestResult!.isVersionBlocked ? cs.error : cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Build $kAppBuildNumber — ${_configTestResult!.isVersionBlocked ? "BLOCKED" : "OK"}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _configTestResult!.isVersionBlocked ? cs.error : cs.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (_configTestError != null) ...[
          const SizedBox(height: 12),
          Text('Error: $_configTestError',
              style: TextStyle(color: cs.error, fontSize: 12)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _monoBox(ColorScheme cs, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _KeyLogTile extends StatelessWidget {
  final String identifier;
  final String licenseKey;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _KeyLogTile({
    required this.identifier,
    required this.licenseKey,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final short = licenseKey.length > 24
        ? '${licenseKey.substring(0, 24)}…'
        : licenseKey;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        title: Text(identifier, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(short,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy key',
              onPressed: onCopy,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
              tooltip: 'Remove from log',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Text('$label:', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfigRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
