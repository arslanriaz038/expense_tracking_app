import 'package:expense_tracking_app/gen/assets.gen.dart';
import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/views/expenses_screen.dart';
import 'package:expense_tracking_app/views/social_login_buttons/view/social_login_buttons.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    ?.copyWith(color: ColorName.darGreyText),
              ),
              const SizedBox(height: 32),
              const MyInputField(
                hintText: 'Email',
              ),
              const SizedBox(height: 16),
              const MyInputField(
                hintText: 'Password',
                isPassword: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // AppNavigator.pushReplacement(
                    //     context, const ForgetPasswordPage());
                  },
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: ColorName.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 31),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    AppNavigator.pushReplacement(context, const ExpensesPage());
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
                    ?.copyWith(color: ColorName.darGreyText),
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
                      // AppNavigator.pushReplacement(context, const SignUpPage());
                    },
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ColorName.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
