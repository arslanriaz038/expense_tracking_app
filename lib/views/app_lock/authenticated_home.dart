import 'package:expense_tracking_app/views/app_lock/app_lock_gate.dart';
import 'package:expense_tracking_app/views/main_shell/main_shell_page.dart';
import 'package:flutter/material.dart';

/// Main app shell wrapped with optional biometric lock.
class AuthenticatedHome extends StatelessWidget {
  const AuthenticatedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLockGate(
      child: MainShellPage(),
    );
  }
}
