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
  // Keep the Android Google sign-in request minimal here. The usual cause of
  // ApiException: 10 is Firebase/Google OAuth misconfiguration such as a
  // package-name or SHA mismatch.
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<User?> signIn() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user dismissed picker

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    if (accessToken == null) {
      throw Exception('Google sign-in failed: no access token returned.');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      // idToken intentionally omitted until a matching server client ID is
      // wired for the app's Firebase/Google OAuth setup.
    );
    final result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }
}

final googleAuthActionsProvider =
    Provider<GoogleAuthActions>((_) => GoogleAuthActions());
