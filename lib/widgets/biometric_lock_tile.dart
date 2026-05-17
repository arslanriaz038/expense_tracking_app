import 'package:expense_tracking_app/services/biometric_auth_service.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:flutter/material.dart';

class BiometricLockTile extends StatefulWidget {
  const BiometricLockTile({super.key});

  @override
  State<BiometricLockTile> createState() => _BiometricLockTileState();
}

class _BiometricLockTileState extends State<BiometricLockTile> {
  final _biometricService = BiometricAuthService();

  bool _enabled = false;
  bool _isLoading = true;
  bool _deviceSupported = false;
  String _biometricLabel = 'Biometrics';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final supported = await _biometricService.canUseAppLock();
    final label = supported
        ? await _biometricService.primaryBiometricLabel()
        : 'Biometrics';

    if (!mounted) return;

    setState(() {
      _enabled = MyPref.isBiometricLockEnabled();
      _deviceSupported = supported;
      _biometricLabel = label;
      _isLoading = false;
    });
  }

  Future<void> _onChanged(bool value) async {
    if (_isLoading) return;

    if (value) {
      if (!_deviceSupported) {
        AppAlerts.showErrorMessage(
          context,
          'Device authentication is not available.',
        );
        return;
      }

      final result = await _biometricService.authenticate(
        reason: 'Confirm your identity to enable app lock',
        biometricOnly: false,
      );

      if (!mounted) return;

      if (result.success) {
        await MyPref.setBiometricLockEnabled(true);
        setState(() => _enabled = true);
        AppAlerts.showSuccessMessage(context, 'App lock enabled');
        return;
      }

      if (result.userCanceled) {
        AppAlerts.showInfoMessage(
          context,
          'Authentication canceled. App lock was not enabled.',
        );
        return;
      }

      AppAlerts.showErrorMessage(
        context,
        result.errorMessage ?? 'Could not enable app lock.',
      );
      return;
    }

    await MyPref.setBiometricLockEnabled(false);
    if (mounted) {
      setState(() => _enabled = false);
      AppAlerts.showSuccessMessage(context, 'App lock disabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: const Text('App lock'),
      subtitle: Text(
        _isLoading
            ? 'Checking device...'
            : _deviceSupported
                ? 'Require $_biometricLabel when opening the app'
                : 'Device authentication is not available',
      ),
      value: _enabled,
      onChanged: _isLoading || !_deviceSupported ? null : _onChanged,
    );
  }
}
