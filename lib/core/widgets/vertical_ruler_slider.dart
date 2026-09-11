import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neurokey/core/theme/app_theme.dart';

/// Tactile vertical ruler/ladder slider for setting password length (8 to 32 characters)
/// with rung markers, glowing thumb, drag physics, and direct tap selection.
class VerticalRulerSlider extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const VerticalRulerSlider({
    super.key,
    required this.value,
    this.min = 8,
    this.max = 32,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const height = 280.0;
    const width = 68.0;

    return Semantics(
      slider: true,
      value: ' characters',
      increasedValue: ' characters',
      decreasedValue: ' characters',
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
          if (box != null) {
            final localPos = box.globalToLocal(details.globalPosition);
            // Invert Y: top is max (32), bottom is min (8)
            final fraction = (1.0 - (localPos.dy / height)).clamp(0.0, 1.0);
            final newValue = (min + (fraction * (max - min))).round();
            if (newValue != value) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            }
          }
        },
        onTapDown: (details) {
          final fraction = (1.0 - (details.localPosition.dy / height)).clamp(0.0, 1.0);
          final newValue = (min + (fraction * (max - min))).round();
          if (newValue != value) {
            HapticFeedback.selectionClick();
            onChanged(newValue);
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
            alignment: Alignment.bottomCenter,
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
              Positioned(
                bottom: (((value - min) / (max - min)) * (height - 52)).clamp(4.0, height - 52.0),
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
            ],
          ),
        ),
      ),
    );
  }
}
