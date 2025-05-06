import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NTextField extends StatefulWidget {

  /// Optional text to display above the text field.
  final String? title;

  /// Custom style for the title text.
  final TextStyle? titleStyle;

  /// Whether to display a mandatory indicator (*) next to the title.
  /// Defaults to `false`.
  final bool isMandatory;

  /// The text displayed when the field is empty.
  final String? hintText;

  /// Custom style for the hint text.
  final TextStyle? hintStyle;

  /// An optional icon to display before the text input area.
  final Widget? prefixIcon;

  /// An optional icon to display after the text input area.
  final Widget? suffixIcon;

  /// Controls the text being edited.
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// The type of keyboard to use for editing the text.
  /// Defaults to [TextInputType.text].
  final TextInputType keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Whether the text field is enabled or disabled.
  /// Defaults to `true`.
  final bool enabled;

  /// Whether to hide the text being edited (e.g., for passwords).
  /// Defaults to `false`.
  final bool obscureText;

  /// An optional method that validates an input.
  /// Returns an error string to display if the input is invalid, or null otherwise.
  final FormFieldValidator<String>? validator;

  /// Called when the user initiates a change to the text field's value.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates that they are done editing the text in the field.
  final VoidCallback? onEditingComplete;

  /// Called when the user submits the text field's current value.
  final ValueChanged<String>? onSubmitted;

  /// The maximum number of lines the text field can occupy.
  /// Defaults to 1 (single line).
  final int? maxLines;

  /// Custom style for the text being edited.
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

  /// Optional input formatters to apply to the text field.
  final List<TextInputFormatter>? inputFormatters;

  const NTextField({
    super.key,
    this.title,
    this.titleStyle,
    this.isMandatory = false,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.enabled = true,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.maxLines = 1,
    this.textStyle,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.fillColor,
    this.filled = false,
    this.contentPadding,
    this.inputFormatters,
  });

  @override
  State<NTextField> createState() => _NTextFieldState();
}

class _NTextFieldState extends State<NTextField> {

  // If no controller is provided, create a local one.
  late final TextEditingController _controller;
  bool _isInitialized = false; // To ensure controller is initialized only once

  @override
  void initState() {
    super.initState();
    // Initialize the controller only if it wasn't provided externally
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isInitialized = true; // Mark as initialized locally
    }
  }

  @override
  void dispose() {
    // Dispose the local controller only if it was created here
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Use the provided controller or the local one
    final effectiveController = widget.controller ?? _controller;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Take minimum vertical space
      children: [
        // --- Title Section ---
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0), // Space below title
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title!,
                  style: widget.titleStyle ??
                      textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.enabled
                            ? colorScheme.onSurface
                            : Colors.grey, // Dim title when disabled
                      ),
                ),
                if (widget.isMandatory)
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: colorScheme.error, // Use error color for '*'
                        fontSize: (widget.titleStyle?.fontSize ??
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

        // --- TextFormField Section ---
        TextFormField(
          controller: effectiveController,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted, // Use onFieldSubmitted for Form
          maxLines: widget.obscureText ? 1 : widget.maxLines, // MaxLines=1 for password
          style: widget.textStyle ?? textTheme.bodyLarge,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            // Apply custom borders or fall back to defaults
            enabledBorder: widget.enabledBorder ?? defaultBorder,
            focusedBorder: widget.focusedBorder ?? defaultFocusedBorder,
            disabledBorder: widget.disabledBorder ?? defaultBorder.copyWith(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: widget.errorBorder ?? defaultErrorBorder,
            focusedErrorBorder: widget.focusedErrorBorder ?? defaultErrorBorder.copyWith(
              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            ),
            border: widget.enabledBorder ?? defaultBorder, // General border
            isDense: true, // Reduces vertical padding
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            fillColor: widget.fillColor ?? (widget.enabled ? Colors.transparent : Colors.grey.shade100),
            filled: widget.filled || !widget.enabled, // Fill if explicitly set or disabled
          ),
        ),
      ],
    );
  }
}
