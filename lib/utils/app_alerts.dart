import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppAlerts {
  AppAlerts._();

  static void showErrorMessage(BuildContext context, [String? message]) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message ?? "Something went wrong",
      ),
    );
  }

  static void showInfoMessage(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        message: message,
      ),
    );
  }

  static void showSuccessMessage(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
      ),
    );
  }
}
