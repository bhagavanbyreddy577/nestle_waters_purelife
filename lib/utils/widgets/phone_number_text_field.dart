import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nestle_waters_purelife/utils/helpers/helper_classes/country_code_data_helper.dart';

class NPhoneNumberTextField extends StatefulWidget {
  /// Text editing controller to manage the text input
  final TextEditingController controller;

  /// The country associated with this phone number (for validation)
  final CountryCodeData? selectedCountry;

  /// Optional hint text displayed when the field is empty
  final String? hintText;

  /// Optional label/title text displayed above the text field
  final String? label;

  /// Whether to show the label/title
  final bool showLabel;

  /// Custom validation function that returns error message or null if valid
  final String? Function(String?, CountryCodeData?)? validator;

  /// Whether to show an icon on the left side of the text field
  final bool showLeftIcon;

  /// Icon to display on the left side (if showLeftIcon is true)
  final IconData? leftIcon;

  /// Whether to show an icon on the right side of the text field
  final bool showRightIcon;

  /// Icon to display on the right side (if showRightIcon is true)
  final IconData? rightIcon;

  /// Action when right icon is pressed
  final VoidCallback? onRightIconPressed;

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

  /// Whether to automatically format the phone number
  final bool autoFormat;

  const NPhoneNumberTextField({
    super.key,
    required this.controller,
    this.selectedCountry,
    this.hintText = 'Phone number',
    this.label = 'Phone Number',
    this.showLabel = true,
    this.validator,
    this.showLeftIcon = true,
    this.leftIcon = Icons.phone,
    this.showRightIcon = false,
    this.rightIcon = Icons.clear,
    this.onRightIconPressed,
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
    this.autoFormat = true,
  });

  @override
  State<NPhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<NPhoneNumberTextField> {
  String? _errorText;

  /// Validates the phone number based on the selected country rules
  String? _validatePhoneNumber(String? value, CountryCodeData? country) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (country == null) {
      return 'Please select a country first';
    }

    // Check for length requirements
    if (value.length < country.minLength) {
      return 'Phone number must be at least ${country.minLength} digits';
    }

    if (value.length > country.maxLength) {
      return 'Phone number cannot exceed ${country.maxLength} digits';
    }

    // Check for pattern match if pattern is provided
    if (country.pattern != null) {
      final RegExp regExp = RegExp(country.pattern!);
      if (!regExp.hasMatch(value)) {
        return 'Invalid phone number format for ${country.name}';
      }
    }

    return null;
  }

  /// Formats the phone number if autoFormat is enabled
  String _formatPhoneNumber(String value, CountryCodeData? country) {
    if (!widget.autoFormat || country == null || value.isEmpty) {
      return value;
    }

    // Basic formatting examples - can be customized per country
    switch (country.isoCode) {
      case 'US':
      case 'CA':
      // Format as: (XXX) XXX-XXXX
        if (value.length <= 3) {
          return value;
        } else if (value.length <= 6) {
          return '(${value.substring(0, 3)}) ${value.substring(3)}';
        } else {
          return '(${value.substring(0, 3)}) ${value.substring(3, 6)}-${value.substring(6, value.length.clamp(6, 10))}';
        }
      case 'IN':
      // Format as: XXXXX XXXXX
        if (value.length <= 5) {
          return value;
        } else {
          return '${value.substring(0, 5)} ${value.substring(5, value.length.clamp(5, 10))}';
        }
    // Add more country-specific formatting as needed
      default:
      // Default formatting in groups of 3
        if (value.length <= 3) {
          return value;
        } else if (value.length <= 6) {
          return '${value.substring(0, 3)} ${value.substring(3)}';
        } else {
          final parts = [];
          for (var i = 0; i < value.length; i += 3) {
            final end = (i + 3 < value.length) ? i + 3 : value.length;
            parts.add(value.substring(i, end));
          }
          return parts.join(' ');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show label if enabled
        if (widget.showLabel && widget.label != null)
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
        // Phone number text form field
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.phone,
          style: widget.textStyle,
          enabled: widget.enabled && widget.selectedCountry != null,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(
              widget.selectedCountry?.maxLength ?? 15,
            ),
          ],
          onChanged: (value) {
            if (widget.onChanged != null) {
              // Pass the raw digits to the onChanged callback
              widget.onChanged!(value.replaceAll(RegExp(r'[^\d]'), ''));
            }

            // Validate on change
            if (widget.validator != null) {
              setState(() {
                _errorText = widget.validator!(value, widget.selectedCountry);
              });
            } else {
              setState(() {
                _errorText = _validatePhoneNumber(value.replaceAll(RegExp(r'[^\d]'), ''), widget.selectedCountry);
              });
            }

            // If auto-formatting is enabled, format the phone number
            if (widget.autoFormat && value.isNotEmpty) {
              final rawDigits = value.replaceAll(RegExp(r'[^\d]'), '');
              final formatted = _formatPhoneNumber(rawDigits, widget.selectedCountry);

              if (formatted != value) {
                // Update the text field with formatted text
                widget.controller.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }
          },
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value, widget.selectedCountry);
            }
            return _validatePhoneNumber(value?.replaceAll(RegExp(r'[^\d]'), ''), widget.selectedCountry);
          },
          decoration: widget.customDecoration ??
              InputDecoration(
                hintText: widget.selectedCountry == null
                    ? 'Enter Phone Number'
                    : widget.hintText,
                hintStyle: widget.hintStyle ?? TextStyle(color: Colors.grey.shade500),
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
                suffixIcon: widget.showRightIcon && widget.rightIcon != null
                    ? IconButton(
                  icon: Icon(
                    widget.rightIcon,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: widget.onRightIconPressed,
                )
                    : null,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: widget.borderWidth,
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
