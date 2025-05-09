import 'package:flutter/material.dart';

class NCheckbox extends StatefulWidget {

  /// The current value of the checkbox.
  final bool value;

  /// Callback function when the checkbox value changes.
  final ValueChanged<bool> onChanged;

  /// The title text to display next to the checkbox.
  final String title;

  /// Text style for the title.
  final TextStyle? textStyle;

  /// Color of the checkbox when checked.
  final Color? activeColor;

  /// Color of the checkbox when unchecked.
  final Color? inactiveColor;

  /// Color of the checkmark.
  final Color? checkColor;

  /// Padding around the entire widget.
  final EdgeInsets? padding;

  /// Spacing between the checkbox and the title.
  final double spaceBetween;

  /// Whether the checkbox should be enabled or not.
  final bool enabled;

  /// Size of the checkbox.
  final double checkboxSize;

  /// Custom border radius for the checkbox.
  final BorderRadius? borderRadius;

  /// Border width for the checkbox.
  final double borderWidth;

  /// Border color for the checkbox when unchecked.
  final Color? borderColor;

  /// Whether the title should be positioned before or after the checkbox.
  final bool titleFirst;

  /// How the checkbox and title should be aligned horizontally.
  final MainAxisAlignment mainAxisAlignment;

  /// How the checkbox and title should be aligned vertically.
  final CrossAxisAlignment crossAxisAlignment;

  const NCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.textStyle,
    this.activeColor,
    this.inactiveColor,
    this.checkColor,
    this.padding,
    this.spaceBetween = 8.0,
    this.enabled = true,
    this.checkboxSize = 24.0,
    this.borderRadius,
    this.borderWidth = 2.0,
    this.borderColor,
    this.titleFirst = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  _NCheckboxState createState() => _NCheckboxState();
}

class _NCheckboxState extends State<NCheckbox> {
  @override
  Widget build(BuildContext context) {
    // Default theme colors if not provided
    final ThemeData theme = Theme.of(context);
    final Color effectiveActiveColor = widget.activeColor ?? theme.colorScheme.primary;
    final Color effectiveCheckColor = widget.checkColor ?? Colors.white;
    final Color effectiveBorderColor = widget.borderColor ?? theme.colorScheme.outline;
    final Color effectiveInactiveColor = widget.inactiveColor ?? Colors.transparent;

    // Create the checkbox
    final checkbox = SizedBox(
      width: widget.checkboxSize,
      height: widget.checkboxSize,
      child: Transform.scale(
        scale: widget.checkboxSize / 24.0, // Scale based on the desired size
        child: Checkbox(
          value: widget.value,
          onChanged: widget.enabled ? (value) => widget.onChanged(value!) : null,
          activeColor: effectiveActiveColor,
          checkColor: effectiveCheckColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(
            color: effectiveBorderColor,
            width: widget.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
          ),
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.selected)) {
              return effectiveActiveColor;
            }
            return effectiveInactiveColor;
          }),
        ),
      ),
    );

    // Create the title
    final titleWidget = Text(
      widget.title,
      style: widget.textStyle ?? theme.textTheme.bodyMedium?.copyWith(
        color: widget.enabled ? null : theme.disabledColor,
      ),
    );

    // Arrange the widgets based on titleFirst property
    List<Widget> rowChildren = widget.titleFirst
        ? [titleWidget, SizedBox(width: widget.spaceBetween), checkbox]
        : [checkbox, SizedBox(width: widget.spaceBetween), titleWidget];

    // Build the final widget
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: rowChildren,
      ),
    );
  }
}