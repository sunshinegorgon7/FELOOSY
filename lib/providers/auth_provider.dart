import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/database/database_helper.dart';
import '../domain/services/firebase_sync_service.dart';
import '../firebase_options.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

class GoogleAuthActions {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static final Future<void> _initialization = _googleSignIn.initialize(
    serverClientId: DefaultFirebaseOptions.androidServerClientId,
  );

  Future<User?> signIn() async {
    await _initialization;

    final googleUser = await _googleSignIn.authenticate(
      scopeHint: const ['email', 'profile'],
    );

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google sign-in failed: no ID token returned.');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );
    final result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    // Push all local data to Firestore before the session ends so nothing is
    // lost on uninstall. This is a safety net for any sync calls that may have
    // failed silently earlier in the session.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseSyncService(
          uid: user.uid,
          localDb: DatabaseHelper.instance,
        ).pushAll();
      } catch (e) {
        debugPrint('Pre-signout pushAll error: $e');
      }
    }
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }
}

final googleAuthActionsProvider =
    Provider<GoogleAuthActions>((_) => GoogleAuthActions());
