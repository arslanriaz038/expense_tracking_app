import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthResult {
  const BiometricAuthResult._({
    required this.success,
    this.userCanceled = false,
    this.errorMessage,
  });

  const BiometricAuthResult.success()
      : this._(success: true);

  const BiometricAuthResult.canceled()
      : this._(success: false, userCanceled: true);

  const BiometricAuthResult.failed(String message)
      : this._(success: false, errorMessage: message);

  final bool success;
  final bool userCanceled;
  final String? errorMessage;
}

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Device can show system auth (biometrics and/or device PIN).
  Future<bool> canUseAppLock() => _auth.isDeviceSupported();

  Future<bool> hasEnrolledBiometrics() async {
    if (!await canUseAppLock()) return false;
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
    return 'device passcode';
  }

  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: false,
        sensitiveTransaction: false,
      );

      if (success) {
        return const BiometricAuthResult.success();
      }
      return const BiometricAuthResult.canceled();
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.userCanceled ||
          e.code == LocalAuthExceptionCode.systemCanceled) {
        return const BiometricAuthResult.canceled();
      }

      final message = e.description?.isNotEmpty == true
          ? e.description!
          : _messageForCode(e.code);

      return BiometricAuthResult.failed(message);
    } on PlatformException catch (e) {
      return BiometricAuthResult.failed(
        e.message ?? 'Biometric authentication is not available.',
      );
    }
  }

  String _messageForCode(LocalAuthExceptionCode code) {
    return switch (code) {
      LocalAuthExceptionCode.noBiometricHardware =>
        'This device has no biometric hardware.',
      LocalAuthExceptionCode.noBiometricsEnrolled =>
        'Set up fingerprint or Face ID in device settings, or use your passcode when prompted.',
      LocalAuthExceptionCode.biometricLockout ||
      LocalAuthExceptionCode.temporaryLockout =>
        'Too many attempts. Try again later or use your device passcode.',
      _ => 'Could not verify your identity. Please try again.',
    };
  }
}
