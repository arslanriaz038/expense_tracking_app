import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/auth_error_message.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/delete_account_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDeleteAccountConfirmDialog(context);
    if (!confirmed || !context.mounted) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    String? password;

    if (AuthSessionService.requiresPasswordForAccountDeletion(firebaseUser)) {
      password = await showDeleteAccountPasswordDialog(context);
      if (password == null || !context.mounted) return;
    }

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(height: 16),
                  Text('Deleting account...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      context.read<ExpensesCubit>().stopListening();
      await AuthSessionService.deleteAccount(password: password);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      AppNavigator.goToLogin();
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      AppAlerts.showErrorMessage(context, AuthErrorMessage.from(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return ListTile(
      leading: Icon(Icons.delete_forever_outlined, color: errorColor),
      title: Text(
        'Delete account',
        style: TextStyle(color: errorColor, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'Permanently remove your account and all data',
      ),
      onTap: () => _deleteAccount(context),
    );
  }
}
