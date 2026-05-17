import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';

/// Returns the password if the user confirmed linking, or null if canceled.
Future<String?> showLinkAccountPasswordDialog(
  BuildContext context, {
  required String email,
  required String pendingProviderLabel,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _LinkAccountPasswordDialog(
      email: email,
      pendingProviderLabel: pendingProviderLabel,
    ),
  );
}

class _LinkAccountPasswordDialog extends StatefulWidget {
  const _LinkAccountPasswordDialog({
    required this.email,
    required this.pendingProviderLabel,
  });

  final String email;
  final String pendingProviderLabel;

  @override
  State<_LinkAccountPasswordDialog> createState() =>
      _LinkAccountPasswordDialogState();
}

class _LinkAccountPasswordDialogState extends State<_LinkAccountPasswordDialog> {
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
      title: const Text('Link accounts'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'An account for ${widget.email} already exists with email & password. '
              'Enter your password to link ${widget.pendingProviderLabel} to the same account.',
            ),
            const SizedBox(height: 16),
            MyInputField(
              controller: _passwordController,
              hintText: 'Password',
              isPassword: true,
              validator: (value) => AppFormFieldValidator.emptyFieldValidator(
                value,
                'Enter your password',
              ),
            ),
          ],
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
          child: const Text('Link & sign in'),
        ),
      ],
    );
  }
}

Future<bool> showEmailAlreadyRegisteredDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Email already registered'),
      content: const Text(
        'This email is already linked to an account. Sign in with your existing '
        'method (email or social), then link other sign-in options from '
        'More → Link sign-in methods.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Go to sign in'),
        ),
      ],
    ),
  );

  return result ?? false;
}
