import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Configuration parameters for Argon2id Key Derivation Function.
class KdfParameters {
  /// Memory size in KiB (e.g., 64 * 1024 = 65536 KiB = 64 MB).
  final int memory;

  /// Number of iterations / passes.
  final int iterations;

  /// Degree of parallelism / number of threads.
  final int parallelism;

  /// Output key length in bytes (32 bytes = 256 bits).
  final int hashLength;

  const KdfParameters({
    this.memory = 64 * 1024,
    this.iterations = 3,
    this.parallelism = 1,
    this.hashLength = 32,
  });

  /// Recommended production parameters complying with OWASP.
  static const KdfParameters owasp = KdfParameters();

  /// Lightweight parameters intended for fast unit testing.
  static const KdfParameters testProfile = KdfParameters(
    memory: 1024,
    iterations: 1,
    parallelism: 1,
    hashLength: 32,
  );
}

/// Service implementing Argon2id key derivation from a master password.
class KdfService {
  final KdfParameters defaultParams;

  const KdfService({this.defaultParams = KdfParameters.owasp});

  /// Generates a cryptographically secure random salt of [length] bytes (default 16 bytes = 128 bits).
  List<int> generateSalt([int length = 16]) {
    if (length < 16) {
      throw ArgumentError.value(length, 'length', 'Salt must be at least 16 bytes.');
    }
    final secureRandom = Random.secure();
    return List<int>.generate(length, (_) => secureRandom.nextInt(256));
  }

  /// Derives a 256-bit (32-byte) master key from [masterPassword] and [salt] using Argon2id.
  Future<List<int>> deriveMasterKey({
    required String masterPassword,
    required List<int> salt,
    KdfParameters? params,
  }) async {
    if (masterPassword.isEmpty) {
      throw ArgumentError('Master password cannot be empty.');
    }
    if (salt.length < 16) {
      throw ArgumentError('Salt must be at least 16 bytes (128 bits).');
    }

    final effectiveParams = params ?? defaultParams;

    final argon2id = Argon2id(
      memory: effectiveParams.memory,
      iterations: effectiveParams.iterations,
      parallelism: effectiveParams.parallelism,
      hashLength: effectiveParams.hashLength,
    );

    final passwordBytes = utf8.encode(masterPassword);
    final secretKey = SecretKey(passwordBytes);

    final derivedKey = await argon2id.deriveKey(
      secretKey: secretKey,
      nonce: salt,
    );

    return derivedKey.extractBytes();
  }
}
