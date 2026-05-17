import 'package:expense_tracking_app/utils/money_format.dart';

class AppFormFieldValidator {
  AppFormFieldValidator._();

  static String? emailValidator(String? email) {
    if (email != null &&
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+")
            .hasMatch(email) &&
        !email.contains(' ')) {
      return null;
    }
    return "Enter valid email address";
  }

  static String? emptyFieldValidator(String? value, String errorMessage) {
    if (value != null && value.trim().isNotEmpty) {
      return null;
    }
    return errorMessage;
  }

  static String? minLengthValidator(
    String? value,
    int minLength,
    String errorMessage,
  ) {
    if (value != null && value.length >= minLength) {
      return null;
    }
    return errorMessage;
  }

  static String? amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = MoneyFormat.parse(value);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount greater than 0';
    }
    if (amount > MoneyFormat.maxAmount) {
      return 'Amount is too large';
    }
    return null;
  }

  static String? nameValidator(String? name, String errorMessage) {
    if (name != null && name.isEmpty) {
      return 'Name is Required';
    } else if (name != null && name.isNotEmpty) {
      final RegExp namePattern = RegExp(r'^[a-zA-Z\- ]+$');

      if (namePattern.hasMatch(name)) {
        return null;
      }
    }
    return errorMessage;
  }
}
