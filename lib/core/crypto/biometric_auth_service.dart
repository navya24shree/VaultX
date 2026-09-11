import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric gate guarding access to the derived master key in secure enclave.
class BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Determines if the device hardware supports biometrics and has enrolled biometrics.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types on this device (e.g., face, fingerprint).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Prompts the user for biometric authentication (Face ID, Touch ID, Fingerprint).
  ///
  /// Returns `true` if authentication succeeded, `false` otherwise.
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to unlock your NeuroKey vault',
    bool biometricOnly = true,
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Cancels any ongoing biometric authentication session.
  Future<bool> stopAuthentication() async {
    try {
      return await _auth.stopAuthentication();
    } on PlatformException {
      return false;
    }
  }
}
