import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Circular Progress Bar Widget
///
/// A customizable circular progress bar with various styling options.
class NCircularProgress extends StatelessWidget {

  /// The progress value between 0.0 and 1.0
  final double value;

  /// Size of the circular progress bar
  final double size;

  /// Width of the progress track
  final double strokeWidth;

  /// Background color of the progress track
  final Color backgroundColor;

  /// Color of the progress indicator
  final Color progressColor;

  /// Colors to use for gradient progress (if provided, progressColor is ignored)
  final List<Color>? gradientColors;

  /// Whether to animate the progress change
  final bool animate;

  /// Duration of the animation
  final Duration animationDuration;

  /// Start angle for the progress arc in radians
  final double startAngle;

  /// Whether to show percentage text in the center
  final bool showPercentage;

  /// Style for the percentage text
  final TextStyle? percentageTextStyle;

  /// Whether to round the progress bar caps
  final bool roundCaps;

  /// Whether the progress bar should display indeterminate (loading) state
  final bool isIndeterminate;

  /// Custom background widget to display in the center
  final Widget? centerWidget;

  /// Whether to show background track
  final bool showBackgroundTrack;

  const NCircularProgress({
    super.key,
    this.value = 0.0,
    this.size = 100.0,
    this.strokeWidth = 10.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = Colors.blue,
    this.gradientColors,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.startAngle = -math.pi / 2, // Start from top
    this.showPercentage = false,
    this.percentageTextStyle,
    this.roundCaps = false,
    this.isIndeterminate = false,
    this.centerWidget,
    this.showBackgroundTrack = true,
  }) : assert(value >= 0.0 && value <= 1.0);

  @override
  Widget build(BuildContext context) {
    final constrainedValue = value.clamp(0.0, 1.0);

    Widget progressBar;

    if (isIndeterminate) {
      // Indeterminate progress indicator
      progressBar = SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            gradientColors != null ? gradientColors!.first : progressColor,
          ),
          backgroundColor: showBackgroundTrack ? backgroundColor : Colors.transparent,
        ),
      );
    } else {
      // Determinate progress indicator
      progressBar = SizedBox(
        width: size,
        height: size,
        child: animate
            ? TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: constrainedValue),
          duration: animationDuration,
          builder: (context, value, _) {
            return _buildCircularProgress(value);
          },
        )
            : _buildCircularProgress(constrainedValue),
      );
    }

    // Add center widget or percentage if needed
    if ((showPercentage || centerWidget != null) && !isIndeterminate) {
      Widget? centerContent;

      if (centerWidget != null) {
        centerContent = centerWidget;
      } else if (showPercentage) {
        final percentageText = '${(constrainedValue * 100).toInt()}%';
        centerContent = Text(
          percentageText,
          style: percentageTextStyle ??
              TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        );
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          progressBar,
          if (centerContent != null) centerContent,
        ],
      );
    }

    return progressBar;
  }

  /// Builds the circular progress painter
  Widget _buildCircularProgress(double value) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CircularProgressPainter(
        value: value,
        strokeWidth: strokeWidth,
        backgroundColor: showBackgroundTrack ? backgroundColor : Colors.transparent,
        progressColor: progressColor,
        gradientColors: gradientColors,
        startAngle: startAngle,
        roundCaps: roundCaps,
      ),
    );
  }
}

/// Custom painter for drawing the circular progress
class _CircularProgressPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final List<Color>? gradientColors;
  final double startAngle;
  final bool roundCaps;

  _CircularProgressPainter({
    required this.value,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    this.gradientColors,
    required this.startAngle,
    required this.roundCaps,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Draw background circle if needed
    if (backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = roundCaps ? StrokeCap.round : StrokeCap.butt;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Create progress paint
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = roundCaps ? StrokeCap.round : StrokeCap.butt;

    // Set up gradient if needed
    if (gradientColors != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      progressPaint.shader = SweepGradient(
        colors: gradientColors!,
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        tileMode: TileMode.clamp,
      ).createShader(rect);
    } else {
      progressPaint.color = progressColor;
    }

    // Draw progress arc
    final sweepAngle = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldPainter) {
    return oldPainter.value != value ||
        oldPainter.strokeWidth != strokeWidth ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.progressColor != progressColor ||
        oldPainter.startAngle != startAngle ||
        oldPainter.roundCaps != roundCaps;
  }
}