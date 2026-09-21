import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vaultx/core/theme/app_theme.dart';

/// An interactive swipe-to-generate slider control with spark icon,
/// smooth drag physics, and Apple HIG accessible tap fallback.
class SwipeToCreateSlider extends StatefulWidget {
  final VoidCallback onTrigger;
  final String label;

  const SwipeToCreateSlider({
    super.key,
    required this.onTrigger,
    this.label = 'Swipe to Create Password',
  });

  @override
  State<SwipeToCreateSlider> createState() => _SwipeToCreateSliderState();
}

class _SwipeToCreateSliderState extends State<SwipeToCreateSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppColors.darkInputSurface
        : AppColors.lightInputSurface;
    const thumbColor = AppColors.primaryBlue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - 56.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Centered Label
                  Center(
                    child: Opacity(
                      opacity: (1.0 - (_dragPosition / (maxDrag > 0 ? maxDrag : 1.0)))
                          .clamp(0.2, 1.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Draggable Thumb
                  Positioned(
                    left: _dragPosition,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _dragPosition = (_dragPosition + details.delta.dx)
                              .clamp(0.0, maxDrag);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_dragPosition >= maxDrag * 0.75) {
                          setState(() {
                            _dragPosition = maxDrag;
                            _isCompleted = true;
                          });
                          HapticFeedback.mediumImpact();
                          widget.onTrigger();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _dragPosition = 0.0;
                                _isCompleted = false;
                              });
                            }
                          });
                        } else {
                          setState(() {
                            _dragPosition = 0.0;
                          });
                        }
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _isCompleted ? AppColors.emerald500 : thumbColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withAlpha(80),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isCompleted ? Icons.check : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // HIG Accessibility fallback: Direct tap button for screen readers & assistive touch
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onTrigger();
                },
                icon: const Icon(Icons.touch_app_rounded, size: 15),
                label: const Text(
                  'Tap here to generate automatically',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
