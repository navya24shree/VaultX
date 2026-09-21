import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vaultx/core/theme/app_theme.dart';

/// Tactile vertical ruler/ladder slider for setting password length (8 to 32 characters)
/// with rung markers, glowing thumb, drag physics, and direct tap selection.
class VerticalRulerSlider extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final double? height;

  const VerticalRulerSlider({
    super.key,
    required this.value,
    this.min = 8,
    this.max = 32,
    required this.onChanged,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const width = 68.0;

    return Semantics(
      slider: true,
      value: '$value characters',
      increasedValue: '${(value + 1).clamp(min, max)} characters',
      decreasedValue: '${(value - 1).clamp(min, max)} characters',
      onIncrease: () {
        if (value < max) onChanged(value + 1);
      },
      onDecrease: () {
        if (value > min) onChanged(value - 1);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null && box.size.height > 0) {
            final localPos = box.globalToLocal(details.globalPosition);
            final h = box.size.height;
            // Invert Y: top is max (32), bottom is min (8)
            final fraction = (1.0 - (localPos.dy / h)).clamp(0.0, 1.0);
            final newValue = (min + (fraction * (max - min))).round();
            if (newValue != value) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            }
          }
        },
        onTapDown: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null && box.size.height > 0) {
            final h = box.size.height;
            final fraction = (1.0 - (details.localPosition.dy / h)).clamp(0.0, 1.0);
            final newValue = (min + (fraction * (max - min))).round();
            if (newValue != value) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            }
          }
        },
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkInputSurface : AppColors.lightInputSurface,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rung Tick Marks
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(13, (index) {
                  final isMajor = index % 3 == 0;
                  return Container(
                    height: 2,
                    width: isMajor ? 24 : 12,
                    decoration: BoxDecoration(
                      color: isMajor
                          ? (isDark ? Colors.white24 : Colors.black26)
                          : (isDark ? Colors.white12 : Colors.black12),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                }),
              ),

              // Positioned Active Indicator Thumb
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Align(
                  alignment: Alignment(
                    0.0,
                    1.0 - (2.0 * ((value - min) / (max - min)).clamp(0.0, 1.0)),
                  ),
                  child: Container(
                    width: 54,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withAlpha(90),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$value',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
