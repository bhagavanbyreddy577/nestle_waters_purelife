import 'package:flutter/material.dart';

class NElevatedButton extends StatelessWidget {

  /// The text displayed on the button. Required.
  final String text;

  /// Callback function executed when the button is tapped.
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Callback function executed when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// The color of the button's background (fill).
  final Color? backgroundColor;

  /// The color of the button's text when enabled.
  final Color? foregroundColor; // Renamed from textColor for consistency

  /// The color of the button's background when disabled.
  /// If null, Flutter's default disabled color is used.
  final Color? disabledBackgroundColor;

  /// The color of the button's text when disabled.
  /// If null, Flutter's default disabled foreground color is used.
  final Color? disabledForegroundColor;

  /// The style of the button's text.
  final TextStyle? textStyle;

  /// The elevation of the button (shadow).
  final double? elevation;

  /// The color of the button's shadow.
  final Color? shadowColor;

  /// The padding inside the button, around the text.
  final EdgeInsetsGeometry? padding;

  /// The margin around the button.
  final EdgeInsetsGeometry? margin;

  /// The shape of the button, including border radius.
  /// Defaults to a rounded rectangle.
  final OutlinedBorder? shape;

  /// The width of the button. If null, it sizes to content plus padding.
  final double? width;

  /// The height of the button. If null, it sizes to content plus padding.
  final double? height;

  /// The minimum width constraint for the button.
  final double? minWidth;

  /// The minimum height constraint for the button.
  final double? minHeight;

  /// Determines if the button is enabled or disabled.
  /// Defaults to true if [onPressed] is not null, false otherwise.
  final bool enabled;

  const NElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.textStyle,
    this.elevation,
    this.shadowColor,
    this.padding,
    this.margin,
    this.shape,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {

    final bool isDisabled = !enabled || onPressed == null;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Determine effective colors based on provided values and theme defaults
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
    final effectiveDisabledBackgroundColor = disabledBackgroundColor ?? colorScheme.onSurface.withOpacity(0.12);
    final effectiveDisabledForegroundColor = disabledForegroundColor ?? colorScheme.onSurface.withOpacity(0.38);

    // Determine effective text style
    final baseTextStyle = textStyle ?? theme.textTheme.labelLarge ?? const TextStyle();

    // Apply the correct color based on state
    final finalTextStyle = baseTextStyle.copyWith(
      color: isDisabled ? effectiveDisabledForegroundColor : effectiveForegroundColor,
    );

    // Build the button's child content (Text Only)
    Widget buttonChild = Text(
      text,
      style: finalTextStyle, // Use the final calculated text style
      overflow: TextOverflow.ellipsis, // Prevent text overflow
      textAlign: TextAlign.center, // Center text within button constraints
    );

    // Define ButtonStyle
    final ButtonStyle style = ButtonStyle(
      // Colors
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return effectiveDisabledBackgroundColor;
          }
          return effectiveBackgroundColor;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return effectiveDisabledForegroundColor;
          }
          return effectiveForegroundColor;
        },
      ),
      // Overlay color for ripple effect
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            // Use foreground color for overlay, common practice
            return effectiveForegroundColor.withOpacity(0.12);
          }
          if (states.contains(WidgetState.focused)) {
            return effectiveForegroundColor.withOpacity(0.12);
          }
          return null; // Defer to the widget's default.
        },
      ),
      // Elevation and Shadow
      elevation: WidgetStateProperty.resolveWith<double?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) return 0;
            if (states.contains(WidgetState.pressed)) return (elevation ?? 2.0) + 4.0; // Increase elevation when pressed
            return elevation ?? 2.0; // Default elevation
          }
      ),
      shadowColor: WidgetStateProperty.all<Color?>(shadowColor ?? theme.shadowColor),
      // Padding
      padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)), // Adjusted vertical padding slightly for text-only
      // Shape and Border Radius
      shape: WidgetStateProperty.all<OutlinedBorder>(
        shape ?? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Default border radius
        ),
      ),
      // Text Style (applied via foregroundColor and also base style if needed)
      // ButtonStyle.textStyle applies *base* style properties, color is handled by foregroundColor
      textStyle: WidgetStateProperty.all<TextStyle?>(baseTextStyle.copyWith(color: null)), // Pass base style without color here
      // Size Constraints
      minimumSize: WidgetStateProperty.all<Size?>(
        (minWidth != null || minHeight != null)
            ? Size(minWidth ?? 0, minHeight ?? 36.0) // Default min height
            : const Size(0, 36.0), // Ensure a minimum tappable height
      ),
      fixedSize: WidgetStateProperty.all<Size?>(
        (width != null || height != null)
            ? Size(width ?? double.infinity, height ?? double.infinity)
            : null,
      ),
      maximumSize: WidgetStateProperty.all<Size?>(
        (width != null || height != null)
            ? Size(width ?? double.infinity, height ?? double.infinity)
            : null,
      ),
      // Taps, splashes
      enableFeedback: true,
      splashFactory: InkRipple.splashFactory,
    );

    // Create the ElevatedButton
    Widget button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      onLongPress: isDisabled ? null : onLongPress,
      style: style,
      child: buttonChild,
    );

    // Apply fixed size constraints if width or height is provided directly
    // ButtonStyle fixedSize is often preferred, but this allows direct override
    if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    // Apply margin if provided
    if (margin != null) {
      return Padding(
        padding: margin!,
        child: button,
      );
    }

    return button;
  }
}