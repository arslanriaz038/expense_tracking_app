import 'dart:io';

import 'package:expense_tracking_app/services/account_linking_service.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_form_fields_validator.dart';
import 'package:expense_tracking_app/utils/auth_error_message.dart';
import 'package:expense_tracking_app/utils/helper_functions.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LinkSignInMethodsScreen extends StatefulWidget {
  const LinkSignInMethodsScreen({super.key});

  @override
  State<LinkSignInMethodsScreen> createState() => _LinkSignInMethodsScreenState();
}

class _LinkSignInMethodsScreenState extends State<LinkSignInMethodsScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isLoading) return;
    hideKeyBoard();
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      setState(() {});
      AppAlerts.showSuccessMessage(context, 'Sign-in method linked');
    } catch (e) {
      if (!mounted) return;
      AppAlerts.showErrorMessage(context, AuthErrorMessage.from(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkGoogle() => _run(AccountLinkingService.linkGoogleToCurrentUser);

  Future<void> _linkApple() => _run(AccountLinkingService.linkAppleToCurrentUser);

  Future<void> _linkEmailPassword() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;
    await _run(
      () => AccountLinkingService.linkEmailPasswordToCurrentUser(
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hasPassword =
        AccountLinkingService.isProviderLinked(user, 'password');
    final hasGoogle =
        AccountLinkingService.isProviderLinked(user, 'google.com');
    final hasApple = AccountLinkingService.isProviderLinked(user, 'apple.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link sign-in methods'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Use one account with multiple ways to sign in. Your expenses stay under ${user?.email ?? 'this email'}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Linked methods',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _LinkedMethodTile(
                        icon: Icons.email_outlined,
                        label: 'Email & password',
                        linked: hasPassword,
                      ),
                      const Divider(height: 1),
                      _LinkedMethodTile(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        linked: hasGoogle,
                      ),
                      if (Platform.isIOS) ...[
                        const Divider(height: 1),
                        _LinkedMethodTile(
                          icon: Icons.apple,
                          label: 'Apple',
                          linked: hasApple,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add a method',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                if (!hasGoogle)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.g_mobiledata),
                      title: const Text('Link Google'),
                      subtitle: const Text(
                        'Sign in with Google using the same email',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _linkGoogle,
                    ),
                  ),
                if (Platform.isIOS && !hasApple) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.apple),
                      title: const Text('Link Apple'),
                      subtitle: const Text(
                        'Sign in with Apple using the same email',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _linkApple,
                    ),
                  ),
                ],
                if (!hasPassword) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Add email password',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        MyInputField(
                          controller: _passwordController,
                          hintText: 'New password',
                          isPassword: true,
                          validator: (value) =>
                              AppFormFieldValidator.minLengthValidator(
                            value,
                            8,
                            'Password must be at least 8 characters',
                          ),
                        ),
                        const SizedBox(height: 12),
                        MyInputField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          isPassword: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _linkEmailPassword,
                            child: const Text('Link email & password'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (hasPassword && hasGoogle && (!Platform.isIOS || hasApple))
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'All available sign-in methods are linked.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _LinkedMethodTile extends StatelessWidget {
  const _LinkedMethodTile({
    required this.icon,
    required this.label,
    required this.linked,
  });

  final IconData icon;
  final String label;
  final bool linked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: linked
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : Text(
              'Not linked',
              style: Theme.of(context).textTheme.bodySmall,
            ),
    );
  }
}
