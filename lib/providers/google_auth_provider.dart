import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

const kDriveAppDataScope = 'https://www.googleapis.com/auth/drive.appdata';

class GoogleAccountNotifier extends Notifier<GoogleSignInAccount?> {
  static final _init = GoogleSignIn.instance.initialize(
    serverClientId:
        '623272973124-mnu6801i3rlbls311al4490cntfn80q1.apps.googleusercontent.com',
  );

  @override
  GoogleSignInAccount? build() {
    _restoreSession();
    return null;
  }

  Future<void> _restoreSession() async {
    try {
      await _init;
      final account =
          await GoogleSignIn.instance.attemptLightweightAuthentication();
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
    await GoogleSignIn.instance.authorizationClient
        .authorizeScopes([kDriveAppDataScope]);
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
