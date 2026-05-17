import 'package:expense_tracking_app/services/biometric_auth_service.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:flutter/material.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final _biometricService = BiometricAuthService();

  bool _unlocked = false;
  bool _isAuthenticating = false;
  String _biometricLabel = 'Biometrics';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (!MyPref.isBiometricLockEnabled()) {
      if (mounted) setState(() => _unlocked = true);
      return;
    }

    _biometricLabel = await _biometricService.primaryBiometricLabel();
    await _unlock();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        MyPref.isBiometricLockEnabled() &&
        _unlocked) {
      setState(() => _unlocked = false);
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_isAuthenticating || !mounted) return;

    setState(() => _isAuthenticating = true);

    final success = await _biometricService.authenticate(
      reason: 'Unlock Expense Tracker to view your financial data',
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _unlocked = success;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked || !MyPref.isBiometricLockEnabled()) {
      return widget.child;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'App locked',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use $_biometricLabel to access your expenses and budgets.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isAuthenticating ? null : _unlock,
                  icon: _isAuthenticating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(
                    _isAuthenticating ? 'Verifying...' : 'Unlock',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
