import 'package:flutter/material.dart';

/// A set of custom progress bar widgets for both linear and circular variants.
/// These widgets are highly customizable and can be reused throughout the app.

/// Custom Linear Progress Bar Widget
/// 
/// A customizable linear progress bar that can be styled with various properties.
class NLinearProgress extends StatelessWidget {

  /// The progress value between 0.0 and 1.0
  final double value;

  /// Height of the progress bar
  final double height;

  /// Width of the progress bar (null means it takes the parent's width)
  final double? width;

  /// Background color of the progress bar
  final Color backgroundColor;

  /// Color of the progress indicator
  final Color progressColor;

  /// Colors to use for gradient progress (if provided, progressColor is ignored)
  final List<Color>? gradientColors;

  /// Border radius of the progress bar
  final BorderRadius? borderRadius;

  /// Border width of the progress bar
  final double borderWidth;

  /// Border color of the progress bar
  final Color? borderColor;

  /// Whether to animate the progress change
  final bool animate;

  /// Duration of the animation
  final Duration animationDuration;

  /// Direction of the progress bar
  final TextDirection direction;

  /// Whether to show percentage text
  final bool showPercentage;

  /// Style for the percentage text
  final TextStyle? percentageTextStyle;

  /// Whether the progress bar should display indeterminate (loading) state
  final bool isIndeterminate;

  /// Optional custom shape for the progress bar
  final BoxShape shape;

  const NLinearProgress({
    Key? key,
    this.value = 0.0,
    this.height = 10.0,
    this.width,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = Colors.blue,
    this.gradientColors,
    this.borderRadius,
    this.borderWidth = 0.0,
    this.borderColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.direction = TextDirection.ltr,
    this.showPercentage = false,
    this.percentageTextStyle,
    this.isIndeterminate = false,
    this.shape = BoxShape.rectangle,
  }) : assert(value >= 0.0 && value <= 1.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final constrainedValue = value.clamp(0.0, 1.0);
    final percentageText = '${(constrainedValue * 100).toInt()}%';

    // If shape is not rectangle, we need to make the width equal to height
    final effectiveWidth = shape == BoxShape.circle ? height : width;

    // Border radius handling
    final effectiveBorderRadius = borderRadius ??
        (shape == BoxShape.circle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(4.0));

    // Build the main progress bar
    Widget progressBar = Container(
      width: effectiveWidth,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveBorderRadius,
        shape: shape,
        border: borderWidth > 0
            ? Border.all(
          color: borderColor ?? Colors.grey.shade400,
          width: borderWidth,
        )
            : null,
      ),
      child: isIndeterminate
          ? _buildIndeterminateBar(effectiveBorderRadius)
          : _buildDeterminateBar(constrainedValue, effectiveBorderRadius),
    );

    // Add percentage display if needed
    if (showPercentage && !isIndeterminate) {
      return Stack(
        alignment: Alignment.center,
        children: [
          progressBar,
          Text(
            percentageText,
            style: percentageTextStyle ??
                TextStyle(
                  fontSize: height * 0.6,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      );
    }

    return progressBar;
  }

  /// Builds the determinate (fixed value) progress bar
  Widget _buildDeterminateBar(double constrainedValue, BorderRadius borderRadius) {
    final progressWidget = Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: gradientColors == null ? progressColor : null,
        gradient: gradientColors != null
            ? LinearGradient(
          colors: gradientColors!,
          begin: direction == TextDirection.ltr
              ? Alignment.centerLeft
              : Alignment.centerRight,
          end: direction == TextDirection.ltr
              ? Alignment.centerRight
              : Alignment.centerLeft,
        )
            : null,
      ),
    );

    final clipper = _LinearProgressClipper(
      value: constrainedValue,
      direction: direction,
    );

    if (animate) {
      return AnimatedBuilder(
          animation: ClipperAnimation(
            value: constrainedValue,
            duration: animationDuration,
          ),
          builder: (context, _) {
            return ClipPath(
              clipper: clipper,
              child: progressWidget,
            );
          }
      );
    } else {
      return ClipPath(
        clipper: clipper,
        child: progressWidget,
      );
    }
  }

  /// Builds the indeterminate (loading) progress bar
  Widget _buildIndeterminateBar(BorderRadius borderRadius) {
    return LinearProgressIndicator(
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation<Color>(
        gradientColors != null ? gradientColors!.first : progressColor,
      ),
      borderRadius: borderRadius,
    );
  }
}

/// Clipper for animating the linear progress
class _LinearProgressClipper extends CustomClipper<Path> {
  final double value;
  final TextDirection direction;

  _LinearProgressClipper({
    required this.value,
    required this.direction,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    if (direction == TextDirection.ltr) {
      path.addRect(Rect.fromLTWH(0, 0, size.width * value, size.height));
    } else {
      path.addRect(Rect.fromLTWH(
          size.width * (1 - value),
          0,
          size.width * value,
          size.height
      ));
    }
    return path;
  }

  @override
  bool shouldReclip(_LinearProgressClipper oldClipper) {
    return oldClipper.value != value || oldClipper.direction != direction;
  }
}

/// Simple animation controller for progress animations
class ClipperAnimation extends Animation<double> with AnimationLazyListenerMixin {
  double _value;
  final Duration duration;

  ClipperAnimation({
    required double value,
    required this.duration,
  }) : _value = value;

  @override
  double get value => _value;



  @override
  void addStatusListener(AnimationStatusListener listener) {
  }

  @override
  void didStartListening() {
  }

  @override
  void didStopListening() {
  }

  @override
  void removeListener(VoidCallback listener) {
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
  }

  @override
  AnimationStatus get status => throw UnimplementedError();

  @override
  void addListener(VoidCallback listener) {
  }
}