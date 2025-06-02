import 'package:flutter/material.dart';

/// A customizable increment/decrement counter widget
///
/// Features:
/// - Min/max value constraints
/// - Customizable appearance (colors, size, icons)
/// - Automatic button state management (disabled when limits reached)
/// - Callback function for value changes
class ItemCounterWidget extends StatelessWidget {

  /// Current count value
  final int count;

  /// Callback function called when count changes
  final Function(int) onCountChanged;

  /// Minimum allowed count (default: 0)
  final int minCount;

  /// Maximum allowed count (default: 999)
  final int maxCount;

  /// Overall size of the widget (default: 32.0)
  final double size;

  /// Background color of the container
  final Color? backgroundColor;

  /// Color of the increment/decrement buttons
  final Color? buttonColor;

  /// Color of the count text
  final Color? textColor;

  /// Icon for increment button (default: Icons.add)
  final IconData? incrementIcon;

  /// Icon for decrement button (default: Icons.remove)
  final IconData? decrementIcon;

  /// Whether to show border around the widget
  final bool showBorder;

  const ItemCounterWidget({
    super.key,
    required this.count,
    required this.onCountChanged,
    this.minCount = 0,
    this.maxCount = 999,
    this.size = 32.0,
    this.backgroundColor,
    this.buttonColor,
    this.textColor,
    this.incrementIcon = Icons.add,
    this.decrementIcon = Icons.remove,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final btnColor = buttonColor ?? theme.colorScheme.primary;
    final txtColor = textColor ?? theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
        border: showBorder ? Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          _buildButton(
            icon: decrementIcon!,
            onPressed: count > minCount
                ? () => onCountChanged(count - 1)
                : null,
            color: btnColor,
            size: size,
            isEnabled: count > minCount,
          ),

          // Count Display
          Container(
            constraints: BoxConstraints(minWidth: size * 1.2),
            padding: EdgeInsets.symmetric(horizontal: size * 0.2),
            child: Text(
              count.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                color: txtColor,
              ),
            ),
          ),

          // Increment Button
          _buildButton(
            icon: incrementIcon!,
            onPressed: count < maxCount
                ? () => onCountChanged(count + 1)
                : null,
            color: btnColor,
            size: size,
            isEnabled: count < maxCount,
          ),
        ],
      ),
    );
  }

  /// Builds individual increment/decrement buttons with proper state management
  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required double size,
    required bool isEnabled,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            size: size * 0.5,
            color: isEnabled ? color : color.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}