import 'package:firebase_auth/firebase_auth.dart';

import 'api_error_model.dart';

class ApiErrorHandler {
  static BaseErrorModel handle(dynamic error) {
    if (error is FirebaseAuthException) {
      return FirebaseErrorModel(message: _mapAuthError(error.code));
    } else if (error is FirebaseException) {
      return FirebaseErrorModel(
        message: error.message ?? 'Firebase error occurred',
        code: null,
      );
    } else {
      return GenericErrorModel(message: error.toString());
    }
  }

  static String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
