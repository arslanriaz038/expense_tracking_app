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
    final supported = await _biometricService.canUseBiometrics();
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
          'Biometrics are not available on this device.',
        );
        return;
      }

      final confirmed = await _biometricService.authenticate(
        reason: 'Confirm your identity to enable app lock',
        biometricOnly: false,
      );

      if (!confirmed) {
        AppAlerts.showInfoMessage(context, 'App lock was not enabled.');
        return;
      }

      await MyPref.setBiometricLockEnabled(true);
    } else {
      await MyPref.setBiometricLockEnabled(false);
    }

    if (mounted) {
      setState(() => _enabled = value);
      AppAlerts.showSuccessMessage(
        context,
        value ? 'App lock enabled' : 'App lock disabled',
      );
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
                : 'Biometrics not available on this device',
      ),
      value: _enabled,
      onChanged: _isLoading || !_deviceSupported ? null : _onChanged,
    );
  }
}
