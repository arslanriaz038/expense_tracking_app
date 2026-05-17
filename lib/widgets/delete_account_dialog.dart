import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';

Future<String?> showDeleteAccountPasswordDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _DeleteAccountPasswordDialog(),
  );
}

class _DeleteAccountPasswordDialog extends StatefulWidget {
  const _DeleteAccountPasswordDialog();

  @override
  State<_DeleteAccountPasswordDialog> createState() =>
      _DeleteAccountPasswordDialogState();
}

class _DeleteAccountPasswordDialogState
    extends State<_DeleteAccountPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm your password'),
      content: Form(
        key: _formKey,
        child: MyInputField(
          controller: _passwordController,
          hintText: 'Password',
          isPassword: true,
          validator: (value) => AppFormFieldValidator.emptyFieldValidator(
            value,
            'Enter your password',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_passwordController.text.trim());
            }
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

Future<bool> showDeleteAccountConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 32,
      ),
      title: const Text('Delete account?'),
      content: const Text(
        'This permanently deletes your account, transactions, budgets, '
        'categories, and receipt images. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete account'),
        ),
      ],
    ),
  );

  return result ?? false;
}
