import 'package:flutter/material.dart';

class NTextStyles {

  // Private constructor to prevent instantiation
  NTextStyles._();

  /// Base text theme configuration
  static const String _defaultFontFamily = 'Roboto';

  /// Method to get a custom text style with optional overrides
  static TextStyle _getTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    String? fontFamily,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? _defaultFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // Heading Styles
  static TextStyle get headingLarge => _getTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle get headingMedium => _getTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get headingSmall => _getTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  // Body Text Styles
  static TextStyle get bodyLarge => _getTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  static TextStyle get bodyMedium => _getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  static TextStyle get bodySmall => _getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  // Button Text Styles
  static TextStyle get buttonLarge => _getTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  static TextStyle get buttonMedium => _getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 1.1,
  );

  static TextStyle get buttonSmall => _getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 1.0,
  );

  // Caption and Helper Text Styles
  static TextStyle get captionText => _getTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black38,
  );

  static TextStyle get subtitleText => _getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  // Link and Special Text Styles
  static TextStyle get linkText => _getTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  static TextStyle get errorText => _getTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.red,
  );

  // Utility method to create a custom text style with easy overrides
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
    String? fontFamily,
  }) {
    return _getTextStyle(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontFamily: fontFamily,
    );
  }
}

/// TODO: Usage example (Need to remove in production

/*
* Text('Error Text', style: NTextStyles.errorText)

            // Custom Text Style Example
            Text(
              'Custom Text Style',
              style: NTextStyles.custom(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.purple,
              )
            ),
            * */