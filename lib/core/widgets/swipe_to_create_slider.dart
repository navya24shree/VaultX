import 'package:flutter/material.dart';
import 'package:vaultx/core/widgets/expressive/expressive_swipe_slider.dart';

/// An interactive swipe-to-generate slider control powered by
/// Material 3 Expressive motion physics, fluid progress track,
/// morphing thumb icon, and tactile haptic feedback.
class SwipeToCreateSlider extends StatelessWidget {
  final VoidCallback onTrigger;
  final String label;

  const SwipeToCreateSlider({
    super.key,
    required this.onTrigger,
    this.label = 'Swipe to Create Password',
  });

  @override
  Widget build(BuildContext context) {
    return ExpressiveSwipeSlider(
      onTrigger: onTrigger,
      label: label,
    );
  }
}
