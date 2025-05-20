import 'dart:math';
import 'package:flutter/material.dart';

/// A customizable circular progress indicator widget that can be styled
/// with various parameters to fit your app's design language.
class CustomCircularProgressIndicator extends StatelessWidget {
  /// The current progress value between 0.0 and 1.0
  final double progress;

  /// Size of the circular indicator (both width and height)
  final double size;

  /// Thickness of the progress arc
  final double strokeWidth;

  /// Color of the progress arc
  final Color progressColor;

  /// Color of the background arc
  final Color backgroundColor;

  /// Whether to display the center text showing percentage
  final bool showPercentage;

  /// Style for the percentage text
  final TextStyle? percentageTextStyle;

  /// Start angle for the progress arc in radians (0.0 is at 3 o'clock position)
  final double startAngle;

  /// Whether to animate changes in progress value
  final bool animate;

  /// Duration for the progress animation
  final Duration animationDuration;

  /// Optional widget to display in the center instead of percentage text
  final Widget? centerWidget;

  /// Callback function that gets called when the progress indicator is tapped
  final VoidCallback? onTap;

  /// Creates a custom circular progress indicator.
  const CustomCircularProgressIndicator({
    super.key,
    required this.progress,
    this.size = 100.0,
    this.strokeWidth = 10.0,
    this.progressColor = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.showPercentage = true,
    this.percentageTextStyle,
    this.startAngle = -pi / 2, // Start from top (12 o'clock position)
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.centerWidget,
    this.onTap,
  })  : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    // Default text style for percentage if not provided
    final defaultTextStyle = TextStyle(
      fontSize: size / 5,
      fontWeight: FontWeight.bold,
      color: progressColor,
    );

    // Final text style to use
    final textStyle = percentageTextStyle ?? defaultTextStyle;

    // Clamp progress value between 0.0 and 1.0 to ensure valid values
    final clampedProgress = progress.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            CustomPaint(
              size: Size(size, size),
              painter: _CircularProgressPainter(
                progress: animate ? 1.0 : clampedProgress,
                progressColor: backgroundColor,
                strokeWidth: strokeWidth,
                startAngle: startAngle,
              ),
            ),

            // Progress arc
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: clampedProgress),
              duration: animate ? animationDuration : Duration.zero,
              builder: (context, value, _) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: _CircularProgressPainter(
                    progress: value,
                    progressColor: progressColor,
                    strokeWidth: strokeWidth,
                    startAngle: startAngle,
                    isBackground: false,
                  ),
                );
              },
            ),

            // Center content (either percentage text or custom widget)
            if (centerWidget != null)
              centerWidget!
            else if (showPercentage)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: clampedProgress),
                duration: animate ? animationDuration : Duration.zero,
                builder: (context, value, _) {
                  return Text(
                    '${(value * 100).toInt()}%',
                    style: textStyle,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

}

/// Custom painter that draws the circular progress arc
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;
  final double startAngle;
  final bool isBackground;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
    required this.startAngle,
    this.isBackground = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the center point and radius
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    // Create paint object for the arc
    final paint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = isBackground ? StrokeCap.butt : StrokeCap.round;

    // Calculate sweep angle based on progress (full circle is 2π radians)
    final sweepAngle = 2 * pi * progress;

    // Draw the arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle;
  }
}

/// TODO: Example Usage: (Need to remove in production)
///
/// class ProgressDemoPage extends StatefulWidget {
///   @override
///   _ProgressDemoPageState createState() => _ProgressDemoPageState();
/// }
///
/// class _ProgressDemoPageState extends State<ProgressDemoPage> {
///   double progress = 0.0;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Custom Progress Demo')),
///       body: Center(
///         child: Column(
///           mainAxisAlignment: MainAxisAlignment.center,
///           children: [
///             // Basic usage
///             CustomCircularProgressIndicator(
///               progress: progress,
///               size: 150,
///               progressColor: Colors.purple,
///               backgroundColor: Colors.purple.withOpacity(0.2),
///             ),
///             SizedBox(height: 30),
///
///             // Theme-aware usage
///             CustomCircularProgressIndicator.primary(
///               context,
///               progress: progress,
///               size: 120,
///             ),
///             SizedBox(height: 30),
///
///             // With custom center widget
///             CustomCircularProgressIndicator(
///               progress: progress,
///               size: 150,
///               progressColor: Colors.orange,
///               backgroundColor: Colors.orange.withOpacity(0.2),
///               showPercentage: false,
///               centerWidget: Icon(
///                 Icons.cloud_upload,
///                 size: 40,
///                 color: Colors.orange,
///               ),
///             ),
///             SizedBox(height: 40),
///
///             // Control slider
///             Slider(
///               value: progress,
///               onChanged: (value) {
///                 setState(() {
///                   progress = value;
///                 });
///               },
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
