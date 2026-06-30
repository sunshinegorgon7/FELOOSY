import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/license_service.dart';
import 'remote_config_provider.dart';

/// True when a valid Ed25519 license key is stored on this device
/// AND the identifier has not been remotely revoked via the Gist config.
/// Re-verified on every cold start — forged secure-storage values return false.
/// Fails open: if the remote config is unavailable the revocation list is empty.
final licenseProvider = FutureProvider<bool>((ref) async {
  final isValid = await LicenseService.loadAndVerify();
  if (!isValid) return false;
  final identifier = await LicenseService.getActivatedIdentifier();
  if (identifier == null) return false;
  final config = await ref.watch(remoteConfigProvider.future);
  return !config.revokedIdentifiers.contains(identifier);
});
