import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vaultx/core/theme/app_theme.dart';
import 'package:vaultx/core/theme/expressive_motion.dart';

/// Material 3 Expressive Motion Slider with dynamic track expansion,
/// morphing thumb physics, spring-based floating value indicator,
/// and discrete step markers.
class ExpressiveMotionSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final String Function(double value)? valueFormatter;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final bool showValueIndicator;
  final bool showTickMarks;
  final double restingTrackHeight;
  final double activeTrackHeight;

  const ExpressiveMotionSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.valueFormatter,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.showValueIndicator = true,
    this.showTickMarks = true,
    this.restingTrackHeight = 14.0,
    this.activeTrackHeight = 22.0,
  }) : assert(max > min, 'max must be strictly greater than min');

  @override
  State<ExpressiveMotionSlider> createState() => _ExpressiveMotionSliderState();
}

class _ExpressiveMotionSliderState extends State<ExpressiveMotionSlider>
    with TickerProviderStateMixin {
  late AnimationController _interactionController;
  late Animation<double> _trackHeightAnimation;
  late Animation<double> _thumbScaleAnimation;
  late Animation<double> _tooltipScaleAnimation;

  bool _isDragging = false;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);

    _interactionController = AnimationController(
      vsync: this,
      duration: ExpressiveMotion.durationMedium1,
      reverseDuration: ExpressiveMotion.durationMedium2,
    );

    _trackHeightAnimation = Tween<double>(
      begin: widget.restingTrackHeight,
      end: widget.activeTrackHeight,
    ).animate(
      CurvedAnimation(
        parent: _interactionController,
        curve: ExpressiveMotion.emphasizedDecelerate,
        reverseCurve: Curves.easeOutCubic,
      ),
    );

    _thumbScaleAnimation = Tween<double>(
      begin: 1.0,
      end: ExpressiveMotion.sliderThumbPressScale,
    ).animate(
      CurvedAnimation(
        parent: _interactionController,
        curve: ExpressiveMotion.snappy,
        reverseCurve: Curves.easeOutCubic,
      ),
    );

    _tooltipScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _interactionController,
        curve: ExpressiveMotion.snappy,
        reverseCurve: Curves.easeInBack,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ExpressiveMotionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && widget.value != oldWidget.value) {
      _currentValue = widget.value.clamp(widget.min, widget.max);
    }
  }

  @override
  void dispose() {
    _interactionController.dispose();
    super.dispose();
  }

  void _onInteractionStart(double localDx, double width) {
    _isDragging = true;
    _interactionController.forward();
    _updateValueFromPosition(localDx, width);
    widget.onChangeStart?.call(_currentValue);
  }

  void _onInteractionUpdate(double localDx, double width) {
    _updateValueFromPosition(localDx, width);
  }

  void _onInteractionEnd() {
    _isDragging = false;
    _interactionController.reverse();
    widget.onChangeEnd?.call(_currentValue);
  }

  void _updateValueFromPosition(double localDx, double width) {
    if (width <= 0) return;
    const thumbPadding = 18.0;
    final usableWidth = width - (thumbPadding * 2);
    final clampedX = (localDx - thumbPadding).clamp(0.0, usableWidth);
    final fraction = usableWidth > 0 ? (clampedX / usableWidth) : 0.0;
    var rawValue = widget.min + (fraction * (widget.max - widget.min));

    if (widget.divisions != null && widget.divisions! > 0) {
      final step = (widget.max - widget.min) / widget.divisions!;
      rawValue = (widget.min + ((rawValue - widget.min) / step).round() * step)
          .clamp(widget.min, widget.max);
    }

    if (rawValue != _currentValue) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentValue = rawValue;
      });
      widget.onChanged(rawValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = widget.activeColor ?? AppColors.primaryBlue;
    final inactiveBg = widget.inactiveColor ??
        (isDark ? AppColors.darkInputSurface : AppColors.lightInputSurface);
    final thumbColor = widget.thumbColor ?? primary;

    final normalized = (widget.max > widget.min)
        ? ((_currentValue - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0)
        : 0.0;

    return Semantics(
      slider: true,
      value: widget.valueFormatter?.call(_currentValue) ?? '$_currentValue',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          const thumbRadius = 14.0;
          final usableWidth = totalWidth - (thumbRadius * 2);
          final thumbCenterDx = thumbRadius + (normalized * usableWidth);

          return SizedBox(
            height: 72,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) =>
                  _onInteractionStart(details.localPosition.dx, totalWidth),
              onHorizontalDragUpdate: (details) =>
                  _onInteractionUpdate(details.localPosition.dx, totalWidth),
              onHorizontalDragEnd: (_) => _onInteractionEnd(),
              onHorizontalDragCancel: () => _onInteractionEnd(),
              onTapDown: (details) {
                _onInteractionStart(details.localPosition.dx, totalWidth);
                _onInteractionEnd();
              },
              child: AnimatedBuilder(
                animation: _interactionController,
                builder: (context, child) {
                  final trackHeight = _trackHeightAnimation.value;
                  final thumbScale = _thumbScaleAnimation.value;
                  final tooltipScale = _tooltipScaleAnimation.value;

                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      // --- INACTIVE TRACK CONTAINER ---
                      Positioned(
                        left: 0,
                        right: 0,
                        top: (72 - trackHeight) / 2,
                        height: trackHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: inactiveBg,
                            borderRadius: BorderRadius.circular(trackHeight / 2),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // --- DISCRETE TICK MARKS ---
                      if (widget.showTickMarks &&
                          widget.divisions != null &&
                          widget.divisions! <= 24)
                        Positioned(
                          left: thumbRadius,
                          right: thumbRadius,
                          top: (72 - trackHeight) / 2,
                          height: trackHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(widget.divisions! + 1, (index) {
                              final tickFraction = index / widget.divisions!;
                              final isPassed = tickFraction <= normalized;
                              return Container(
                                width: 3.5,
                                height: 3.5,
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? Colors.white.withAlpha(180)
                                      : (isDark ? Colors.white24 : Colors.black26),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ),

                      // --- ACTIVE TRACK SEGMENT (with M3 Expressive notch gap) ---
                      if (thumbCenterDx > thumbRadius)
                        Positioned(
                          left: 0,
                          width: math.max(0.0, thumbCenterDx - (_isDragging ? 16 : 8)),
                          top: (72 - trackHeight) / 2,
                          height: trackHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(trackHeight / 2),
                                right: Radius.circular(trackHeight / 4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withAlpha(isDark ? 90 : 60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // --- ACTIVE INACTIVE GAP (RIGHT SIDE OF THUMB) ---
                      if (thumbCenterDx < totalWidth - thumbRadius)
                        Positioned(
                          left: thumbCenterDx + (_isDragging ? 16 : 8),
                          right: 0,
                          top: (72 - trackHeight) / 2,
                          height: trackHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(trackHeight / 4),
                                right: Radius.circular(trackHeight / 2),
                              ),
                            ),
                          ),
                        ),

                      // --- FLOATING BALLOON VALUE INDICATOR (Pop-up with spring) ---
                      if (widget.showValueIndicator && tooltipScale > 0.001)
                        Positioned(
                          left: (thumbCenterDx - 36).clamp(0.0, totalWidth - 72),
                          top: -4,
                          child: Opacity(
                            opacity: tooltipScale.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: tooltipScale,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCardSurface : primary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? primary.withAlpha(120) : Colors.white24,
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(90),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.valueFormatter?.call(_currentValue) ??
                                      '${_currentValue.round()}',
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // --- MORPHING EXPRESSIVE THUMB ---
                      Positioned(
                        left: thumbCenterDx - 14,
                        top: (72 - 32) / 2,
                        child: Transform.scale(
                          scale: thumbScale,
                          child: Container(
                            width: _isDragging ? 14 : 8,
                            height: 32,
                            decoration: BoxDecoration(
                              color: thumbColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: thumbColor.withAlpha(isDark ? 160 : 110),
                                  blurRadius: _isDragging ? 14 : 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
