import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/auth_error_message.dart';
import 'package:expense_tracking_app/utils/helper_functions.dart';
import 'package:expense_tracking_app/views/app_lock/authenticated_home.dart';
import 'package:expense_tracking_app/views/login_screen.dart';
import 'package:expense_tracking_app/widgets/link_account_dialog.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    hideKeyBoard();
    setState(() => _isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'operation-not-allowed');
      }

      final name = _nameController.text.trim();
      await user.updateDisplayName(name);

      await AuthSessionService.completeSignIn(
        user,
        name: name,
        providerId: 'password',
      );

      if (!mounted) return;
      AppAlerts.showSuccessMessage(context, 'Account created successfully');
      AppNavigator.pushReplacement(context, const AuthenticatedHome());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email-already-in-use') {
        final goToLogin = await showEmailAlreadyRegisteredDialog(context);
        if (goToLogin && mounted) {
          AppNavigator.pushReplacement(
            context,
            LoginScreen(initialEmail: _emailController.text.trim()),
          );
        }
        return;
      }
      AppAlerts.showErrorMessage(context, AuthErrorMessage.from(e));
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
        title: const Text('Sign up'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              MyInputField(
                controller: _nameController,
                hintText: 'Full name',
                textCapitalization: TextCapitalization.words,
                validator: (value) => AppFormFieldValidator.emptyFieldValidator(
                  value,
                  'Name is required',
                ),
              ),
              const SizedBox(height: 20),
              MyInputField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: AppFormFieldValidator.emailValidator,
              ),
              const SizedBox(height: 20),
              MyInputField(
                controller: _passwordController,
                isPassword: true,
                hintText: 'Password',
                validator: (value) => AppFormFieldValidator.minLengthValidator(
                  value,
                  8,
                  'Password must be at least 8 characters',
                ),
              ),
              const SizedBox(height: 20),
              MyInputField(
                controller: _confirmPasswordController,
                isPassword: true,
                hintText: 'Confirm password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => AppNavigator.pushReplacement(
                            context,
                            const LoginScreen(),
                          ),
                  child: Text(
                    'Already have an account?',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: ColorName.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
