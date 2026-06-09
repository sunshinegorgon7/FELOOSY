import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/license_service.dart';

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              _publicKeyLiteral!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
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
        // Generator input
        Text('Generate Key',
            style: Theme.of(context).textTheme.titleMedium),
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

        // Key log
        if (_keyLog.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Generated Keys',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._keyLog.reversed.map((entry) => _KeyLogTile(
                identifier: entry['id']!,
                licenseKey: entry['key']!,
                onCopy: () =>
                    _copyToClipboard(entry['key']!, label: '"${entry['id']}"'),
              )),
        ],

        // Blocklist
        const SizedBox(height: 24),
        Text('Blocklist', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (LicenseService.revokedKeys.isEmpty)
          Text('Empty — add key strings in source to revoke access.',
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
      ],
    );
  }
}

class _KeyLogTile extends StatelessWidget {
  final String identifier;
  final String licenseKey;
  final VoidCallback onCopy;

  const _KeyLogTile({
    required this.identifier,
    required this.licenseKey,
    required this.onCopy,
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
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copy key',
          onPressed: onCopy,
        ),
      ),
    );
  }
}
