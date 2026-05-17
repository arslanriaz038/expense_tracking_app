import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isDeviceSupported() => _auth.isDeviceSupported();

  Future<bool> canUseBiometrics() async {
    if (!await isDeviceSupported()) return false;
    final canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;
    final available = await _auth.getAvailableBiometrics();
    return available.isNotEmpty;
  }

  Future<String> primaryBiometricLabel() async {
    final types = await _auth.getAvailableBiometrics();
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    }
    if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    if (types.contains(BiometricType.strong) ||
        types.contains(BiometricType.weak)) {
      return 'Biometrics';
    }
    return 'Device passcode';
  }

  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
