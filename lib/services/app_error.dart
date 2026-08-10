import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

String userMessage(Object error) {
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
  if (error is FirebaseException && error.code == 'permission-denied') {
    return "You don't have permission to perform this action.";
  }
  return 'Something went wrong. Please try again.';
}
