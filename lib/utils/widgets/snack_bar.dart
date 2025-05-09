import 'package:flutter/material.dart';

enum SnackBarType {

  /// Standard information snackbar
  info,

  /// Success message snackbar
  success,

  /// Warning message snackbar
  warning,

  /// Error message snackbar
  error,

  /// Custom themed snackbar
  custom,
}


class NSnackBar {

  /// The [BuildContext] is needed to show the snackbar
  final BuildContext context;

  /// The message to display in the snackbar
  final String message;

  /// The type of snackbar to display, defaults to [SnackBarType.info]
  final SnackBarType type;

  /// Duration to show the snackbar, defaults to 4 seconds
  final Duration duration;

  /// Optional action text to display
  final String? actionLabel;

  /// Optional callback when action is pressed
  final VoidCallback? onActionPressed;

  /// Optional icon to display at the start of the snackbar
  final IconData? icon;

  /// Optional background color that overrides the default color for the type
  final Color? backgroundColor;

  /// Optional text color that overrides the default color for the type
  final Color? textColor;

  /// Optional margin around the snackbar
  final EdgeInsets? margin;

  /// Optional padding inside the snackbar
  final EdgeInsets? padding;

  /// Optional border radius for the snackbar
  final double? borderRadius;

  /// Optional elevation for the snackbar
  final double? elevation;

  /// Optional behavior for how the snackbar should be positioned
  final SnackBarBehavior? behavior;

  /// Optional dismiss direction
  final DismissDirection? dismissDirection;

  /// Creates a new instance of [NSnackBar]
  NSnackBar({
    required this.context,
    required this.message,
    this.type = SnackBarType.info,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onActionPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.margin,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.behavior,
    this.dismissDirection,
  });

  /// Shows the snackbar
  void show() {
    // Get theme data for current context
    final theme = Theme.of(context);

    // Set default values based on type
    final defaultValues = _getDefaultValues(theme);

    // Create and show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Optional icon
            if (icon != null || defaultValues.icon != null) ...[
              Icon(
                icon ?? defaultValues.icon,
                color: textColor ?? defaultValues.contentColor,
              ),
              const SizedBox(width: 12),
            ],
            // Message text
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? defaultValues.contentColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? defaultValues.backgroundColor,
        duration: duration,
        margin: margin,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        behavior: behavior ?? SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        elevation: elevation ?? 6,
        dismissDirection: dismissDirection ?? DismissDirection.down,
        action: actionLabel != null
            ? SnackBarAction(
          label: actionLabel!,
          textColor: textColor ?? defaultValues.actionColor,
          onPressed: onActionPressed ?? () {},
        )
            : null,
      ),
    );
  }

  /// Returns default values for the snackbar based on its type
  _SnackBarDefaults _getDefaultValues(ThemeData theme) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarDefaults(
          backgroundColor: Colors.green[800]!,
          contentColor: Colors.white,
          actionColor: Colors.green[100]!,
          icon: Icons.check_circle,
        );
      case SnackBarType.warning:
        return _SnackBarDefaults(
          backgroundColor: Colors.amber[800]!,
          contentColor: Colors.white,
          actionColor: Colors.amber[100]!,
          icon: Icons.warning,
        );
      case SnackBarType.error:
        return _SnackBarDefaults(
          backgroundColor: Colors.red[800]!,
          contentColor: Colors.white,
          actionColor: Colors.red[100]!,
          icon: Icons.error,
        );
      case SnackBarType.info:
        return _SnackBarDefaults(
          backgroundColor: Colors.blue[800]!,
          contentColor: Colors.white,
          actionColor: Colors.blue[100]!,
          icon: Icons.info,
        );
      case SnackBarType.custom:
        return _SnackBarDefaults(
          backgroundColor: theme.colorScheme.secondary,
          contentColor: theme.colorScheme.onSecondary,
          actionColor: theme.colorScheme.onSecondary,
          icon: null,
        );
    }
  }
}

/// Helper class to store default values for each snackbar type
class _SnackBarDefaults {
  final Color backgroundColor;
  final Color contentColor;
  final Color actionColor;
  final IconData? icon;

  _SnackBarDefaults({
    required this.backgroundColor,
    required this.contentColor,
    required this.actionColor,
    this.icon,
  });
}

/// Extension methods for BuildContext to show snackbars more easily
extension ShowSnackBarExt on BuildContext {
  /// Shows an info snackbar
  void showInfoSnackBar(String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    NSnackBar(
      context: this,
      message: message,
      type: SnackBarType.info,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      margin: margin,
      padding: padding,
    ).show();
  }

  /// Shows a success snackbar
  void showSuccessSnackBar(String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    NSnackBar(
      context: this,
      message: message,
      type: SnackBarType.success,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      margin: margin,
      padding: padding,
    ).show();
  }

  /// Shows a warning snackbar
  void showWarningSnackBar(String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    NSnackBar(
      context: this,
      message: message,
      type: SnackBarType.warning,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      margin: margin,
      padding: padding,
    ).show();
  }

  /// Shows an error snackbar
  void showErrorSnackBar(String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    NSnackBar(
      context: this,
      message: message,
      type: SnackBarType.error,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      margin: margin,
      padding: padding,
    ).show();
  }

  /// Shows a custom snackbar
  void showCustomSnackBar(String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    double? elevation,
    SnackBarBehavior? behavior,
    DismissDirection? dismissDirection,
  }) {
    NSnackBar(
      context: this,
      message: message,
      type: SnackBarType.custom,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      elevation: elevation,
      behavior: behavior,
      dismissDirection: dismissDirection,
    ).show();
  }
}

/// TODO: Example usage of the CustomSnackBar widget (Need to remove in production)
/*
* CustomSnackBar(
                      context: context,
                      message: "This is an information message",
                      type: SnackBarType.info,
                    ).show();

* */
/// TODO: Example usage of the CustomSnackBar widget with extension (Need to remove in production)
/*
* context.showInfoSnackBar("Info via extension method");
* */