import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

class GoogleAuthActions {
  // Web client ID (type 3) from google-services.json — required for Firebase Auth
  static const _webClientId =
      '623272973124-mnu6801i3rlbls311al4490cntfn80q1.apps.googleusercontent.com';

  Future<User?> signIn() async {
    final googleUser = await GoogleSignIn(
      serverClientId: _webClientId,
      scopes: ['email', 'profile'],
    ).signIn();
    if (googleUser == null) return null; // user dismissed the picker

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception(
        'Google sign-in returned no ID token. '
        'Verify the web OAuth client ID in Firebase console matches the '
        'type-3 client in google-services.json.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: idToken,
    );
    final result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}

final googleAuthActionsProvider =
    Provider<GoogleAuthActions>((_) => GoogleAuthActions());
