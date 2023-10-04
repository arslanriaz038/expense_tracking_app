import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/views/expenses_screen.dart';
import 'package:expense_tracking_app/views/signup_screen.dart';
import 'package:expense_tracking_app/views/social_login_buttons/view/social_login_buttons.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loginWithEmailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          AppNavigator.pushReplacement(context, const ExpensesPage());
        }
      } catch (e) {
        AppAlerts.showErrorMessage(context, '$e');
        print('Error signing in: $e');
        // Handle login errors (e.g., show an error message to the user).
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 99,
                ),
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
                  validator: (value) => AppFormFieldValidator.emailValidator(
                    value,
                  ),
                ),
                const SizedBox(height: 16),
                MyInputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPassword: true,
                  validator: (value) =>
                      AppFormFieldValidator.emptyFieldValidator(
                          value, 'Enter Password '),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      AppNavigator.pushReplacement(
                          context, const SignupScreen());
                    },
                    child: Text(
                      'Sign up?',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 31),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      _loginWithEmailAndPassword();
                    },
                    child: const Text('Login'),
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
                const SizedBox(height: 83),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Don\'t have an Account? ',
                        style: Theme.of(context).textTheme.labelLarge),
                    TextButton(
                      onPressed: () {
                        AppNavigator.pushReplacement(
                            context, const SignupScreen());
                      },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
