import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Thrown when sign-in needs the existing provider first, then [pendingCredential]
/// can be linked.
class AccountLinkRequired implements Exception {
  AccountLinkRequired({
    required this.email,
    required this.pendingCredential,
    required this.pendingProviderLabel,
  });

  final String email;
  final AuthCredential pendingCredential;
  final String pendingProviderLabel;
}

class AccountLinkingService {
  AccountLinkingService._();

  static final _googleSignIn = GoogleSignIn.instance;

  static String providerLabel(String? providerId) {
    return switch (providerId) {
      'password' => 'Email & password',
      'google.com' => 'Google',
      'apple.com' => 'Apple',
      _ => 'another method',
    };
  }

  static String pendingProviderLabel(AuthCredential credential) {
    return providerLabel(credential.providerId);
  }

  static Future<UserCredential> signInWithCredentialHandlingLink(
    AuthCredential credential, {
    required String pendingProviderLabel,
  }) async {
    try {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential' &&
          e.email != null &&
          e.credential != null) {
        throw AccountLinkRequired(
          email: e.email!,
          pendingCredential: e.credential!,
          pendingProviderLabel: pendingProviderLabel,
        );
      }
      rethrow;
    }
  }

  /// Sign in with email/password, then link the pending social credential.
  static Future<User> linkPendingCredentialWithPassword({
    required String email,
    required String password,
    required AuthCredential pendingCredential,
  }) async {
    final signIn = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = signIn.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    await _linkIfNeeded(user, pendingCredential);
    return user;
  }

  static Future<void> linkGoogleToCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final googleAccount = await _googleSignIn.authenticate();
    final googleAuth = await googleAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _linkIfNeeded(user, credential);
  }

  static Future<void> linkAppleToCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthProvider = OAuthProvider('apple.com');
    final credential = oauthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    await _linkIfNeeded(user, credential);
  }

  static Future<void> linkEmailPasswordToCurrentUser({
    required String password,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    if (user.providerData.any((p) => p.providerId == 'password')) {
      throw FirebaseAuthException(
        code: 'provider-already-linked',
        message: 'Email sign-in is already linked.',
      );
    }

    await user.linkWithCredential(
      EmailAuthProvider.credential(email: email, password: password.trim()),
    );
  }

  static bool isProviderLinked(User? user, String providerId) {
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == providerId);
  }

  static Future<void> _linkIfNeeded(User user, AuthCredential credential) async {
    try {
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' ||
          e.code == 'credential-already-in-use') {
        return;
      }
      rethrow;
    }
  }
}
