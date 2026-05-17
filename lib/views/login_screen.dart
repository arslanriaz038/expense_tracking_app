import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/auth_error_message.dart';
import 'package:expense_tracking_app/views/app_lock/authenticated_home.dart';
import 'package:expense_tracking_app/views/forgot_password_screen.dart';
import 'package:expense_tracking_app/views/signup_screen.dart';
import 'package:expense_tracking_app/views/social_login_buttons/view/social_login_buttons.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmailAndPassword() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      await AuthSessionService.completeSignIn(user);

      if (!mounted) return;
      AppNavigator.pushReplacement(context, const AuthenticatedHome());
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 99),
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome! Login with your credentials',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                MyInputField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: AppFormFieldValidator.emailValidator,
                ),
                const SizedBox(height: 16),
                MyInputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPassword: true,
                  validator: (value) => AppFormFieldValidator.emptyFieldValidator(
                    value,
                    'Enter password',
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => AppNavigator.push(
                              context,
                              const ForgotPasswordScreen(),
                            ),
                    child: Text(
                      'Forgot password?',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _loginWithEmailAndPassword,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Or login with',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const SocialLoginButtons(),
                const SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => AppNavigator.pushReplacement(
                                context,
                                const SignupScreen(),
                              ),
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
