import 'package:flutter/material.dart';

class NText extends StatelessWidget {

  /// The text to display.  This is the only required parameter.
  final String text;

  /// The style to apply to the text.
  ///
  /// If null, the default text style from the current theme is used.
  /// You can override specific properties of the default style using other parameters
  /// like [fontSize], [fontWeight], [color], etc.
  final TextStyle? style;

  /// The color of the text.
  ///
  /// Overrides the color specified in [style], if any.
  final Color? color;

  /// The font size of the text.
  ///
  /// Overrides the font size specified in [style], if any.
  final double? fontSize;

  /// The font weight of the text.
  ///
  /// Overrides the font weight specified in [style], if any.
  final FontWeight? fontWeight;

  /// The font family of the text.
  ///
  /// Overrides the font family specified in [style], if any.
  final String? fontFamily;

  /// The background color of the text.
  final Color? backgroundColor;

  /// The decoration to apply to the text (e.g., underline, line through).
  ///
  /// Overrides the decoration specified in [style], if any.
  final TextDecoration? decoration;

  /// The style of the text decoration (e.g., solid, dashed, dotted).
  ///
  /// Only effective if [decoration] is not null.  Overrides the decoration style
  /// specified in [style], if any.
  final TextDecorationStyle? decorationStyle;

  /// The color of the text decoration.
  ///
  /// Only effective if [decoration] is not null. Overrides the decoration color
  /// specified in [style], if any.
  final Color? decorationColor;

  /// The height of each line of text, as a multiple of the font size.
  final double? height;

  /// The amount of space (in logical pixels) to add between each letter.
  final double? letterSpacing;

  /// The amount of space (in logical pixels) to add at each edge of the text.
  final EdgeInsetsGeometry? padding;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The maximum number of lines for the text to span.
  ///
  /// If the text exceeds this number of lines, it will be truncated according to
  /// the [overflow] property.
  final int? maxLines;

  /// How visual overflow should be handled.
  ///
  /// Defaults to [TextOverflow.clip].
  final TextOverflow? overflow;

  /// The shape of the background.
  ///
  /// If null, the background is rectangular.  If [borderRadius] is also provided,
  /// the background will be a rounded rectangle.
  final BoxShape? shape;

  /// The border to draw around the text.
  final Border? border;

  /// The radius of the background.
  ///
  /// Only effective if [shape] is [BoxShape.rectangle].
  final BorderRadius? borderRadius;

  /// Creates a new CustomText widget.
  const NText({
    super.key,
    required this.text,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.backgroundColor,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
    this.height,
    this.letterSpacing,
    this.padding,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.shape,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Start with the base text style, either from the provided style or the theme.
    TextStyle? textStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    // Override individual properties if they are provided.
    if (color != null) {
      textStyle = textStyle?.copyWith(color: color);
    }
    if (fontSize != null) {
      textStyle = textStyle?.copyWith(fontSize: fontSize);
    }
    if (fontWeight != null) {
      textStyle = textStyle?.copyWith(fontWeight: fontWeight);
    }
    if (fontFamily != null) {
      textStyle = textStyle?.copyWith(fontFamily: fontFamily);
    }
    if (decoration != null) {
      textStyle = textStyle?.copyWith(decoration: decoration);
    }
    if (decorationStyle != null) {
      textStyle = textStyle?.copyWith(decorationStyle: decorationStyle);
    }
    if (decorationColor != null) {
      textStyle = textStyle?.copyWith(decorationColor: decorationColor);
    }
    if (height != null) {
      textStyle = textStyle?.copyWith(height: height);
    }
    if (letterSpacing != null) {
      textStyle = textStyle?.copyWith(letterSpacing: letterSpacing);
    }

    // Build the container that will hold the text and apply background styling.
    Widget content = Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Use a Container for background color, shape, and border.
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: shape ?? BoxShape.rectangle, // Default to rectangle if not provided
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null, // Only apply if it is a rectangle
        border: border,
      ),
      child: content,
    );
  }
}