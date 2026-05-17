import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/auth_error_message.dart';
import 'package:expense_tracking_app/utils/helper_functions.dart';
import 'package:expense_tracking_app/views/forgot_password_screen.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    hideKeyBoard();
    setState(() => _isLoading = true);

    try {
      await AuthSessionService.changePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      if (!mounted) return;
      AppAlerts.showSuccessMessage(context, 'Password updated successfully');
      AppNavigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppAlerts.showErrorMessage(context, AuthErrorMessage.from(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose a new password',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your current password, then your new password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              MyInputField(
                controller: _currentPasswordController,
                hintText: 'Current password',
                isPassword: true,
                validator: (value) => AppFormFieldValidator.emptyFieldValidator(
                  value,
                  'Enter your current password',
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => AppNavigator.push(
                            context,
                            const ForgotPasswordScreen(),
                          ),
                  child: const Text('Forgot current password?'),
                ),
              ),
              const SizedBox(height: 8),
              MyInputField(
                controller: _newPasswordController,
                hintText: 'New password',
                isPassword: true,
                validator: (value) => AppFormFieldValidator.minLengthValidator(
                  value,
                  8,
                  'Password must be at least 8 characters',
                ),
              ),
              const SizedBox(height: 16),
              MyInputField(
                controller: _confirmPasswordController,
                hintText: 'Confirm new password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Update password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
