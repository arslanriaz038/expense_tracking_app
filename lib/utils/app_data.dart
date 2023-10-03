import 'package:expense_tracking_app/models/user_model.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppData {
  AppData._();

  static UserModel? _user;

  static void updateCurrentUser(
    UserModel user, {
    bool storeInPreferences = true,
  }) {
    _user = user;

    if (storeInPreferences) {
      MyPref.updateUserInfo(user);
    }
  }

  static UserModel? get currentUser => _user;

  static void logOutUser() {
    _user = null;
    MyPref.logOutUser();
    FirebaseAuth.instance.signOut();
  }
}
