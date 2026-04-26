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
  // No serverClientId → Google Play Services returns an accessToken only
  // (idToken stays null). Firebase Auth accepts accessToken alone and
  // validates it via Google's tokeninfo endpoint. This avoids
  // ApiException: 10 which is triggered by serverClientId pointing at an
  // OAuth client whose consent screen is not yet published.
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
      // idToken intentionally omitted — requires serverClientId + published
      // OAuth consent screen, which is not set up yet.
    );
    final result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    try { await _googleSignIn.disconnect(); } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }
}

final googleAuthActionsProvider =
    Provider<GoogleAuthActions>((_) => GoogleAuthActions());
