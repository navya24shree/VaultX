import 'package:flutter/foundation.dart';
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
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (canCheck) return true;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('BiometricAuthService.isBiometricAvailable PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('BiometricAuthService.isBiometricAvailable error: $e');
      return false;
    }
  }

  /// Returns the list of enrolled biometric types on this device (e.g., face, fingerprint).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('BiometricAuthService.getAvailableBiometrics error: $e');
      return <BiometricType>[];
    }
  }

  /// Prompts the user for biometric authentication (Face ID, Touch ID, Fingerprint).
  ///
  /// Returns `true` if authentication succeeded, `false` otherwise.
  Future<bool> authenticate({
    String localizedReason = 'Scan your fingerprint to authenticate',
    bool biometricOnly = false,
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        debugPrint('BiometricAuthService: biometrics not available on device.');
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
    } on PlatformException catch (e) {
      debugPrint('BiometricAuthService.authenticate PlatformException: [${e.code}] ${e.message}');
      return false;
    } catch (e) {
      debugPrint('BiometricAuthService.authenticate error: $e');
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
