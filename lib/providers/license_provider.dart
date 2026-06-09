import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/license_service.dart';

/// True when a valid Ed25519 license key is stored on this device.
/// Re-verified on every cold start — forged secure-storage values return false.
final licenseProvider = FutureProvider<bool>(
  (_) => LicenseService.loadAndVerify(),
);
