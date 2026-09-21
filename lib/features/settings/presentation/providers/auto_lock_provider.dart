import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Available auto-lock durations after the app is closed or backgrounded.
enum AutoLockDuration {
  sec30('30sec', '30 Seconds', Duration(seconds: 30)),
  min1('1min', '1 Minute', Duration(minutes: 1)),
  min2('2min', '2 Minutes', Duration(minutes: 2)),
  min3('3min', '3 Minutes', Duration(minutes: 3)),
  min4('4min', '4 Minutes', Duration(minutes: 4)),
  min5('5min', '5 Minutes', Duration(minutes: 5));

  final String id;
  final String label;
  final Duration duration;

  const AutoLockDuration(this.id, this.label, this.duration);

  static AutoLockDuration fromId(String? id) {
    return AutoLockDuration.values.firstWhere(
      (element) => element.id == id,
      orElse: () => AutoLockDuration.min5,
    );
  }
}

/// Manages and persists the user's preferred auto-lock timeout.
class AutoLockNotifier extends StateNotifier<AutoLockDuration> {
  final FlutterSecureStorage _storage;
  static const _storageKey = 'vaultx_auto_lock_duration';

  AutoLockNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(AutoLockDuration.min5) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final savedId = await _storage.read(key: _storageKey);
      if (savedId != null) {
        state = AutoLockDuration.fromId(savedId);
      }
    } catch (_) {
      // Fallback gracefully to default
    }
  }

  Future<void> setDuration(AutoLockDuration duration) async {
    state = duration;
    try {
      await _storage.write(key: _storageKey, value: duration.id);
    } catch (_) {
      // Non-critical persistence failure
    }
  }
}

final autoLockProvider =
    StateNotifierProvider<AutoLockNotifier, AutoLockDuration>((ref) {
  return AutoLockNotifier();
});
