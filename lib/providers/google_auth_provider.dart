import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

const kDriveAppDataScope = 'https://www.googleapis.com/auth/drive.appdata';

class GoogleAccountNotifier extends Notifier<GoogleSignInAccount?> {
  static final _init = GoogleSignIn.instance.initialize();

  @override
  GoogleSignInAccount? build() {
    _restoreSession();
    return null;
  }

  Future<void> _restoreSession() async {
    await _init;
    final account =
        await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account != null) state = account;
  }

  Future<void> signIn() async {
    await _init;
    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: ['email', 'profile', kDriveAppDataScope],
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
