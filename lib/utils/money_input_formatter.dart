import 'package:expense_tracking_app/models/app_currency.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats numeric input with locale-aware thousands grouping and decimals.
///
/// Examples (en_US): `1000` → `1,000`, `1234.5` → `1,234.5`
class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter({String? locale})
      : _locale = locale ??
            AppCurrencyRegistry.forCode(MyPref.getCurrencyCode())
                .numberFormatLocale;

  /// Max digits before the decimal point (avoids int/double overflow).
  static const int maxWholeDigits = 12;

  static const int maxFractionDigits = 2;

  final String _locale;

  NumberFormat get _symbolsFormat => NumberFormat.decimalPattern(_locale);

  String get _groupingSeparator => _symbolsFormat.symbols.GROUP_SEP;

  String get _decimalSeparator => _symbolsFormat.symbols.DECIMAL_SEP;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) {
      return newValue;
    }

    final normalized = _normalizeRawInput(raw);
    if (normalized == null) {
      return oldValue;
    }

    final formatted = _tryFormatNormalized(normalized);
    if (formatted == null) {
      return oldValue;
    }

    final selectionIndex = _cursorIndex(
      oldValue: oldValue,
      newValue: newValue,
      formatted: formatted,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  /// Keeps digits and at most one decimal separator; limits fraction digits.
  String? _normalizeRawInput(String raw) {
    final buffer = StringBuffer();
    var hasDecimal = false;
    var wholeDigits = 0;
    var fractionDigits = 0;

    for (final rune in raw.runes) {
      final char = String.fromCharCode(rune);
      if (_isDigit(char)) {
        if (hasDecimal) {
          if (fractionDigits >= maxFractionDigits) {
            return null;
          }
          fractionDigits++;
        } else {
          if (wholeDigits >= maxWholeDigits) {
            return null;
          }
          wholeDigits++;
        }
        buffer.write(char);
      } else if (char == _groupingSeparator) {
        // Ignore thousands separators already present in the field text.
        continue;
      } else if (char == _decimalSeparator) {
        if (hasDecimal) continue;
        hasDecimal = true;
        buffer.write(_decimalSeparator);
      }
    }

    final result = buffer.toString();
    if (result == _decimalSeparator) {
      return '0$_decimalSeparator';
    }
    return result;
  }

  String? _tryFormatNormalized(String normalized) {
    try {
      return _formatNormalized(normalized);
    } catch (_) {
      return null;
    }
  }

  String _formatNormalized(String normalized) {
    final endsWithDecimal = normalized.endsWith(_decimalSeparator);
    final parts = normalized.split(_decimalSeparator);
    final wholeDigits = _stripLeadingZeros(
      parts.first.replaceAll(_groupingSeparator, ''),
    );
    if (wholeDigits.isEmpty && !endsWithDecimal) {
      return '';
    }

    final wholeFormatted = _formatGroupedDigits(wholeDigits);

    if (parts.length == 1 && !endsWithDecimal) {
      return wholeFormatted;
    }

    final fraction = parts.length > 1 ? parts[1] : '';
    if (endsWithDecimal && fraction.isEmpty) {
      return '$wholeFormatted$_decimalSeparator';
    }
    return '$wholeFormatted$_decimalSeparator$fraction';
  }

  /// Groups digit strings without parsing to [int] (safe for very long input).
  String _formatGroupedDigits(String digits) {
    if (digits.isEmpty || digits == '0') return '0';

    final mod = digits.length % 3;
    final groups = <String>[];

    if (mod > 0) {
      groups.add(digits.substring(0, mod));
    }
    for (var i = mod; i < digits.length; i += 3) {
      groups.add(digits.substring(i, i + 3));
    }

    return groups.join(_groupingSeparator);
  }

  String _stripLeadingZeros(String digits) {
    if (digits.isEmpty) return '';
    var start = 0;
    while (start < digits.length - 1 && digits[start] == '0') {
      start++;
    }
    return digits.substring(start);
  }

  int _cursorIndex({
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
    required String formatted,
  }) {
    final oldCursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final digitsBeforeCursor = _countDigitsAndDecimal(
      newValue.text.substring(0, oldCursor),
    );

    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      final char = formatted[i];
      if (_isDigit(char) || char == _decimalSeparator) {
        seen++;
        if (seen >= digitsBeforeCursor) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }

  int _countDigitsAndDecimal(String text) {
    var count = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (_isDigit(char) || char == _decimalSeparator) {
        count++;
      }
    }
    return count;
  }

  bool _isDigit(String char) => RegExp(r'\d').hasMatch(char);
}
