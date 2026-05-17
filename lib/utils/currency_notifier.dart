import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:flutter/foundation.dart';

class CurrencyNotifier extends ChangeNotifier {
  CurrencyNotifier._();

  static final instance = CurrencyNotifier._();

  Future<void> setCurrencyCode(String code) async {
    await MyPref.setCurrencyCode(code);
    notifyListeners();
  }
}
