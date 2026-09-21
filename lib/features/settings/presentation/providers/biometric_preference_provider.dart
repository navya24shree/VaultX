import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vaultx/core/crypto/biometric_auth_service.dart';

/// Persists the user's preference for biometric unlock.
///
/// Stored in the hardware-backed secure enclave alongside other crypto keys.
/// When the user enables biometrics, a fingerprint/biometric scan is required to confirm.
class BiometricPreferenceNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;
  final BiometricAuthService _biometricAuth;

  static const _key = 'vaultx_biometric_enabled';

  BiometricPreferenceNotifier({
    FlutterSecureStorage? storage,
    BiometricAuthService? biometricAuth,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _biometricAuth = biometricAuth ?? BiometricAuthService(),
        super(false) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      // Read the stored preference directly — do NOT gate it on isBiometricAvailable().
      // The availability check is transient (especially on MIUI/Android 14 cold starts)
      // and was silently resetting a saved 'true' preference to false every relaunch.
      // UI interactability is already gated via authState.isBiometricsAvailable in the
      // settings screen and login screen, so no duplicate guard is needed here.
      final raw = await _storage.read(key: _key);
      state = raw == 'true';
    } catch (_) {
      state = false;
    }
  }

  /// Prompts for fingerprint and enables biometric unlock if verified.
  Future<bool> enableWithBiometrics({
    String reason = 'Scan your fingerprint to enable biometric unlock',
  }) async {
    try {
      final isAvailable = await _biometricAuth.isBiometricAvailable();
      if (!isAvailable) {
        debugPrint('Cannot enable biometrics: device does not support or has no enrolled biometrics');
        return false;
      }

      final authenticated = await _biometricAuth.authenticate(
        localizedReason: reason,
      );

      if (authenticated) {
        await _storage.write(key: _key, value: 'true');
        state = true;
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error enabling biometrics: $e');
      return false;
    }
  }

  /// Disables biometric unlock.
  Future<void> disable() async {
    try {
      await _storage.write(key: _key, value: 'false');
      state = false;
    } catch (_) {}
  }

  /// Toggles biometric preference. If [value] is true, prompts fingerprint authentication.
  Future<bool> setEnabled(bool value) async {
    if (value) {
      return await enableWithBiometrics();
    } else {
      await disable();
      return true;
    }
  }
}

final biometricPreferenceProvider =
    StateNotifierProvider<BiometricPreferenceNotifier, bool>((ref) {
  return BiometricPreferenceNotifier();
});
