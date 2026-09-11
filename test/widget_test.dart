import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurokey/main.dart';
import 'package:neurokey/features/auth/presentation/providers/auth_session_provider.dart';

class _FakeAuthSessionNotifier extends StateNotifier<AuthSessionState>
    implements AuthSessionNotifier {
  _FakeAuthSessionNotifier()
      : super(const AuthSessionState(
          isInitialized: true,
          isAuthenticated: false,
          hasMasterKey: false,
          isBiometricsAvailable: false,
        ));

  @override
  Future<bool> setupMasterPassword(String password) async => false;
  @override
  Future<bool> unlockWithMasterPassword(String password) async => false;
  @override
  Future<bool> unlockWithBiometrics() async => false;
  @override
  void lockVault() {}
  @override
  Future<void> wipeAllData() async {}
  @override
  Future<void> checkStatus() async {}
}

void main() {
  testWidgets('NeuroKey app smoke test — renders login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith((_) => _FakeAuthSessionNotifier()),
        ],
        child: const NeuroKeyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // AuthGate should redirect to LoginSignUpScreen since isAuthenticated=false
    expect(find.byType(MaterialApp), findsOneWidget);

    // NeuroKey wordmark should be on screen
    expect(find.textContaining('NeuroKey'), findsWidgets);

    // Tagline should appear
    expect(find.textContaining('secured'), findsWidgets);

    // Login / Sign Up mode toggle should be present
    expect(find.text('Log In'), findsWidgets);
    expect(find.text('Sign Up'), findsWidgets);
  });
}
