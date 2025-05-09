import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nestle_waters_purelife/utils/helpers/helper_classes/country_code_data_helper.dart';

class NCountryCodePicker extends StatefulWidget {
  /// The currently selected country
  final CountryCodeData? selectedCountry;

  /// Callback function when a country is selected
  final Function(CountryCodeData) onCountrySelected;

  /// Whether to show label above the picker
  final bool showLabel;

  /// Label text to display
  final String? label;

  /// Style for the label text
  final TextStyle? labelStyle;

  /// List of countries to display
  final List<CountryCodeData> countries;

  /// Text to display when no country is selected
  final String initialText;

  /// Style for the selected country text
  final TextStyle? countryTextStyle;

  /// Color for the dropdown button
  final Color? dropdownColor;

  /// Border radius for the dropdown button
  final double borderRadius;

  /// Border color for the dropdown button
  final Color? borderColor;

  /// Width of the border
  final double borderWidth;

  /// Whether to show country flags
  final bool showFlags;

  /// Whether to show country codes
  final bool showCodes;

  /// Whether to show the dropdown border
  final bool showBorder;

  /// Background color of the dropdown button
  final Color? backgroundColor;

  /// Custom dropdown button decoration
  final BoxDecoration? customDecoration;

  /// Height of the dropdown button
  final double height;

  /// Width of the dropdown button (if null, will size to content)
  final double? width;

   NCountryCodePicker({
    Key? key,
    this.selectedCountry,
    required this.onCountrySelected,
    this.showLabel = true,
    this.label = 'Country',
    this.labelStyle,
    this.countries = CountryCodeDataHelper.countryCodeData,
    this.initialText = 'Country',
    this.countryTextStyle,
    this.dropdownColor,
    this.borderRadius = 8.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.showFlags = true,
    this.showCodes = true,
    this.showBorder = true,
    this.backgroundColor,
    this.customDecoration,
    this.height = 58.0,
    this.width,
  }) : super(key: key);

  @override
  State<NCountryCodePicker> createState() => _NCountryCodePickerState();
}

class _NCountryCodePickerState extends State<NCountryCodePicker> {
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
        // Dropdown button
        Container(
          height: widget.height,
          width: widget.width,
          decoration: widget.customDecoration ??
              (widget.showBorder
                  ? BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.borderColor ?? Colors.grey.shade400,
                  width: widget.borderWidth,
                ),
              )
                  : BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              )),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CountryCodeData>(
              value: widget.selectedCountry,
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              dropdownColor: widget.dropdownColor ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              hint: Text(
                widget.initialText,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              onChanged: (CountryCodeData? value) {
                if (value != null) {
                  widget.onCountrySelected(value);
                }
              },
              items: widget.countries.map<DropdownMenuItem<CountryCodeData>>((CountryCodeData country) {
                return DropdownMenuItem<CountryCodeData>(
                  value: country,
                  child: Row(
                    children: [
                      if (widget.showFlags) ...[
                        Text(
                          country.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          '${country.name} ${widget.showCodes ? '(${country.code})' : ''}',
                          style: widget.countryTextStyle ??
                              const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return widget.countries.map<Widget>((CountryCodeData country) {
                  return Row(
                    children: [
                      if (widget.showFlags) ...[
                        Text(
                          country.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.showCodes ? country.code : country.name,
                        style: widget.countryTextStyle ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ],
    );
  }
}
