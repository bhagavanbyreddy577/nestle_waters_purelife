import 'package:flutter/material.dart';

/// A single custom radio button widget that allows for extensive customization.
///
/// This widget creates a radio button with a title arranged horizontally in a Row.
/// It provides customization options for various properties like colors, padding,
/// text style, and more.
class NRadioButton<T> extends StatelessWidget {

  /// The current selected value of the radio group.
  final T? groupValue;

  /// The value this radio button represents.
  final T value;

  /// Callback function when the radio button value changes.
  final ValueChanged<T> onChanged;

  /// The title text to display next to the radio button.
  final String title;

  /// Text style for the title.
  final TextStyle? textStyle;

  /// Color of the radio button when selected.
  final Color? activeColor;

  /// Color of the radio button border when unselected.
  final Color? unselectedColor;

  /// Padding around the entire widget.
  final EdgeInsets? padding;

  /// Spacing between the radio button and the title.
  final double spaceBetween;

  /// Whether the radio button should be enabled or not.
  final bool enabled;

  /// Size of the radio button.
  final double radioSize;

  /// Whether the title should be positioned before or after the radio button.
  final bool titleFirst;

  /// How the radio button and title should be aligned horizontally.
  final MainAxisAlignment mainAxisAlignment;

  /// How the radio button and title should be aligned vertically.
  final CrossAxisAlignment crossAxisAlignment;

  const NRadioButton({
    super.key,
    required this.groupValue,
    required this.value,
    required this.onChanged,
    required this.title,
    this.textStyle,
    this.activeColor,
    this.unselectedColor,
    this.padding,
    this.spaceBetween = 8.0,
    this.enabled = true,
    this.radioSize = 20.0,
    this.titleFirst = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    // Default theme colors if not provided
    final ThemeData theme = Theme.of(context);
    final Color effectiveActiveColor = activeColor ?? theme.colorScheme.primary;
    final Color effectiveUnselectedColor = unselectedColor ?? theme.unselectedWidgetColor;

    // Create the radio button
    final radioButton = SizedBox(
      width: radioSize,
      height: radioSize,
      child: Transform.scale(
        scale: radioSize / 20.0, // Scale based on the desired size
        child: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: enabled ? (newValue) => onChanged(newValue as T) : null,
          activeColor: effectiveActiveColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.selected)) {
              return effectiveActiveColor;
            }
            return effectiveUnselectedColor;
          }),
        ),
      ),
    );

    // Create the title
    final titleWidget = Text(
      title,
      style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
        color: enabled ? null : theme.disabledColor,
      ),
    );

    // Arrange the screens based on titleFirst property
    List<Widget> rowChildren = titleFirst
        ? [titleWidget, SizedBox(width: spaceBetween), radioButton]
        : [radioButton, SizedBox(width: spaceBetween), titleWidget];

    // Build the final widget
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: rowChildren,
      ),
    );
  }
}

/// A widget that displays a list of custom radio buttons.
///
/// This widget takes a list of items and creates a radio button for each item.
/// It handles the selection logic and provides customization options for the appearance.
class NRadioGroup<T> extends StatefulWidget {
  /// List of items to create radio buttons for.
  final List<T> items;

  /// Function to convert an item to a display string.
  final String Function(T) labelBuilder;

  /// Initial selected value.
  final T? initialValue;

  /// Callback function when selection changes.
  final ValueChanged<T> onChanged;

  /// Direction of the layout (vertical or horizontal).
  final Axis direction;

  /// Text style for the radio button labels.
  final TextStyle? textStyle;

  /// Color of the radio button when selected.
  final Color? activeColor;

  /// Color of the radio button border when unselected.
  final Color? unselectedColor;

  /// Padding around each radio button.
  final EdgeInsets? itemPadding;

  /// Spacing between radio buttons in the group.
  final double spacing;

  /// Spacing between the radio button and its label.
  final double spaceBetween;

  /// Size of the radio buttons.
  final double radioSize;

  /// Whether the title should be positioned before or after the radio button.
  final bool titleFirst;

  /// How each radio button and title should be aligned horizontally.
  final MainAxisAlignment mainAxisAlignment;

  /// How each radio button and title should be aligned vertically.
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the entire radio group is enabled.
  final bool enabled;

  const NRadioGroup({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.initialValue,
    this.direction = Axis.vertical,
    this.textStyle,
    this.activeColor,
    this.unselectedColor,
    this.itemPadding,
    this.spacing = 8.0,
    this.spaceBetween = 8.0,
    this.radioSize = 20.0,
    this.titleFirst = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.enabled = true,
  });

  @override
  State<NRadioGroup<T>> createState() => _NRadioGroupState<T>();
}

class _NRadioGroupState<T> extends State<NRadioGroup<T>> {
  late T? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(NRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      selectedValue = widget.initialValue;
    }
  }

  void _handleValueChange(T value) {
    setState(() {
      selectedValue = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    // Create radio buttons for each item
    final List<Widget> radioButtons = widget.items.map((item) {
      return NRadioButton<T>(
        value: item,
        groupValue: selectedValue,
        onChanged: _handleValueChange,
        title: widget.labelBuilder(item),
        textStyle: widget.textStyle,
        activeColor: widget.activeColor,
        unselectedColor: widget.unselectedColor,
        padding: widget.itemPadding,
        spaceBetween: widget.spaceBetween,
        radioSize: widget.radioSize,
        titleFirst: widget.titleFirst,
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        enabled: widget.enabled,
      );
    }).toList();

    // Build layout based on direction
    if (widget.direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _intersperse(
          radioButtons,
          SizedBox(height: widget.spacing),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _intersperse(
          radioButtons,
          SizedBox(width: widget.spacing),
        ),
      );
    }
  }

  // Helper function to add spacing between items
  List<Widget> _intersperse(List<Widget> list, Widget separator) {
    if (list.isEmpty) return list;

    List<Widget> result = [];
    for (int i = 0; i < list.length - 1; i++) {
      result.add(list[i]);
      result.add(separator);
    }
    result.add(list.last);

    return result;
  }
}