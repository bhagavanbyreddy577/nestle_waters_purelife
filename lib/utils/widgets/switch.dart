import 'package:flutter/material.dart';

class NSwitch extends StatelessWidget {

  /// The current value of the switch
  final bool value;

  /// Callback function when the switch value changes
  final ValueChanged<bool> onChanged;

  /// Title text displayed at the top left
  final String title;

  /// Description text displayed next to the switch
  final String description;

  /// Style for the title text
  final TextStyle? titleStyle;

  /// Style for the description text
  final TextStyle? descriptionStyle;

  /// Color of the switch when active (on)
  final Color activeColor;

  /// Color of the switch when inactive (off)
  final Color inactiveColor;

  /// Color of the switch thumb (the moving part)
  final Color? thumbColor;

  /// Background color of the entire widget
  final Color backgroundColor;

  /// Border radius for the container
  final BorderRadius? borderRadius;

  /// Padding applied to the entire widget
  final EdgeInsetsGeometry padding;

  /// Space between elements
  final double spacing;

  /// Width of the switch
  final double switchWidth;

  /// Height of the switch
  final double switchHeight;

  /// Optional widget to replace the standard switch
  final Widget? customSwitch;

  /// Whether to show a divider between title and row contents
  final bool showDivider;

  /// Color of the divider
  final Color dividerColor;

  /// Optional icon to display before the title
  final IconData? titleIcon;

  /// Color of the title icon
  final Color? titleIconColor;

  const NSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.description,
    this.titleStyle,
    this.descriptionStyle,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.thumbColor,
    this.backgroundColor = Colors.transparent,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16.0),
    this.spacing = 8.0,
    this.switchWidth = 50.0,
    this.switchHeight = 30.0,
    this.customSwitch,
    this.showDivider = false,
    this.dividerColor = Colors.grey,
    this.titleIcon,
    this.titleIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default text styles if not provided
    final defaultTitleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    ) ??
        const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        );

    final defaultDescriptionStyle = Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(
          fontSize: 14.0,
          color: Colors.black87,
        );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title section with optional icon
          Row(
            children: [
              if (titleIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    titleIcon,
                    color: titleIconColor,
                    size: defaultTitleStyle.fontSize! * 1.2,
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: titleStyle ?? defaultTitleStyle,
                ),
              ),
            ],
          ),

          // Optional divider
          if (showDivider)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing),
              child: Divider(
                color: dividerColor,
                height: 1.0,
              ),
            ),

          SizedBox(height: showDivider ? 0 : spacing),

          // Row containing description and switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Description text
              Expanded(
                child: Text(
                  description,
                  style: descriptionStyle ?? defaultDescriptionStyle,
                ),
              ),

              SizedBox(width: spacing),

              // Switch
              customSwitch ??
                  SizedBox(
                    width: switchWidth,
                    height: switchHeight,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Switch(
                        value: value,
                        onChanged: onChanged,
                        activeColor: activeColor,
                        inactiveTrackColor: inactiveColor,
                        thumbColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            return thumbColor ?? Colors.white;
                          },
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}