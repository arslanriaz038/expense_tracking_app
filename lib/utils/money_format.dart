import 'package:expense_tracking_app/models/app_currency.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:intl/intl.dart';

class MoneyFormat {
  MoneyFormat._();

  static AppCurrency get _currency =>
      AppCurrencyRegistry.forCode(MyPref.getCurrencyCode());

  static bool _hasCents(double amount) {
    final cents = (amount.abs() * 100).round();
    return cents % 100 != 0;
  }

  static NumberFormat _formatterFor(double amount) => NumberFormat.currency(
        symbol: _currency.symbol,
        decimalDigits: _hasCents(amount) ? 2 : 0,
      );

  static String format(double amount) => _formatterFor(amount).format(amount);

  static String formatSigned(double amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${_formatterFor(amount).format(amount.abs())}';
  }

  static double? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned =
        value.replaceAll(RegExp(r'[^\d.,\-]'), '').replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
