import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

const kDriveAppDataScope = 'https://www.googleapis.com/auth/drive.appdata';

// Singleton shared by the auth provider and the backup service.
final googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile', kDriveAppDataScope],
);

final googleAccountProvider = StreamProvider<GoogleSignInAccount?>((ref) {
  return googleSignIn.onCurrentUserChanged;
});

class GoogleAuthActions {
  Future<GoogleSignInAccount?> signIn() => googleSignIn.signIn();
  Future<void> signOut() => googleSignIn.disconnect();
}

final googleAuthActionsProvider =
    Provider<GoogleAuthActions>((_) => GoogleAuthActions());
