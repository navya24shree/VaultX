import 'package:flutter/material.dart';
import 'package:vaultx/core/widgets/expressive/expressive_vertical_slider.dart';

/// Tactile vertical ruler/ladder slider for setting password length (8 to 32 characters)
/// powered by Material 3 Expressive motion physics, rung markers, glowing thumb,
/// and floating lateral value badge.
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
    return ExpressiveVerticalMotionSlider(
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
      height: height,
    );
  }
}
