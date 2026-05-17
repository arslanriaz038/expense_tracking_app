import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/views/change_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSecurityTile extends StatelessWidget {
  const AccountSecurityTile({super.key});

  void _showSocialPasswordInfo(BuildContext context, User? user) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Signed in with ${AuthSessionService.signInMethodLabel(user)}'),
        content: Text(AuthSessionService.socialPasswordManagementMessage(user)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final usesEmail = AuthSessionService.usesEmailPassword(user);
    final methodLabel = AuthSessionService.signInMethodLabel(user);

    if (usesEmail) {
      return ListTile(
        leading: const Icon(Icons.lock_outline),
        title: const Text('Change password'),
        subtitle: const Text('Update your email account password'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ChangePasswordScreen(),
            ),
          );
        },
      );
    }

    return ListTile(
      leading: const Icon(Icons.shield_outlined),
      title: const Text('Sign-in & password'),
      subtitle: Text('Signed in with $methodLabel · managed outside this app'),
      trailing: const Icon(Icons.info_outline),
      onTap: () => _showSocialPasswordInfo(context, user),
    );
  }
}
