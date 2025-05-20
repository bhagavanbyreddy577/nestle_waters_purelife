import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/utils/helpers/helper_classes/country_code_data_helper.dart';
import 'package:nestle_waters_purelife/utils/widgets/country_code_picker.dart';
import 'package:nestle_waters_purelife/utils/widgets/phone_number_text_field.dart';

class NPhoneInputWidget extends StatefulWidget {
  /// Controller for the phone number text field
  final TextEditingController phoneController;

  /// Whether to show labels for both fields
  final bool showLabels;

  /// Label for the country picker
  final String? countryLabel;

  /// Label for the phone field
  final String? phoneLabel;

  /// Text styles for labels
  final TextStyle? labelStyle;

  /// Whether to show the country flag
  final bool showFlag;

  /// Whether to show country codes
  final bool showCountryCode;

  /// Whether to show left icon in phone field
  final bool showLeftIcon;

  /// Left icon for phone field
  final IconData? leftIcon;

  /// Whether to show right icon in phone field
  final bool showRightIcon;

  /// Right icon for phone field
  final IconData? rightIcon;

  /// Action when right icon is pressed
  final VoidCallback? onRightIconPressed;

  /// Spacing between the country picker and phone field
  final double spacing;

  /// Border radius for both fields
  final double borderRadius;

  /// Border color for both fields
  final Color? borderColor;

  /// Fill color for both fields
  final Color? fillColor;

  /// Initially selected country
  final CountryCodeData? initialCountry;

  /// Custom list of countries to show in picker
  final List<CountryCodeData> countries;

  /// Callback when valid phone number is entered
  final void Function(String, CountryCodeData)? onPhoneNumberChanged;

  /// Whether to automatically format the phone number
  final bool autoFormat;

  /// Validation mode
  final AutovalidateMode? validationMode;

  /// Text styles for input fields
  final TextStyle? inputTextStyle;

  /// Width ratio for country picker (0.0 to 1.0)
  final double countryPickerWidthRatio;

  /// Initial text to show in country picker
  final String initialCountryText;

  /// Whether the text field is enabled
  final bool enabled;

  const NPhoneInputWidget({
    super.key,
    required this.phoneController,
    this.showLabels = true,
    this.countryLabel = 'Country',
    this.phoneLabel = 'Phone Number',
    this.labelStyle,
    this.showFlag = true,
    this.showCountryCode = true,
    this.showLeftIcon = true,
    this.leftIcon = Icons.phone,
    this.showRightIcon = false,
    this.rightIcon = Icons.clear,
    this.onRightIconPressed,
    this.spacing = 12.0,
    this.borderRadius = 8.0,
    this.borderColor,
    this.fillColor,
    this.initialCountry,
    this.countries = CountryCodeDataHelper.countryCodeData,
    this.onPhoneNumberChanged,
    this.autoFormat = true,
    this.validationMode,
    this.inputTextStyle,
    this.countryPickerWidthRatio = 0.35,
    this.initialCountryText = 'Country',
    this.enabled = true,
  });

  @override
  State<NPhoneInputWidget> createState() => _NPhoneInputWidgetState();
}

class _NPhoneInputWidgetState extends State<NPhoneInputWidget> {
  CountryCodeData? _selectedCountry;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.validationMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country code picker
              SizedBox(
                width: MediaQuery.of(context).size.width * widget.countryPickerWidthRatio,
                child: NCountryCodePicker(
                  selectedCountry: _selectedCountry,
                  onCountrySelected: (country) {
                    setState(() {
                      _selectedCountry = country;
                      // Clear the phone field when country changes
                      widget.phoneController.clear();
                    });
                  },
                  showLabel: widget.showLabels,
                  label: widget.countryLabel,
                  labelStyle: widget.labelStyle,
                  countries: widget.countries,
                  initialText: widget.initialCountryText,
                  countryTextStyle: widget.inputTextStyle,
                  borderColor: widget.borderColor,
                  borderRadius: widget.borderRadius,
                  showFlags: widget.showFlag,
                  showCodes: widget.showCountryCode,
                  backgroundColor: widget.fillColor,
                ),
              ),
              SizedBox(width: widget.spacing),
              // Phone number text field
              Expanded(
                child: NPhoneNumberTextField(
                  controller: widget.phoneController,
                  selectedCountry: _selectedCountry,
                  showLabel: widget.showLabels,
                  label: widget.phoneLabel,
                  labelStyle: widget.labelStyle,
                  showLeftIcon: widget.showLeftIcon,
                  leftIcon: widget.leftIcon,
                  showRightIcon: widget.showRightIcon,
                  rightIcon: widget.rightIcon,
                  onRightIconPressed: widget.onRightIconPressed ?? () {
                    widget.phoneController.clear();
                  },
                  borderRadius: widget.borderRadius,
                  borderColor: widget.borderColor,
                  fillColor: widget.fillColor,
                  textStyle: widget.inputTextStyle,
                  autoFormat: widget.autoFormat,
                  enabled: widget.enabled,
                  onChanged: (value) {
                    if (widget.onPhoneNumberChanged != null && _selectedCountry != null) {
                      final isValid = _formKey.currentState?.validate() ?? false;
                      if (isValid) {
                        widget.onPhoneNumberChanged!(value, _selectedCountry!);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
