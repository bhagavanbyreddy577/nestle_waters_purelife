import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class NChip extends StatelessWidget {

  /// The text to display within the chip.
  final String label;

  /// The background color of the chip.
  final Color? backgroundColor;

  /// The color of the text within the chip.
  final Color? textColor;

  /// The border of the chip.
  final Border? border;

  /// The padding around the chip's content.
  final EdgeInsetsGeometry? padding;

  /// The margin around the chip.
  final EdgeInsetsGeometry? margin;

  /// The radius of the chip's corners.
  final BorderRadius? borderRadius;

  /// A custom leading widget.
  final Widget? leading;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// Elevation of the chip.
  final double? elevation;

  /// Shadow color for the chip.
  final Color? shadowColor;

  /// A callback function to be called when the close button is pressed.
  final VoidCallback? onClosePressed;

  /// Whether to show a close button.
  final bool showCloseButton;

  /// A custom trailing widget.
  final Widget? trailing;

  /// Constructor for the CustomChip widget.
  ///
  /// The [label] is required and is the text that will be displayed inside the chip.
  /// Other properties are optional and allow for extensive customization of the chip's appearance.
  const NChip({
    super.key,
    required this.label,
    this.backgroundColor = Colors.grey, // Default background color.
    this.textColor = Colors.white, // Default text color.
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Default padding.
    this.margin = const EdgeInsets.symmetric(horizontal: 4), // Default margin.
    this.borderRadius = const BorderRadius.all(Radius.circular(16)), // Default border radius.
    this.leading,
    this.onTap,
    this.elevation,
    this.shadowColor,
    this.onClosePressed,
    this.showCloseButton = false, // Default is to not show the close button.
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Use a Material widget for inkwell effect, elevation, and shadow.
    return Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      elevation: elevation ?? 0, // Default elevation is 0.
      shadowColor: shadowColor,
      child: InkWell(
        onTap: onTap, // Make the chip tappable.
        borderRadius: borderRadius, // Ensure the inkwell has the same border radius.
        child: Container(
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            // If a border is provided, use it. Otherwise, don't set a default.
            border: border,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Ensure the row takes up minimal space.
            children: <Widget>[
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 4), // Add spacing between leading and label.
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14, // Default font size.
                ),
              ),
              if (showCloseButton) ...[
                const SizedBox(width: 4), // Add spacing before the close button.
                InkWell(
                  onTap: onClosePressed,
                  borderRadius: BorderRadius.circular(10), // Make it round
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white, // Or a contrasting color
                    ),
                  ),
                ),
              ],
              if (trailing != null && !showCloseButton) ...[
                const SizedBox(width: 4), // Add spacing between label and trailing.
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}