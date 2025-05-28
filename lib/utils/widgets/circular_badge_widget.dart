import 'package:flutter/material.dart';

/// A versatile circular badge widget for displaying counts (notifications, cart items, etc.)
/// Can be used standalone or as an overlay on other widgets like icons.
///
/// Features:
/// - Automatic sizing based on count digits
/// - Max count display (e.g., "99+")
/// - Option to show/hide zero counts
/// - Customizable appearance
/// - Perfect positioning when used as overlay
class CircularBadgeWidget extends StatelessWidget {

  /// The count to display in the badge
  final int count;

  /// Size of the badge (default: 20.0)
  final double size;

  /// Background color of the badge
  final Color? backgroundColor;

  /// Text color inside the badge
  final Color? textColor;

  /// Border color around the badge
  final Color? borderColor;

  /// Border width (default: 0 - no border)
  final double borderWidth;

  /// Child widget to overlay the badge on (optional)
  final Widget? child;

  /// Whether to show the badge when count is 0 (default: false)
  final bool showZero;

  /// Maximum count to display before showing "+" (default: 99)
  final int maxCount;

  /// Custom text style for the count
  final TextStyle? textStyle;

  /// Custom padding inside the badge
  final EdgeInsets? padding;

  const CircularBadgeWidget({
    Key? key,
    required this.count,
    this.size = 20.0,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0,
    this.child,
    this.showZero = false,
    this.maxCount = 99,
    this.textStyle,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.error;
    final txtColor = textColor ?? theme.colorScheme.onError;
    final shouldShow = showZero || count > 0;

    // Don't show badge if count is 0 and showZero is false
    if (!shouldShow) {
      return child ?? const SizedBox.shrink();
    }

    // Format count display (e.g., "99+")
    final displayCount = count > maxCount ? '${maxCount}+' : count.toString();

    // Adjust badge size based on digit count
    final badgeSize = size + (count > 9 ? 4 : 0);

    Widget badge = Container(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      padding: padding ?? EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
          color: borderColor ?? Colors.white,
          width: borderWidth,
        )
            : null,
      ),
      child: Center(
        child: Text(
          displayCount,
          style: textStyle ??
              TextStyle(
                color: txtColor,
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );

    // If child widget provided, position badge as overlay
    if (child != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child!,
          Positioned(
            top: -size * 0.3,
            right: -size * 0.3,
            child: badge,
          ),
        ],
      );
    }

    return badge;
  }
}