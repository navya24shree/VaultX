import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/floating_nav_dock.dart';
import 'features/auth/presentation/login_sign_up_screen.dart';
import 'features/auth/presentation/providers/auth_session_provider.dart';
import 'features/vault/presentation/passwords_vault_screen.dart';
import 'features/vault/presentation/password_generator_screen.dart';
import 'features/wallet/presentation/digital_wallet_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/providers/auto_lock_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VaultXApp()));
}

class VaultXApp extends ConsumerWidget {
  const VaultXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'VaultX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppLifecycleLockHandler(child: AuthGate()),
    );
  }
}

/// Backwards compatibility alias
typedef NeuroKeyApp = VaultXApp;

/// Listens for app background/close lifecycle events and triggers auto-lock
/// when elapsed time exceeds the configured AutoLockDuration.
class AppLifecycleLockHandler extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleLockHandler({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleLockHandler> createState() => _AppLifecycleLockHandlerState();
}

class _AppLifecycleLockHandlerState extends ConsumerState<AppLifecycleLockHandler>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pausedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final elapsed = DateTime.now().difference(_pausedAt!);
        final lockDuration = ref.read(autoLockProvider).duration;
        if (elapsed >= lockDuration) {
          ref.read(authSessionProvider.notifier).lockVault();
        }
        _pausedAt = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authSessionProvider);

    if (!authState.isAuthenticated) {
      return const LoginSignUpScreen();
    }

    return const MainAppShell();
  }
}

class MainAppShell extends StatefulWidget {
  final NavTab initialTab;

  const MainAppShell({super.key, this.initialTab = NavTab.passwords});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  late NavTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const PasswordsVaultScreen(),
      const DigitalWalletScreen(),
      const PasswordGeneratorScreen(),
      const SettingsScreen(),
    ];

    final activeIndex = NavTab.values.indexOf(_currentTab);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: activeIndex,
            children: screens,
          ),
          FloatingNavDock(
            currentTab: _currentTab,
            onTabSelected: (tab) {
              setState(() => _currentTab = tab);
            },
          ),
        ],
      ),
    );
  }
}
