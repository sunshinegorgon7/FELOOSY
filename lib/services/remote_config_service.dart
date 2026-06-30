import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../app/app_flavor.dart';
import '../core/constants/app_info.dart';

class RemoteConfig {
  final bool isVersionBlocked;
  final String message;
  final String? storeUrl;
  final Set<String> revokedIdentifiers;
  final int minBuild;

  const RemoteConfig({
    required this.isVersionBlocked,
    required this.message,
    this.storeUrl,
    required this.revokedIdentifiers,
    required this.minBuild,
  });

  factory RemoteConfig.passthrough() => const RemoteConfig(
        isVersionBlocked: false,
        message: '',
        revokedIdentifiers: {},
        minBuild: 0,
      );

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    final minBuild   = (json['min_build'] as num?)?.toInt() ?? 0;
    final androidUrl = json['android_url'] as String?;
    final iosUrl     = json['ios_url'] as String?;
    final revoked    = (json['revoked_identifiers'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toSet();
    return RemoteConfig(
      isVersionBlocked: minBuild > kAppBuildNumber,
      message: json['message'] as String? ?? 'Please update Feloosy to continue.',
      storeUrl: Platform.isAndroid ? androidUrl : iosUrl,
      revokedIdentifiers: revoked,
      minBuild: minBuild,
    );
  }
}

class RemoteConfigService {
  /// Fetches remote config. Skips in dev builds (always returns passthrough).
  /// Fails open: any network error or bad response returns [RemoteConfig.passthrough()].
  static Future<RemoteConfig> fetch() async {
    if (AppFlavor.isDev) return RemoteConfig.passthrough();
    return _fetchInternal();
  }

  /// Same as [fetch] but skips the dev gate — for use in the admin screen test button.
  static Future<RemoteConfig> fetchForTesting() => _fetchInternal();

  static Future<RemoteConfig> _fetchInternal() async {
    if (kRemoteConfigUrl.isEmpty) return RemoteConfig.passthrough();
    try {
      final response = await http
          .get(Uri.parse(kRemoteConfigUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return RemoteConfig.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return RemoteConfig.passthrough();
  }
}
