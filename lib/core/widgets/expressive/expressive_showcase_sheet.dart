import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/app_theme.dart';
import 'package:vaultx/core/widgets/expressive/expressive.dart';

/// Modal bottom sheet showcasing Material 3 Expressive components:
/// - Expressive Buttons (Filled, Tonal, Elevated, Outlined, Text, Segmented)
/// - Expressive Motion Sliders (Dynamic track expansion, spring balloon indicator, vertical ladder, swipe-to-action)
/// - Expressive Icons (Squircle buttons, spring twist micro-interactions, animated toggle morphs, tonal containers)
class ExpressiveShowcaseSheet extends StatefulWidget {
  const ExpressiveShowcaseSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExpressiveShowcaseSheet(),
    );
  }

  @override
  State<ExpressiveShowcaseSheet> createState() => _ExpressiveShowcaseSheetState();
}

class _ExpressiveShowcaseSheetState extends State<ExpressiveShowcaseSheet> {
  // Slider states
  double _horizontalSliderValue = 16.0;
  double _percentSliderValue = 65.0;
  int _verticalSliderValue = 18;
  String _selectedSegment = 'Passwords';
  bool _isPasswordVisible = false;
  bool _isCardLocked = false;
  bool _isFavorite = true;
  bool _isButtonLoading = false;
  String _actionFeedback = 'Tap or drag any component to experience M3 Expressive physics';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderCol, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const ExpressiveIconContainer(
                      icon: Icon(Icons.auto_awesome_rounded),
                      color: AppColors.primaryBlue,
                      size: 42,
                      borderRadius: 14,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Material 3 Expressive',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tactile Motion Sliders • Buttons • Icons',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Live Feedback Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark ? AppColors.darkInputSurface : AppColors.lightInputSurface,
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _actionFeedback,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Content List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // SECTION 1: MOTION SLIDERS
                    _buildSectionHeader(
                      title: 'Material 3 Expressive Motion Sliders',
                      description:
                          'Thick track dynamically expands on touch, morphing thumb with spring stretch, and floating balloon value indicators.',
                    ),
                    const SizedBox(height: 12),

                    // Slider Demo Container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderCol, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Discrete Motion Slider (8-32 Chars)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withAlpha(35),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_horizontalSliderValue.round()} chars',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlue,
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ExpressiveMotionSlider(
                            value: _horizontalSliderValue,
                            min: 8,
                            max: 32,
                            divisions: 24,
                            valueFormatter: (val) => '${val.round()} chars',
                            onChanged: (val) {
                              setState(() {
                                _horizontalSliderValue = val;
                                _actionFeedback = 'Slider set to ${val.round()} characters';
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Continuous Motion Slider (Percentage)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_percentSliderValue.round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandPurple,
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ExpressiveMotionSlider(
                            value: _percentSliderValue,
                            min: 0,
                            max: 100,
                            activeColor: AppColors.brandPurple,
                            valueFormatter: (val) => '${val.round()}%',
                            onChanged: (val) {
                              setState(() {
                                _percentSliderValue = val;
                                _actionFeedback = 'Continuous slider at ${val.round()}%';
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Tactile Ladder & Swipe-to-Action Sliders',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vertical motion slider
                              ExpressiveVerticalMotionSlider(
                                value: _verticalSliderValue,
                                min: 8,
                                max: 32,
                                height: 160,
                                onChanged: (val) {
                                  setState(() {
                                    _verticalSliderValue = val;
                                    _actionFeedback = 'Vertical ladder slider: $val characters';
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              // Swipe slider & detail
                              Expanded(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      'Swipe right to trigger with spring momentum and haptic confirmation:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ExpressiveSwipeSlider(
                                      label: 'Swipe to Generate',
                                      onTrigger: () {
                                        setState(() {
                                          _actionFeedback = '🎉 Swipe-to-action triggered successfully!';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // SECTION 2: EXPRESSIVE BUTTONS
                    _buildSectionHeader(
                      title: 'Material 3 Expressive Buttons',
                      description:
                          'Tactile spring press down (scale 0.96) with snappy bounce on release. Full variant system with shape morphs.',
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderCol, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Segmented Button
                          const Text(
                            'Expressive Segmented Pill Button',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          ExpressiveSegmentedButton<String>(
                            items: const ['Passwords', 'Cards', 'Keys'],
                            selectedItem: _selectedSegment,
                            onSelected: (val) {
                              setState(() {
                                _selectedSegment = val;
                                _actionFeedback = 'Selected segmented filter: $val';
                              });
                            },
                            itemBuilder: (context, item, isSelected) {
                              return Text(
                                item,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? Colors.white : AppColors.primaryBlue)
                                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Primary Filled & Tonal
                          Row(
                            children: [
                              Expanded(
                                child: ExpressiveButton.filled(
                                  label: 'Filled Primary',
                                  icon: const Icon(Icons.check_circle_outline_rounded),
                                  onPressed: () {
                                    setState(() => _actionFeedback = 'Filled Primary Button pressed');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ExpressiveButton.tonal(
                                  label: 'Filled Tonal',
                                  icon: const Icon(Icons.bolt_rounded),
                                  onPressed: () {
                                    setState(() => _actionFeedback = 'Filled Tonal Button pressed');
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Elevated & Outlined
                          Row(
                            children: [
                              Expanded(
                                child: ExpressiveButton.elevated(
                                  label: 'Elevated Surface',
                                  icon: const Icon(Icons.layers_outlined),
                                  onPressed: () {
                                    setState(() => _actionFeedback = 'Elevated Button pressed');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ExpressiveButton.outlined(
                                  label: 'Outlined Action',
                                  icon: const Icon(Icons.tune_rounded),
                                  onPressed: () {
                                    setState(() => _actionFeedback = 'Outlined Button pressed');
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Full-width Large Action with Loading Demo
                          ExpressiveButton(
                            isFullWidth: true,
                            size: ExpressiveButtonSize.large,
                            label: _isButtonLoading ? null : 'Large Morphing Button (Tap for Loading)',
                            icon: const Icon(Icons.fingerprint_rounded),
                            isLoading: _isButtonLoading,
                            customColor: AppColors.emerald500,
                            onPressed: () {
                              setState(() {
                                _isButtonLoading = true;
                                _actionFeedback = 'Button entering loading state...';
                              });
                              Future.delayed(const Duration(milliseconds: 1500), () {
                                if (mounted) {
                                  setState(() {
                                    _isButtonLoading = false;
                                    _actionFeedback = 'Action completed with spring return!';
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // SECTION 3: EXPRESSIVE ICONS & MICRO-INTERACTIONS
                    _buildSectionHeader(
                      title: 'Material 3 Expressive Icons',
                      description:
                          'Squircle icon containers with spring twist micro-interactions and smooth animated state toggle transitions.',
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderCol, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expressive Icon Buttons (Squircle & Circle)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ExpressiveIconButton.filled(
                                icon: const Icon(Icons.refresh_rounded),
                                tooltip: 'Filled Squircle',
                                enableSpringRotation: true,
                                onPressed: () {
                                  setState(() => _actionFeedback = 'Filled Squircle Icon tapped (with spring twist!)');
                                },
                              ),
                              ExpressiveIconButton.tonal(
                                icon: const Icon(Icons.copy_rounded),
                                tooltip: 'Tonal Squircle',
                                enableSpringRotation: true,
                                onPressed: () {
                                  setState(() => _actionFeedback = 'Tonal Squircle Icon tapped');
                                },
                              ),
                              ExpressiveIconButton.outlined(
                                icon: const Icon(Icons.share_rounded),
                                tooltip: 'Outlined Squircle',
                                onPressed: () {
                                  setState(() => _actionFeedback = 'Outlined Squircle Icon tapped');
                                },
                              ),
                              ExpressiveIconButton(
                                icon: const Icon(Icons.more_vert_rounded),
                                tooltip: 'Standard Icon',
                                onPressed: () {
                                  setState(() => _actionFeedback = 'Standard Expressive Icon tapped');
                                },
                              ),
                              ExpressiveIconButton.filled(
                                isCircle: true,
                                customColor: AppColors.brandPurple,
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                tooltip: 'Circle Variant',
                                onPressed: () {
                                  setState(() => _actionFeedback = 'Circle Expressive Icon tapped');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Animated State Toggle Morphs',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Visibility toggle
                              Column(
                                children: [
                                  ExpressiveToggleIcon(
                                    isToggled: _isPasswordVisible,
                                    firstIcon: Icons.visibility_off_rounded,
                                    secondIcon: Icons.visibility_rounded,
                                    activeColor: AppColors.primaryBlue,
                                    size: 26,
                                    onToggle: (val) {
                                      setState(() {
                                        _isPasswordVisible = val;
                                        _actionFeedback = 'Password visibility toggled to $val';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Visibility',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),

                              // Lock toggle
                              Column(
                                children: [
                                  ExpressiveToggleIcon(
                                    isToggled: _isCardLocked,
                                    firstIcon: Icons.lock_open_rounded,
                                    secondIcon: Icons.lock_rounded,
                                    activeColor: AppColors.rose500,
                                    size: 26,
                                    onToggle: (val) {
                                      setState(() {
                                        _isCardLocked = val;
                                        _actionFeedback = 'Lock status toggled to $val';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Vault Lock',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),

                              // Favorite star toggle
                              Column(
                                children: [
                                  ExpressiveToggleIcon(
                                    isToggled: _isFavorite,
                                    firstIcon: Icons.star_border_rounded,
                                    secondIcon: Icons.star_rounded,
                                    activeColor: AppColors.amber500,
                                    size: 26,
                                    onToggle: (val) {
                                      setState(() {
                                        _isFavorite = val;
                                        _actionFeedback = 'Favorite toggled to $val';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Favorite',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
