import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/utils/validators/validation.dart';

class NEmailTextField extends StatefulWidget {

  /// Text editing controller to manage the text input
  final TextEditingController emailController;

  /// Optional hint text displayed when the field is empty
  final String? hintText;

  /// Optional label/title text displayed above the text field
  final String? label;

  /// Whether to show the label/title
  final bool showLabel;

  /// Custom validation function that returns error message or null if valid
  final String? Function(String?)? validator;

  /// Whether to show an icon on the left side of the text field
  final bool showLeftIcon;

  /// Icon to display on the left side (if showLeftIcon is true)
  final IconData? leftIcon;

  /// The type of keyboard to use for editing the text
  final TextInputType keyboardType;

  /// Callback triggered when the text changes
  final void Function(String)? onChanged;

  /// Style for the hint text
  final TextStyle? hintStyle;

  /// Style for the label text
  final TextStyle? labelStyle;

  /// Style for the input text
  final TextStyle? textStyle;

  /// Custom decoration to override the default decoration
  final InputDecoration? customDecoration;

  /// Padding within the text field
  final EdgeInsetsGeometry? contentPadding;

  /// Background color of the text field
  final Color? fillColor;

  /// Color of the border
  final Color? borderColor;

  /// Border radius for the text field
  final double borderRadius;

  /// Width of the border
  final double borderWidth;

  /// Error text to display (alternative to using validator)
  final String? errorText;

  /// Whether the text field is enabled
  final bool enabled;

  const NEmailTextField({
    super.key,
    required this.emailController,
    this.hintText = 'Enter your email',
    this.label = 'Email',
    this.showLabel = true,
    this.validator,
    this.showLeftIcon = false,
    this.leftIcon = Icons.email,
    this.keyboardType = TextInputType.emailAddress,
    this.onChanged,
    this.hintStyle,
    this.labelStyle,
    this.textStyle,
    this.customDecoration,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<NEmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<NEmailTextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show label if it exists and showLabel is true
        if (widget.label != null && widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: widget.labelStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        // Email text form field with all the customized properties
        TextFormField(
          controller: widget.emailController,
          keyboardType: widget.keyboardType,
          style: widget.textStyle,
          enabled: widget.enabled,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }

            // Validate on change if validator is provided
            if (widget.validator != null) {
              setState(() {
                _errorText = widget.validator!(value);
              });
            } else {
              setState(() {
                _errorText = NValidator.validateEmail(value);
              });
            }
          },
          validator: widget.validator ?? NValidator.validateEmail,
          decoration: widget.customDecoration ??
              InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle,
                errorText: widget.errorText ?? _errorText,
                filled: widget.fillColor != null,
                fillColor: widget.fillColor,
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: widget.showLeftIcon ? 12.0 : 16.0,
                      vertical: 16.0,
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Colors.grey.shade400,
                    width: widget.borderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Colors.grey.shade400,
                    width: widget.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Theme.of(context).colorScheme.primary,
                    width: widget.borderWidth + 0.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: Colors.red.shade700,
                    width: widget.borderWidth,
                  ),
                ),
                prefixIcon: widget.showLeftIcon && widget.leftIcon != null
                    ? Icon(
                  widget.leftIcon,
                  color: Colors.grey.shade600,
                )
                    : null,
              ),
        ),
      ],
    );
  }
}

