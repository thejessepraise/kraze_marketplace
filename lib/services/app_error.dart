import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_service.dart';

String userMessage(Object error) {
  // AuthService already converts Firebase's error codes into a
  // friendly, ready-to-show message (see auth_service.dart) — use it
  // directly instead of falling through to the generic message below.
  if (error is AuthException) {
    return error.message;
  }
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found': return 'Email or password is incorrect.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password': return 'Choose a stronger password.';
      case 'network-request-failed': return 'Check your internet connection and try again.';
      default: return 'Unable to complete that request. Please try again.';
    }
  }
  if (error is FirebaseException) {
    // During development/demo, showing the code helps diagnose missing
    // indexes or permission issues immediately.
    final code = error.code;
    if (code == 'permission-denied') {
      return "Permission Denied: Check your Firestore rules.";
    }
    if (code == 'unavailable') {
      return "Firebase is unavailable. Check your internet connection.";
    }
    return 'Firebase Error ($code): ${error.message}';
  }
  return 'Error: ${error.toString()}';
}
