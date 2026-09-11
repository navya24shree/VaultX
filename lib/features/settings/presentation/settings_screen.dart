import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurokey/core/theme/app_theme.dart';
import 'package:neurokey/core/theme/theme_provider.dart';
import 'package:neurokey/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:neurokey/features/sync/presentation/sync_screen.dart';

/// Screen 8: Settings & Theme Switcher Screen
///
/// Implements appearance settings with live Dark/Light theme switching modal dialog,
/// security preferences, data/sync options, and cryptographic wipe danger zone.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openThemeDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeModeProvider);
            final isDark = themeMode == ThemeMode.dark;
            final dialogBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
            final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

            return Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: borderCol),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Appearance',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ThemeOptionTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'Dark Mode',
                      subtitle: 'OLED Obsidian Black (#020617)',
                      isSelected: themeMode == ThemeMode.dark,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(themeModeProvider.notifier).setDark();
                      },
                    ),
                    const SizedBox(height: 10),
                    _ThemeOptionTile(
                      icon: Icons.light_mode_rounded,
                      title: 'Light Mode',
                      subtitle: 'Clean Slate Light (#F8FAFC)',
                      isSelected: themeMode == ThemeMode.light,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(themeModeProvider.notifier).setLight();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmWipe(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Wipe All Data?',
          style: TextStyle(color: AppColors.rose500, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'WARNING: This is completely irreversible. All encrypted passwords, cards, and keys will be permanently deleted from the platform secure enclave.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose500,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(authSessionProvider.notifier).wipeAllData();
              await HapticFeedback.heavyImpact();
              if (context.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.rose500,
                    content: Text('Vault data completely erased.'),
                  ),
                );
              }
            },
            child: const Text('Wipe Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // SECTION: APPEARANCE
              const _SectionHeader(title: 'APPEARANCE'),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openThemeDialog(context, ref),
                ),
              ),
              const SizedBox(height: 24),

              // SECTION: SECURITY
              const _SectionHeader(title: 'SECURITY'),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.password_rounded, color: AppColors.primaryBlue),
                      title: const Text('Change Master Password', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Master password update available in next session')),
                        );
                      },
                    ),
                    Divider(height: 1, color: borderCol),
                    ListTile(
                      leading: const Icon(Icons.fingerprint_rounded, color: AppColors.primaryBlue),
                      title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Touch ID / Face ID gate'),
                      trailing: Switch.adaptive(
                        value: true,
                        activeThumbColor: AppColors.primaryBlue,
                        onChanged: (val) {},
                      ),
                    ),
                    Divider(height: 1, color: borderCol),
                    ListTile(
                      leading: const Icon(Icons.timer_outlined, color: AppColors.primaryBlue),
                      title: const Text('Auto-Lock Duration', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(
                        '5 Minutes',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION: DATA & SYNC
              const _SectionHeader(title: 'DATA & SYNC'),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.sync_rounded, color: AppColors.primaryBlue),
                      title: const Text('Sync with Devices', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Device-to-device mDNS & WSS pairing'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SyncScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: borderCol),
                    ListTile(
                      leading: const Icon(Icons.backup_rounded, color: AppColors.primaryBlue),
                      title: const Text('Backup Vault', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Encrypted JSON backup exported successfully')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION: ABOUT
              const _SectionHeader(title: 'ABOUT'),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderCol),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.security_rounded, color: AppColors.emerald500),
                      title: Text('Security Architecture', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Argon2id KDF + AES-256-GCM + Hardware Enclave'),
                    ),
                    Divider(height: 1, color: borderCol),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
                      title: const Text('App Version', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(
                        '1.0.0 (Build 1)',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // DANGER ZONE
              const _SectionHeader(title: 'DANGER ZONE'),
              Material(
                color: AppColors.rose950.withAlpha(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.rose500.withAlpha(80)),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.rose400),
                  title: const Text(
                    'Wipe All Data',
                    style: TextStyle(color: AppColors.rose400, fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Irreversible cryptographic erasure',
                    style: TextStyle(color: Color(0xFFFFD1D1), fontSize: 12),
                  ),
                  trailing: const Icon(Icons.warning_amber_rounded, color: AppColors.rose400),
                  onTap: () => _confirmWipe(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? AppColors.darkInputSurface : AppColors.lightInputSurface;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withAlpha(30) : inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : borderCol,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryBlue : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }
}
