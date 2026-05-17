import 'package:expense_tracking_app/models/app_currency.dart';
import 'package:expense_tracking_app/utils/money_input_formatter.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyFormat {
  MoneyFormat._();

  /// Largest amount allowed in inputs (12 whole digits + cents).
  static const double maxAmount = 999999999999.99;

  static AppCurrency get _currency =>
      AppCurrencyRegistry.forCode(MyPref.getCurrencyCode());

  static String get _locale => _currency.numberFormatLocale;

  static bool _hasCents(double amount) {
    final cents = (amount.abs() * 100).round();
    return cents % 100 != 0;
  }

  static NumberFormat _formatterFor(double amount) => NumberFormat.currency(
        locale: _locale,
        symbol: _currency.symbol,
        decimalDigits: _hasCents(amount) ? 2 : 0,
      );

  static NumberFormat get _inputNumberFormat =>
      NumberFormat('#,##0.##', _locale);

  static TextInputFormatter get inputFormatter =>
      MoneyInputFormatter(locale: _locale);

  static String format(double amount) => _formatterFor(amount).format(amount);

  static String formatSigned(double amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${_formatterFor(amount).format(amount.abs())}';
  }

  /// Formats a stored or raw amount string for display in an input field.
  static String formatForInput(String? value) {
    final amount = parse(value);
    if (amount == null) return value?.trim() ?? '';

    if (_hasCents(amount)) {
      return NumberFormat('#,##0.00', _locale).format(amount);
    }
    return NumberFormat('#,##0', _locale).format(amount);
  }

  /// Plain numeric string for persistence (no grouping separators).
  static String normalizeForStorage(String value) {
    final amount = parse(value);
    if (amount == null) return value.trim();

    if (_hasCents(amount)) {
      return amount.toStringAsFixed(2);
    }
    return amount.truncate().toString();
  }

  static double? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final trimmed = value.trim();
    try {
      final amount = _inputNumberFormat.parse(trimmed);
      return amount.toDouble();
    } catch (_) {
      // Fallback for plain numeric strings (e.g. legacy storage).
      return double.tryParse(trimmed);
    }
  }
}
