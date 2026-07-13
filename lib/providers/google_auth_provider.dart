import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

const kDriveAppDataScope = 'https://www.googleapis.com/auth/drive.appdata';

const _lastRestoreAttemptKey = 'feloosy_google_restore_last_attempt_ms';
const _restoreThrottle = Duration(hours: 24);

class GoogleAccountNotifier extends Notifier<GoogleSignInAccount?> {
  static final _init = GoogleSignIn.instance.initialize(
    serverClientId:
        '623272973124-mnu6801i3rlbls311al4490cntfn80q1.apps.googleusercontent.com',
  );
  static const _storage = FlutterSecureStorage();

  @override
  GoogleSignInAccount? build() {
    _restoreSession();
    return null;
  }

  // Android's Credential Manager can show a confirmation sheet on every
  // attemptLightweightAuthentication() call even for a previously-authorized
  // account (a known platform quirk, not fully silent as documented). Throttle
  // to once per rolling window so it doesn't re-prompt on every cold launch.
  Future<void> _restoreSession() async {
    try {
      await _init;
      final raw = await _storage.read(key: _lastRestoreAttemptKey);
      final lastMs = raw != null ? int.tryParse(raw) : null;
      if (lastMs != null &&
          DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(lastMs),
              ) <
              _restoreThrottle) {
        return;
      }
      await _storage.write(
        key: _lastRestoreAttemptKey,
        value: '${DateTime.now().millisecondsSinceEpoch}',
      );
      final account = await GoogleSignIn.instance
          .attemptLightweightAuthentication();
      if (account != null) state = account;
    } catch (_) {
      // Sign-in unavailable (e.g. missing Play Services on emulator).
    }
  }

  Future<void> signIn() async {
    await _init;
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: ['email', 'profile', kDriveAppDataScope],
    );
    await GoogleSignIn.instance.authorizationClient.authorizeScopes([
      kDriveAppDataScope,
    ]);
    await _storage.write(
      key: _lastRestoreAttemptKey,
      value: '${DateTime.now().millisecondsSinceEpoch}',
    );
    state = account;
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.disconnect();
    state = null;
  }
}

final googleAccountProvider =
    NotifierProvider<GoogleAccountNotifier, GoogleSignInAccount?>(
      GoogleAccountNotifier.new,
    );
