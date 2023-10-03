import 'package:expense_tracking_app/consts/my_preferences_constants.dart';
import 'package:expense_tracking_app/models/user_model.dart';
import 'package:expense_tracking_app/utils/app_data.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:get_storage/get_storage.dart';

class MyPref {
  static final _storage = GetStorage();

  MyPref._();

  static void updateUserInfo(UserModel child) {
    _storage.write(
      MyPreferencesConstants.currentUser,
      child.toMap(),
    );
  }

  static UserModel? readUserInfo() {
    return UserModel.fromMap(
      _storage.read(MyPreferencesConstants.currentUser),
    );
  }

  static bool isUserLoggedIn() {
    final savedValue = _storage.read(MyPreferencesConstants.currentUser);
    if (savedValue != null) {
      final user = UserModel.fromMap(savedValue);
      AppData.updateCurrentUser(user, storeInPreferences: false);
      return true;
    }

    return false;
  }

  static void logOutUser() {
    _storage.remove(MyPreferencesConstants.currentUser);
  }
}
