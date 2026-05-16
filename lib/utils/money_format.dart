import 'package:intl/intl.dart';

class MoneyFormat {
  MoneyFormat._();

  static final _currency = NumberFormat.currency(symbol: '\$');

  static String format(double amount) => _currency.format(amount);

  static String formatSigned(double amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${_currency.format(amount.abs())}';
  }

  static double? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'[^\d.,\-]'), '').replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
