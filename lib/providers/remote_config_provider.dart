import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/remote_config_service.dart';

/// Fetches the GitHub Gist remote config once per cold start.
/// Controls the version kill switch and per-user identifier revocation.
/// Always resolves — fails open (passthrough) if the Gist is unreachable.
final remoteConfigProvider = FutureProvider<RemoteConfig>(
  (_) => RemoteConfigService.fetch(),
);
