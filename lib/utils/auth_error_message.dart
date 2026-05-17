import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMessage {
  AuthErrorMessage._();

  static String from(Object error) {
    if (error is FirebaseAuthException) {
      return _fromCode(error.code, error.message);
    }

    final message = error.toString();
    if (message.contains('network')) {
      return 'Network error. Check your connection and try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  static String _fromCode(String code, String? fallback) {
    return switch (code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account found for this email.',
      'wrong-password' => 'Incorrect password. Try again.',
      'invalid-credential' => 'Invalid email or password.',
      'email-already-in-use' => 'An account already exists with this email.',
      'weak-password' => 'Password is too weak. Use at least 8 characters.',
      'operation-not-allowed' =>
        'This action is not available for your sign-in method.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      'account-exists-with-different-credential' =>
        'This email is already registered. Sign in with your existing method to link accounts.',
      'provider-already-linked' => 'That sign-in method is already linked.',
      'credential-already-in-use' =>
        'This sign-in method is already linked to your account.',
      'invalid-verification-code' => 'Invalid verification code.',
      'invalid-verification-id' => 'Verification expired. Please try again.',
      'cancelled' || 'canceled' => 'Sign-in was canceled.',
      'requires-recent-login' =>
        'For security, confirm your identity before deleting your account.',
      _ => fallback?.isNotEmpty == true
          ? fallback!
          : 'Authentication failed. Please try again.',
    };
  }
}
