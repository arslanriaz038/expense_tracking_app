import 'package:expense_tracking_app/models/user_model.dart';
import 'package:expense_tracking_app/services/user_services.dart';
import 'package:expense_tracking_app/utils/app_data.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  static String? _nameFromEmail(String? email) {
    if (email == null || !email.contains('@')) return null;
    final local = email.split('@').first.trim();
    if (local.isEmpty) return null;
    return local[0].toUpperCase() + local.substring(1);
  }
}
