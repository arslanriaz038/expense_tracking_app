import 'package:expense_tracking_app/models/user_model.dart';
import 'package:expense_tracking_app/services/firebase_services.dart';
import 'package:expense_tracking_app/services/user_services.dart';
import 'package:expense_tracking_app/utils/app_data.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Syncs Firebase Auth, Firestore user profile, and local session storage.
class AuthSessionService {
  AuthSessionService._();

  static final _userServices = UserServices();
  static final _googleSignIn = GoogleSignIn.instance;

  static Future<UserModel?> restoreSession() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (MyPref.readUserInfo() != null) {
        AppData.clearLocalSession();
      }
      return null;
    }

    return _persistUser(firebaseUser);
  }

  static Future<UserModel> completeSignIn(
    User firebaseUser, {
    String? name,
    String? profilePictureUrl,
    String? providerId,
  }) async {
    return _persistUser(
      firebaseUser,
      name: name,
      profilePictureUrl: profilePictureUrl,
      providerId: providerId,
    );
  }

  static Future<UserModel> _persistUser(
    User firebaseUser, {
    String? name,
    String? profilePictureUrl,
    String? providerId,
  }) async {
    final resolvedName = firebaseUser.displayName?.trim().isNotEmpty == true
        ? firebaseUser.displayName
        : (name?.trim().isNotEmpty == true ? name!.trim() : null) ??
            _nameFromEmail(firebaseUser.email);

    final resolvedProviderId = providerId ??
        (firebaseUser.providerData.isNotEmpty
            ? firebaseUser.providerData.first.providerId
            : 'password');

    final user = await _userServices.signUpUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: resolvedName,
      profilePictureUrl: firebaseUser.photoURL ?? profilePictureUrl,
      providerId: resolvedProviderId,
    );

    AppData.updateCurrentUser(user);
    return user;
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await FirebaseAuth.instance.signOut();
    AppData.clearLocalSession();
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  static bool requiresPasswordForAccountDeletion(User? user) {
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'password');
  }

  static Future<void> deleteAccount({String? password}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    await _reauthenticate(user, password: password);

    await FirebaseServices().deleteAllUserData();
    await user.delete();
    await signOut();
  }

  static Future<void> _reauthenticate(
    User user, {
    String? password,
  }) async {
    final usesPassword =
        user.providerData.any((info) => info.providerId == 'password');

    if (usesPassword) {
      final email = user.email;
      if (email == null || password == null || password.trim().isEmpty) {
        throw FirebaseAuthException(code: 'requires-recent-login');
      }

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: password.trim(),
        ),
      );
      return;
    }

    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : null;

    if (providerId == 'google.com') {
      final googleAccount = await _googleSignIn.authenticate();
      final googleAuth = await googleAccount.authentication;
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(idToken: googleAuth.idToken),
      );
      return;
    }

    if (providerId == 'apple.com') {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthProvider = OAuthProvider('apple.com');
      await user.reauthenticateWithCredential(
        oauthProvider.credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        ),
      );
      return;
    }

    throw FirebaseAuthException(code: 'requires-recent-login');
  }

  static String? _nameFromEmail(String? email) {
    if (email == null || !email.contains('@')) return null;
    final local = email.split('@').first.trim();
    if (local.isEmpty) return null;
    return local[0].toUpperCase() + local.substring(1);
  }
}
