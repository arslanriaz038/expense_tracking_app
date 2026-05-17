import 'package:expense_tracking_app/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppAlerts {
  AppAlerts._();

  static OverlayState? _resolveOverlay(BuildContext context) {
    final rootOverlay = navigatorKey.currentState?.overlay;
    if (rootOverlay != null) {
      return rootOverlay;
    }

    try {
      return Overlay.of(context);
    } catch (_) {
      return null;
    }
  }

  static void showErrorMessage(BuildContext context, [String? message]) {
    final overlay = _resolveOverlay(context);
    if (overlay == null) return;

    showTopSnackBar(
      overlay,
      CustomSnackBar.error(
        message: message ?? 'Something went wrong',
      ),
    );
  }

  static void showInfoMessage(BuildContext context, String message) {
    final overlay = _resolveOverlay(context);
    if (overlay == null) return;

    showTopSnackBar(
      overlay,
      CustomSnackBar.info(
        message: message,
      ),
    );
  }

  static void showSuccessMessage(BuildContext context, String message) {
    final overlay = _resolveOverlay(context);
    if (overlay == null) return;

    showTopSnackBar(
      overlay,
      CustomSnackBar.success(
        message: message,
      ),
    );
  }
}
