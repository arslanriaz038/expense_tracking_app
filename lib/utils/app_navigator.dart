import 'package:expense_tracking_app/utils/globals.dart';
import 'package:expense_tracking_app/views/login_screen.dart';
import 'package:flutter/material.dart';

class AppNavigator {
  AppNavigator._();

  static Future<dynamic> push(BuildContext context, Widget screen) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => screen));
  }

  static Future<dynamic> pushReplacement(BuildContext context, Widget screen) {
    return Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => screen));
  }

  static void pop(BuildContext context, [dynamic data]) {
    return Navigator.of(context).pop(data);
  }

  static void popUntilFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Clears the entire stack and shows login (e.g. after logout or account deletion).
  static void goToLogin() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
