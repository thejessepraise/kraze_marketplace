import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// A short, plain-English error message safe to show directly in a
/// SnackBar — as opposed to Firebase's own error text, which is written
/// for developers (e.g. "[firebase_auth/invalid-credential] The supplied
/// auth credential is malformed or has expired.").
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

/// Central Firebase Authentication wrapper for Kraze.
///
/// Keeping FirebaseAuth (and now GoogleSignIn) calls here means the UI
/// pages do not need to know Firebase APIs directly. If the auth
/// implementation changes later, the pages can stay mostly unchanged.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  /// Signs in (or, on first use, silently creates) a Kraze account using
  /// the student's Google account.
  ///
  /// WHY THIS SAME METHOD WORKS FOR BOTH LOGIN AND SIGNUP:
  /// Firebase treats "sign in with Google" as one operation — if this is
  /// the first time this Google account has been used with Kraze,
  /// Firebase creates a new account automatically; if it's been used
  /// before, it just signs them in. There's no separate "Google signup"
  /// call needed, which is why both login_page.dart and signup_page.dart
  /// can call this exact same method.
  ///
  /// Returns null if the student closes the account picker without
  /// choosing anything (a cancellation, not a real error).
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // On Flutter Web, use Firebase's native web OAuth flow instead of
      // google_sign_in's authenticate() API. This avoids the platform
      // mismatch that can crash the web build after the Google popup opens.
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        return await _auth.signInWithPopup(provider);
      }

      // On Android/iOS, initialize the current google_sign_in 7.x API
      // before attempting authentication.
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw AuthException(
          'Google did not return an ID token. Please try again.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw AuthException(
        'Google sign-in failed (${e.code.name}). Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    } catch (e) {
      // Keep the actual exception out of the UI, but preserve a useful
      // message for common web OAuth configuration failures.
      final message = e.toString();
      if (message.contains('popup-blocked')) {
        throw AuthException(
          'Google sign-in popup was blocked. Allow popups for this site and try again.',
        );
      }
      if (message.contains('unauthorized-domain')) {
        throw AuthException(
          'This site is not authorized for Google sign-in. Add localhost to Firebase Authentication Authorized Domains.',
        );
      }
      if (message.contains('popup-closed-by-user')) {
        return null;
      }
      throw AuthException('Google sign-in failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  /// Converts Firebase's error codes into plain-English messages.
  ///
  /// WHY A switch ON e.code (not e.message):
  /// e.code is a stable, documented string ('user-not-found', etc.)
  /// that Firebase won't change wording on. e.message is meant for
  /// developer logs, and its exact phrasing isn't something we should
  /// build user-facing text around.
  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error — check your connection and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Authentication.';
      case 'unauthorized-domain':
        return 'This site is not authorized for Firebase Authentication. Add its domain in Firebase Authentication settings.';
      case 'popup-blocked':
        return 'The Google sign-in popup was blocked. Allow popups for this site and try again.';
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
