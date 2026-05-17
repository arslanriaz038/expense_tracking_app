import 'package:expense_tracking_app/models/user_model.dart';
import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';

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

  static void clearLocalSession() {
    _user = null;
    MyPref.logOutUser();
  }

  static Future<void> logOutUserMain() => AuthSessionService.signOut();
}
