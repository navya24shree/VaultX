import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neurokey/core/theme/app_theme.dart';
import 'package:neurokey/core/widgets/vertical_ruler_slider.dart';

/// Screen 5: Password Generator Screen
///
/// Features monospace password display, entropy evaluation gauge, 1-tap copy,
/// 4 character set toggles, and tactile vertical ladder length slider.
class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  int _length = 16;
  bool _useUpper = true;
  bool _useLower = true;
  bool _useNumbers = true;
  bool _useSymbols = true;

  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  void _regenerate() {
    final upper = _useUpper ? 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' : '';
    final lower = _useLower ? 'abcdefghijklmnopqrstuvwxyz' : '';
    final numbers = _useNumbers ? '0123456789' : '';
    final symbols = _useSymbols ? '!@#\$%^&*()_+-=[]{}|;:,.<>?' : '';

    final pool = '$upper$lower$numbers$symbols';
    if (pool.isEmpty) {
      setState(() => _generatedPassword = '');
      return;
    }

    final random = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < _length; i++) {
      buffer.write(pool[random.nextInt(pool.length)]);
    }

    setState(() {
      _generatedPassword = buffer.toString();
    });
  }

  String get _strengthLabel {
    if (_length < 10 || (!_useSymbols && !_useNumbers)) {
      return 'Weak';
    } else if (_length < 14 || !_useSymbols) {
      return 'Medium';
    } else {
      return 'Strong';
    }
  }

  Color get _strengthColor {
    switch (_strengthLabel) {
      case 'Weak':
        return AppColors.rose500;
      case 'Medium':
        return AppColors.amber500;
      default:
        return AppColors.emerald500;
    }
  }

  void _copyToClipboard() {
    if (_generatedPassword.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.emerald500,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Password copied to clipboard!'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final inputBg = isDark ? AppColors.darkInputSurface : AppColors.lightInputSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Generator',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Generated Password Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: borderCol, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 60 : 15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Monospace Password
                      SelectableText(
                        _generatedPassword,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Entropy Strength Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _strengthColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _strengthColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Actions: Regenerate & Copy
                      Row(
                        children: [
                          IconButton.filled(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _regenerate();
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: inputBg,
                              foregroundColor: AppColors.primaryBlue,
                              minimumSize: const Size(54, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                                side: BorderSide(color: borderCol),
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 24),
                            tooltip: 'Regenerate',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _copyToClipboard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(44, 54),
                                shape: const StadiumBorder(),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 20),
                              label: const Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Options Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Options',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'LENGTH: ',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dual Options Section (Toggles on Left, Vertical Ruler on Right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggles Column
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: borderCol),
                        ),
                        child: Column(
                          children: [
                            _ToggleTile(
                              title: 'Uppercase',
                              subtitle: 'A-Z',
                              value: _useUpper,
                              onChanged: (val) {
                                setState(() => _useUpper = val);
                                _regenerate();
                              },
                            ),
                            Divider(height: 1, color: borderCol),
                            _ToggleTile(
                              title: 'Lowercase',
                              subtitle: 'a-z',
                              value: _useLower,
                              onChanged: (val) {
                                setState(() => _useLower = val);
                                _regenerate();
                              },
                            ),
                            Divider(height: 1, color: borderCol),
                            _ToggleTile(
                              title: 'Numbers',
                              subtitle: '0-9',
                              value: _useNumbers,
                              onChanged: (val) {
                                setState(() => _useNumbers = val);
                                _regenerate();
                              },
                            ),
                            Divider(height: 1, color: borderCol),
                            _ToggleTile(
                              title: 'Symbols',
                              subtitle: '!@#\$%^&*',
                              value: _useSymbols,
                              onChanged: (val) {
                                setState(() => _useSymbols = val);
                                _regenerate();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Vertical Ruler Ladder Slider
                    VerticalRulerSlider(
                      value: _length,
                      min: 8,
                      max: 32,
                      onChanged: (val) {
                        setState(() => _length = val);
                        _regenerate();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primaryBlue,
            activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
