import 'package:flutter/material.dart';

class NIcon extends StatelessWidget {
  /// The widget to use as the icon. Typically an [Icon] widget.
  final Widget icon;

  /// The callback that is called when the button is tapped.
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Text that describes the action that will occur when the button is pressed.
  /// This is displayed when the user long-presses on the button and is
  /// important for accessibility.
  final String? tooltip;

  /// The background color of the button.
  /// Defaults to `Colors.transparent`.
  final Color backgroundColor;

  /// The color to use for the icon when the button is enabled.
  /// If the [icon] widget has its own color, this might be overridden
  /// unless the [icon] widget defers to the [IconTheme].
  /// Defaults to the current [IconThemeData.color].
  final Color? foregroundColor;

  /// The background color of the button when it is disabled ([onPressed] is null).
  /// Defaults to the [backgroundColor] with reduced opacity or a theme-specific disabled color.
  final Color? disabledBackgroundColor;

  /// The color to use for the icon when the button is disabled.
  /// Defaults to the theme's disabled color.
  final Color? disabledForegroundColor;

  /// The splash color for the ink response.
  /// Defaults to the theme's splash color.
  final Color? splashColor;

  /// The highlight color for the ink response when tapped.
  /// Defaults to the theme's highlight color.
  final Color? highlightColor;

  /// The padding around the icon.
  /// Defaults to `EdgeInsets.all(8.0)`.
  final EdgeInsetsGeometry padding;

  /// The shape of the button.
  /// This can include a [BorderSide] to define a border.
  /// For example, `CircleBorder(side: BorderSide(color: Colors.blue, width: 2.0))`.
  /// Defaults to `CircleBorder()`.
  final ShapeBorder shape;

  /// The elevation of the button, affecting its shadow.
  /// Defaults to `0.0`.
  final double elevation;

  /// Defines the button's size constraints.
  final BoxConstraints? constraints;

  /// An optional focus node to manage the button's focus.
  final FocusNode? focusNode;

  /// Whether this button should autofocus.
  /// Defaults to `false`.
  final bool autofocus;

  /// Creates a customizable icon button.
  const NIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.splashColor,
    this.highlightColor,
    this.padding = const EdgeInsets.all(8.0),
    this.shape = const CircleBorder(),
    this.elevation = 0.0,
    this.constraints,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEnabled = onPressed != null;

    // Determine effective colors based on enabled state and theme defaults
    final Color effectiveBackgroundColor = isEnabled
        ? backgroundColor
        : disabledBackgroundColor ??
        (backgroundColor == Colors.transparent
            ? Colors.transparent
            : theme.disabledColor.withOpacity(0.12));

    final Color effectiveForegroundColor = isEnabled
        ? foregroundColor ?? theme.iconTheme.color ?? Colors.black
        : disabledForegroundColor ?? theme.disabledColor;

    final Color effectiveSplashColor =
        splashColor ?? theme.splashColor;
    final Color effectiveHighlightColor =
        highlightColor ?? theme.highlightColor;

    Widget buttonContent = Padding(
      padding: padding,
      child: IconTheme.merge(
        data: IconThemeData(
          color: effectiveForegroundColor,
          // The size of the icon should ideally be set on the Icon widget itself.
          // If you want to enforce a size here, you could add an `iconSize` property.
        ),
        child: icon,
      ),
    );

    // Apply constraints if provided
    if (constraints != null) {
      buttonContent = ConstrainedBox(
        constraints: constraints!,
        child: buttonContent,
      );
    }

    // The main button structure using Material for elevation and shape,
    // and InkWell for tap effects.
    Widget result = Material(
      color: effectiveBackgroundColor,
      shape: shape,
      elevation: elevation,
      clipBehavior: Clip.antiAlias, // Ensures the ink splash is clipped to the shape
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        splashColor: effectiveSplashColor,
        highlightColor: effectiveHighlightColor,
        customBorder: shape, // Ensures ink ripple conforms to the custom shape
        focusNode: focusNode,
        autofocus: autofocus,
        canRequestFocus: isEnabled,
        child: buttonContent,
      ),
    );

    // Wrap with Tooltip if provided
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return result;
  }
}