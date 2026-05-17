import 'package:expense_tracking_app/models/app_currency.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:intl/intl.dart';

class MoneyFormat {
  MoneyFormat._();

  static AppCurrency get _currency =>
      AppCurrencyRegistry.forCode(MyPref.getCurrencyCode());

  static NumberFormat get _formatter =>
      NumberFormat.currency(symbol: _currency.symbol);

  static String format(double amount) => _formatter.format(amount);

  static String formatSigned(double amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${_formatter.format(amount.abs())}';
  }

  static double? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned =
        value.replaceAll(RegExp(r'[^\d.,\-]'), '').replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
