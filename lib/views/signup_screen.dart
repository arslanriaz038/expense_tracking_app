import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/helper_functions.dart';
import 'package:expense_tracking_app/views/login_screen.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyInputField(
                controller: _emailController,
                hintText: 'Email',
                validator: (value) => AppFormFieldValidator.emailValidator(
                  value,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MyInputField(
                controller: _passwordController,
                isPassword: true,
                hintText: 'Password',
                validator: (value) => AppFormFieldValidator.minLengthValidator(
                    value, 8, 'Password must be 8 Characters'),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    AppNavigator.pushReplacement(context, const LoginScreen());
                  },
                  child: Text(
                    'Login?',
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
                child: ElevatedButton(
                  onPressed: () {
                    // Call a function to sign up the user with email and password
                    signUpWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to sign up the user with email and password
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    if (formKey.currentState?.validate() ?? false) {
      hideKeyBoard();
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (context.mounted) {
          AppNavigator.pushReplacement(context, const LoginScreen());
          AppAlerts.showSuccessMessage(context, 'SingUp Success!');
        }

        // After successful signup, you can navigate to another screen
        // or perform other actions as needed.
      } catch (e) {
        print('Error signing up: $e');
        // Handle signup errors (e.g., show an error message to the user).
      }
    }
  }
}
