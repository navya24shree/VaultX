import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurokey/core/crypto/kdf_service.dart';
import 'package:neurokey/core/crypto/biometric_auth_service.dart';
import 'package:neurokey/core/crypto/lockout_policy.dart';
import 'package:neurokey/core/storage/secure_key_storage.dart';

class AuthSessionState {
  final bool isInitialized;
  final bool isAuthenticated;
  final bool hasMasterKey;
  final bool isBiometricsAvailable;
  final bool isBiometricsEnabled;
  final String? errorMessage;
  final List<int>? activeMasterKey;

  const AuthSessionState({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.hasMasterKey = false,
    this.isBiometricsAvailable = false,
    this.isBiometricsEnabled = true,
    this.errorMessage,
    this.activeMasterKey,
  });

  AuthSessionState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    bool? hasMasterKey,
    bool? isBiometricsAvailable,
    bool? isBiometricsEnabled,
    String? errorMessage,
    bool clearError = false,
    List<int>? activeMasterKey,
    bool clearKey = false,
  }) {
    return AuthSessionState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasMasterKey: hasMasterKey ?? this.hasMasterKey,
      isBiometricsAvailable: isBiometricsAvailable ?? this.isBiometricsAvailable,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeMasterKey: clearKey ? null : (activeMasterKey ?? this.activeMasterKey),
    );
  }
}

class AuthSessionNotifier extends StateNotifier<AuthSessionState> {
  final SecureKeyStorage _secureStorage;
  final KdfService _kdfService;
  final BiometricAuthService _biometricAuth;
  final AuthLockoutPolicy _lockoutPolicy;

  AuthSessionNotifier({
    SecureKeyStorage? secureStorage,
    KdfService? kdfService,
    BiometricAuthService? biometricAuth,
    AuthLockoutPolicy? lockoutPolicy,
  })  : _secureStorage = secureStorage ?? SecureKeyStorage(),
        _kdfService = kdfService ?? const KdfService(),
        _biometricAuth = biometricAuth ?? BiometricAuthService(),
        _lockoutPolicy = lockoutPolicy ?? AuthLockoutPolicy(),
        super(const AuthSessionState()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final hasKey = await _secureStorage.hasMasterKey();
    final canBio = await _biometricAuth.isBiometricAvailable();
    state = state.copyWith(
      isInitialized: true,
      hasMasterKey: hasKey,
      isBiometricsAvailable: canBio,
    );
  }

  Future<bool> setupMasterPassword(String password) async {
    if (password.length < 8) {
      state = state.copyWith(errorMessage: 'Password must be at least 8 characters.');
      return false;
    }
    try {
      final salt = _kdfService.generateSalt();
      final masterKey = await _kdfService.deriveMasterKey(
        masterPassword: password,
        salt: salt,
      );
      await _secureStorage.storeInstallSalt(salt);
      await _secureStorage.storeMasterKey(masterKey);
      await _lockoutPolicy.recordSuccessfulAuth();

      state = state.copyWith(
        isAuthenticated: true,
        hasMasterKey: true,
        activeMasterKey: masterKey,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to initialize vault: $e');
      return false;
    }
  }

  Future<bool> unlockWithMasterPassword(String password) async {
    final status = await _lockoutPolicy.getStatus();
    if (status.isLockedOut) {
      state = state.copyWith(
        errorMessage: 'Vault locked. Please wait ${status.remainingLockout.inSeconds} seconds.',
      );
      return false;
    }

    try {
      final salt = await _secureStorage.getInstallSalt();
      final storedKey = await _secureStorage.getMasterKey();

      if (salt == null || storedKey == null) {
        // Vault not yet initialized; treat as setup
        return await setupMasterPassword(password);
      }

      final derivedKey = await _kdfService.deriveMasterKey(
        masterPassword: password,
        salt: salt,
      );

      // Constant-time comparison
      bool matches = true;
      if (derivedKey.length != storedKey.length) {
        matches = false;
      } else {
        int diff = 0;
        for (int i = 0; i < derivedKey.length; i++) {
          diff |= derivedKey[i] ^ storedKey[i];
        }
        matches = (diff == 0);
      }

      if (matches) {
        await _lockoutPolicy.recordSuccessfulAuth();
        state = state.copyWith(
          isAuthenticated: true,
          activeMasterKey: derivedKey,
          clearError: true,
        );
        return true;
      } else {
        final newStatus = await _lockoutPolicy.recordFailedAttempt();
        state = state.copyWith(
          errorMessage: 'Incorrect master password. ${newStatus.remainingAttempts} attempts remaining.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Unlock failed: $e');
      return false;
    }
  }

  Future<bool> unlockWithBiometrics() async {
    if (!state.isBiometricsAvailable) {
      state = state.copyWith(errorMessage: 'Biometrics not available on this device.');
      return false;
    }
    try {
      final success = await _biometricAuth.authenticate(
        localizedReason: 'Authenticate to unlock your NeuroKey vault',
      );
      if (success) {
        final storedKey = await _secureStorage.getMasterKey();
        if (storedKey != null) {
          await _lockoutPolicy.recordSuccessfulAuth();
          state = state.copyWith(
            isAuthenticated: true,
            activeMasterKey: storedKey,
            clearError: true,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Biometric authentication failed: $e');
      return false;
    }
  }

  void lockVault() {
    state = state.copyWith(
      isAuthenticated: false,
      clearKey: true,
      clearError: true,
    );
  }

  Future<void> wipeAllData() async {
    await _secureStorage.wipeAllKeys();
    await _lockoutPolicy.reset();
    state = const AuthSessionState(
      isInitialized: true,
      isAuthenticated: false,
      hasMasterKey: false,
    );
  }
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthSessionState>((ref) {
  return AuthSessionNotifier();
});
