import 'package:flutter/material.dart';

class NDropdown<T> extends StatelessWidget {

  /// Optional text to display above the dropdown field.
  final String? title;

  /// Custom style for the title text.
  final TextStyle? titleStyle;

  /// Whether to display a mandatory indicator (*) next to the title.
  /// Defaults to `false`.
  final bool isMandatory;

  /// A list of items the user can select.
  /// Each item must be a [DropdownMenuItem<T>].
  final List<DropdownMenuItem<T>> items;

  /// The currently selected value. Must be one of the values in [items].
  final T? value;

  /// A widget to display when [value] is null. Typically a [Text] widget.
  final Widget? hint;

  /// Called when the user selects an item.
  final ValueChanged<T?>? onChanged;

  /// An optional method that validates the selected value.
  /// Returns an error string to display if the input is invalid, or null otherwise.
  final FormFieldValidator<T>? validator;

  /// Whether the dropdown field is enabled or disabled.
  /// Defaults to `true`.
  final bool enabled;

  /// Custom style for the selected item displayed in the button.
  final TextStyle? textStyle;

  /// The border to display when the InputDecorator is enabled and is not showing an error.
  final InputBorder? enabledBorder;

  /// The border to display when the InputDecorator has focus and is not showing an error.
  final InputBorder? focusedBorder;

  /// The border to display when the InputDecorator is disabled.
  final InputBorder? disabledBorder;

  /// The border to display when the InputDecorator shows an error.
  final InputBorder? errorBorder;

  /// The border to display when the InputDecorator has focus and shows an error.
  final InputBorder? focusedErrorBorder;

  /// The color to fill the decoration's container.
  final Color? fillColor;

  /// Whether the decoration's container should be filled.
  /// Defaults to `false`.
  final bool filled;

  /// The padding for the input decoration's container.
  final EdgeInsetsGeometry? contentPadding;

  /// The error message to display below the field if validation fails.
  /// This is often managed by the validator, but can be set externally via [InputDecoration].
  final String? errorText;

  /// Icon displayed on the right side of the dropdown button.
  /// Defaults to a standard down arrow icon.
  final Widget? suffixIcon;

  /// The elevation of the dropdown menu.
  final double dropdownElevation;

  /// The color of the dropdown menu background.
  final Color? dropdownColor;

  /// The radius of the dropdown menu corners.
  final BorderRadius? dropdownBorderRadius;

  const NDropdown({
    super.key,
    required this.items,
    this.value,
    this.hint,
    this.onChanged,
    this.validator,
    this.title,
    this.titleStyle,
    this.isMandatory = false,
    this.enabled = true,
    this.textStyle,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.fillColor,
    this.filled = false,
    this.contentPadding,
    this.errorText,
    this.suffixIcon, // Keep null default to use DropdownButtonFormField's default
    this.dropdownElevation = 8.0,
    this.dropdownColor,
    this.dropdownBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Default border style if none provided
    const defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(color: Colors.grey),
    );

    // Default focused border style
    final defaultFocusedBorder = defaultBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
    );

    // Default error border style
    final defaultErrorBorder = defaultBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.error, width: 1.5),
    );

    // Effective style for the selected item text
    final effectiveTextStyle = textStyle ?? textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Take minimum vertical space
      children: [
        // --- Title Section ---
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0), // Space below title
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title!,
                  style: titleStyle ??
                      textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? colorScheme.onSurface
                            : Colors.grey, // Dim title when disabled
                      ),
                ),
                if (isMandatory)
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: colorScheme.error, // Use error color for '*'
                        fontSize: (titleStyle?.fontSize ??
                            textTheme.titleSmall?.fontSize ??
                            14) *
                            1.1, // Slightly larger asterisk
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // --- DropdownButtonFormField Section ---
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null, // Disable onChanged if not enabled
          validator: validator,
          hint: hint,
          isExpanded: true, // Makes the dropdown take the available horizontal space
          elevation: dropdownElevation.toInt(),
          style: effectiveTextStyle?.copyWith(
            color: enabled ? effectiveTextStyle.color : Colors.grey, // Dim text when disabled
          ),
          dropdownColor: dropdownColor,
          borderRadius: dropdownBorderRadius,
          icon: suffixIcon, // Use custom icon if provided
          decoration: InputDecoration(
            // Apply custom borders or fall back to defaults
            enabledBorder: enabledBorder ?? defaultBorder,
            focusedBorder: focusedBorder ?? defaultFocusedBorder,
            disabledBorder: disabledBorder ?? defaultBorder.copyWith(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: errorBorder ?? defaultErrorBorder,
            focusedErrorBorder: focusedErrorBorder ?? defaultErrorBorder.copyWith(
              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            ),
            border: enabledBorder ?? defaultBorder, // General border
            isDense: true, // Reduces vertical padding
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            fillColor: fillColor ?? (enabled ? Colors.transparent : Colors.grey.shade100),
            filled: filled || !enabled, // Fill if explicitly set or disabled
            errorText: errorText, // Display external error text if provided
          ),
        ),
      ],
    );
  }
}
