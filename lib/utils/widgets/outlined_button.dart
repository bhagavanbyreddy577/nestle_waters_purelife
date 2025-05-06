import 'package:flutter/material.dart';

class NOutlinedButton extends StatelessWidget {

  /// The text displayed on the button. Required.
  final String text;

  /// Callback function executed when the button is tapped.
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Callback function executed when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// The color of the button's text (foreground) when enabled.
  /// Defaults to the theme's primary color.
  final Color? foregroundColor; // Renamed from textColor

  /// The background color of the button. Typically transparent for outlined buttons.
  final Color? backgroundColor;

  /// The color of the button's text and border when disabled.
  /// If null, Flutter's default disabled foreground color is used.
  final Color? disabledForegroundColor; // Renamed from disabledTextColor

  /// The background color when the button is disabled.
  /// If null, Flutter's default behavior is used (usually transparent).
  final Color? disabledBackgroundColor;

  /// The color of the button's border.
  /// If null, defaults to `foregroundColor` or theme's outline color.
  final Color? borderColor;

  /// The width of the button's border. Defaults to 1.0.
  final double? borderWidth;

  /// The style of the button's text.
  final TextStyle? textStyle;

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

  const NOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
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

    // Determine effective colors
    final effectiveForegroundColor = foregroundColor ?? colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? Colors.transparent; // Default transparent
    final effectiveDisabledForegroundColor = disabledForegroundColor ?? colorScheme.onSurface.withOpacity(0.38);
    final effectiveDisabledBackgroundColor = disabledBackgroundColor ?? Colors.transparent;

    // Use explicit border color if provided, otherwise fall back based on state
    final effectiveBorderColor = borderColor;

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
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
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
          // Use foreground color for overlay
          if (states.contains(WidgetState.pressed)) {
            return effectiveForegroundColor.withOpacity(0.12);
          }
          if (states.contains(WidgetState.focused)) {
            return effectiveForegroundColor.withOpacity(0.12);
          }
          return null; // Defer to the widget's default.
        },
      ),
      // Border Side
      side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) {
          Color currentBorderColor;
          if (states.contains(WidgetState.disabled)) {
            // Use disabled foreground color for border opacity, similar to default M3
            currentBorderColor = colorScheme.onSurface.withOpacity(0.12);
          } else {
            // Use explicit borderColor if available, otherwise use foreground color
            currentBorderColor = effectiveBorderColor ?? effectiveForegroundColor;
          }
          return BorderSide(
            color: currentBorderColor,
            width: borderWidth ?? 1.0,
          );
        },
      ),
      // Elevation (typically 0 for outlined buttons)
      elevation: WidgetStateProperty.all<double>(0.0),
      // Padding
      padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)),
      // Shape and Border Radius
      shape: WidgetStateProperty.all<OutlinedBorder>(
        shape ?? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Default border radius
        ),
      ),
      // Text Style (pass base style without color)
      textStyle: WidgetStateProperty.all<TextStyle?>(baseTextStyle.copyWith(color: null)),
      // Size Constraints
      minimumSize: WidgetStateProperty.all<Size?>(
        (minWidth != null || minHeight != null)
            ? Size(minWidth ?? 0, minHeight ?? 36.0)
            : const Size(0, 36.0),
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

    // Create the OutlinedButton
    Widget button = OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      onLongPress: isDisabled ? null : onLongPress,
      style: style,
      child: buttonChild,
    );

    // Apply fixed size constraints
    if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    // Apply margin
    if (margin != null) {
      return Padding(
        padding: margin!,
        child: button,
      );
    }

    return button;
  }
}