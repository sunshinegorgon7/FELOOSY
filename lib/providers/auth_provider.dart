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
  Future<User?> signIn() async {
    // Use Firebase Auth's built-in OAuth provider flow (Chrome Custom Tab).
    // This avoids the google_sign_in SDK handshake that causes ApiException 10
    // when the Google Cloud OAuth consent screen isn't fully published.
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    final result =
        await FirebaseAuth.instance.signInWithProvider(provider);
    return result.user;
  }

  Future<void> signOut() async {
    // Also disconnect the Google session so the picker re-appears next time.
    try { await GoogleSignIn().disconnect(); } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }
}

final googleAuthActionsProvider =
    Provider<GoogleAuthActions>((_) => GoogleAuthActions());
