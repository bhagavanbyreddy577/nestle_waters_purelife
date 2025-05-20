import 'package:flutter/material.dart';

enum AlertDialogType {

  /// Basic alert dialog with title, message, and action buttons
  basic,

  /// Alert dialog with a single choice list
  singleChoice,

  /// Alert dialog with a multiple choice list (checkboxes)
  multipleChoice,

  /// Alert dialog with a form for user input
  form,

  /// Alert dialog with success message and icon
  success,

  /// Alert dialog with error message and icon
  error,

  /// Alert dialog with warning message and icon
  warning,

  /// Alert dialog with loading indicator
  loading,

  /// Alert dialog with completely custom content
  custom,
}

class NAlertDialog extends StatefulWidget {

  /// The type of alert dialog to display
  final AlertDialogType type;

  /// Title displayed at the top of the alert dialog
  final String title;

  /// Optional subtitle displayed below the title
  final String? subtitle;

  /// Main content or message of the alert dialog
  final String? message;

  /// Background color of the alert dialog
  final Color? backgroundColor;

  /// Text color for the title and other text elements
  final Color? textColor;

  /// Whether to show a close icon at the top right
  final bool showCloseButton;

  /// Callback when the dialog is dismissed
  final VoidCallback? onDismiss;

  /// Width of the dialog as fraction of screen width (0.0 to 1.0)
  final double widthFactor;

  /// For [AlertDialogType.basic], list of action buttons to display
  final List<Widget>? actions;

  /// For [AlertDialogType.singleChoice], the list of items to choose from
  final List<String>? items;

  /// For [AlertDialogType.singleChoice], callback when an item is selected
  final void Function(String, int)? onItemSelected;

  /// For [AlertDialogType.singleChoice], initially selected item index
  final int? initialSelectedIndex;

  /// For [AlertDialogType.multipleChoice], initially selected items
  final List<bool>? initialSelectedItems;

  /// For [AlertDialogType.multipleChoice], callback when selection changes
  final void Function(List<bool>)? onMultiSelect;

  /// For [AlertDialogType.form], list of form fields to display
  final List<Widget>? formFields;

  /// For [AlertDialogType.form], callback when form is submitted
  final VoidCallback? onFormSubmit;

  /// For [AlertDialogType.form], submit button text
  final String submitButtonText;

  /// For [AlertDialogType.success/error/warning], icon to display
  final IconData? icon;

  /// For [AlertDialogType.success/error/warning], icon color
  final Color? iconColor;

  /// For [AlertDialogType.loading], loading indicator text
  final String loadingText;

  /// For [AlertDialogType.custom], a completely custom widget
  final Widget? customWidget;

  /// Border radius for the alert dialog corners
  final double borderRadius;

  /// Whether clicking outside the dialog dismisses it
  final bool barrierDismissible;

  /// Function to execute on primary action (like OK, Submit, etc.)
  final VoidCallback? onPrimaryAction;

  /// Function to execute on secondary action (like Cancel, No, etc.)
  final VoidCallback? onSecondaryAction;

  /// Text for the primary action button
  final String primaryActionText;

  /// Text for the secondary action button
  final String secondaryActionText;

  /// Constructor for CustomAlertDialog
  const NAlertDialog({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
    this.message,
    this.backgroundColor,
    this.textColor,
    this.showCloseButton = true,
    this.onDismiss,
    this.widthFactor = 0.85,
    this.actions,
    this.items,
    this.onItemSelected,
    this.initialSelectedIndex,
    this.initialSelectedItems,
    this.onMultiSelect,
    this.formFields,
    this.onFormSubmit,
    this.submitButtonText = 'Submit',
    this.icon,
    this.iconColor,
    this.loadingText = 'Loading...',
    this.customWidget,
    this.borderRadius = 8.0,
    this.barrierDismissible = true,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryActionText = 'OK',
    this.secondaryActionText = 'Cancel',
  });

  @override
  State<NAlertDialog> createState() => _NAlertDialogState();

  /// Static method to show the alert dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required AlertDialogType type,
    required String title,
    String? subtitle,
    String? message,
    Color? backgroundColor,
    Color? textColor,
    bool showCloseButton = true,
    VoidCallback? onDismiss,
    double widthFactor = 0.85,
    List<Widget>? actions,
    List<String>? items,
    void Function(String, int)? onItemSelected,
    int? initialSelectedIndex,
    List<bool>? initialSelectedItems,
    void Function(List<bool>)? onMultiSelect,
    List<Widget>? formFields,
    VoidCallback? onFormSubmit,
    String submitButtonText = 'Submit',
    IconData? icon,
    Color? iconColor,
    String loadingText = 'Loading...',
    Widget? customWidget,
    double borderRadius = 8.0,
    bool barrierDismissible = true,
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
    String primaryActionText = 'OK',
    String secondaryActionText = 'Cancel',
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => NAlertDialog(
        type: type,
        title: title,
        subtitle: subtitle,
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        showCloseButton: showCloseButton,
        onDismiss: onDismiss,
        widthFactor: widthFactor,
        actions: actions,
        items: items,
        onItemSelected: onItemSelected,
        initialSelectedIndex: initialSelectedIndex,
        initialSelectedItems: initialSelectedItems,
        onMultiSelect: onMultiSelect,
        formFields: formFields,
        onFormSubmit: onFormSubmit,
        submitButtonText: submitButtonText,
        icon: icon,
        iconColor: iconColor,
        loadingText: loadingText,
        customWidget: customWidget,
        borderRadius: borderRadius,
        barrierDismissible: barrierDismissible,
        onPrimaryAction: onPrimaryAction,
        onSecondaryAction: onSecondaryAction,
        primaryActionText: primaryActionText,
        secondaryActionText: secondaryActionText,
      ),
    );
  }
}

class _NAlertDialogState extends State<NAlertDialog> {
  // For multiple choice selection
  late List<bool> _selectedItems;
  // For single choice selection
  int _selectedItemIndex = -1;

  @override
  void initState() {
    super.initState();

    // Initialize selection for multiple choice
    if (widget.type == AlertDialogType.multipleChoice) {
      if (widget.initialSelectedItems != null) {
        _selectedItems = List.from(widget.initialSelectedItems!);
      } else if (widget.items != null) {
        _selectedItems = List.filled(widget.items!.length, false);
      } else {
        _selectedItems = [];
      }
    }

    // Initialize selection for single choice
    if (widget.type == AlertDialogType.singleChoice) {
      _selectedItemIndex = widget.initialSelectedIndex ?? -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.backgroundColor ?? Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * widget.widthFactor,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title and close button
              _buildHeader(context),

              // Content based on type
              Flexible(
                child: SingleChildScrollView(
                  child: _buildContent(context),
                ),
              ),

              // Action buttons for relevant dialog types
              if (_shouldShowActionButtons())
                _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Determines if action buttons should be shown based on dialog type
  bool _shouldShowActionButtons() {
    return widget.type == AlertDialogType.basic ||
        widget.type == AlertDialogType.multipleChoice ||
        widget.type == AlertDialogType.success ||
        widget.type == AlertDialogType.error ||
        widget.type == AlertDialogType.warning;
  }

  /// Builds the header section with title and optional close button
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor ?? Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              if (widget.subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.textColor?.withOpacity(0.8) ??
                          Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.showCloseButton)
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onDismiss != null) widget.onDismiss!();
            },
          ),
      ],
    );
  }

  /// Builds the content based on the alert dialog type
  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      case AlertDialogType.basic:
        return _buildBasicContent(context);
      case AlertDialogType.singleChoice:
        return _buildSingleChoiceContent(context);
      case AlertDialogType.multipleChoice:
        return _buildMultipleChoiceContent(context);
      case AlertDialogType.form:
        return _buildFormContent(context);
      case AlertDialogType.success:
      case AlertDialogType.error:
      case AlertDialogType.warning:
        return _buildStatusContent(context);
      case AlertDialogType.loading:
        return _buildLoadingContent(context);
      case AlertDialogType.custom:
        return widget.customWidget ?? const SizedBox.shrink();
    }
  }

  /// Builds basic content with just a message
  Widget _buildBasicContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        if (widget.message != null)
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 16,
              color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds content for single choice selection
  Widget _buildSingleChoiceContent(BuildContext context) {
    if (widget.items == null || widget.items!.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No items available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              widget.message!,
              style: TextStyle(
                fontSize: 16,
                color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items!.length,
          itemBuilder: (context, index) {
            return RadioListTile<int>(
              title: Text(
                widget.items![index],
                style: TextStyle(
                  color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              value: index,
              groupValue: _selectedItemIndex,
              onChanged: (value) {
                setState(() {
                  _selectedItemIndex = value!;
                });

                if (widget.onItemSelected != null && value != null) {
                  widget.onItemSelected!(widget.items![value], value);
                  Navigator.of(context).pop();
                  if (widget.onDismiss != null) widget.onDismiss!();
                }
              },
              dense: true,
              activeColor: Theme.of(context).colorScheme.primary,
            );
          },
        ),
      ],
    );
  }

  /// Builds content for multiple choice selection
  Widget _buildMultipleChoiceContent(BuildContext context) {
    if (widget.items == null || widget.items!.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No items available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              widget.message!,
              style: TextStyle(
                fontSize: 16,
                color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items!.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(
                widget.items![index],
                style: TextStyle(
                  color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              value: _selectedItems[index],
              onChanged: (value) {
                setState(() {
                  _selectedItems[index] = value!;
                });

                if (widget.onMultiSelect != null) {
                  widget.onMultiSelect!(_selectedItems);
                }
              },
              dense: true,
              activeColor: Theme.of(context).colorScheme.primary,
            );
          },
        ),
      ],
    );
  }

  /// Builds form content with submission button
  Widget _buildFormContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              widget.message!,
              style: TextStyle(
                fontSize: 16,
                color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        if (widget.formFields != null) ...widget.formFields!,
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (widget.onFormSubmit != null) {
              widget.onFormSubmit!();
            }
            Navigator.of(context).pop();
            if (widget.onDismiss != null) widget.onDismiss!();
          },
          child: Text(widget.submitButtonText),
        ),
      ],
    );
  }

  /// Builds content for status dialogs (success, error, warning)
  Widget _buildStatusContent(BuildContext context) {
    // Determine icon and color based on dialog type
    IconData statusIcon = widget.icon ?? _getDefaultIcon();
    Color statusColor = widget.iconColor ?? _getDefaultColor(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        Icon(
          statusIcon,
          size: 48,
          color: statusColor,
        ),
        const SizedBox(height: 16),
        if (widget.message != null)
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 16,
              color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds loading content with a progress indicator
  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          widget.loadingText,
          style: TextStyle(
            fontSize: 16,
            color: widget.textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds action buttons based on dialog type
  Widget _buildActionButtons(BuildContext context) {
    if (widget.type == AlertDialogType.basic && widget.actions != null) {
      // For basic dialogs, use provided actions
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: widget.actions!,
        ),
      );
    } else if (widget.type == AlertDialogType.multipleChoice) {
      // For multiple choice dialogs, provide submit button
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onDismiss != null) widget.onDismiss!();
              },
              child: Text(widget.secondaryActionText),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (widget.onMultiSelect != null) {
                  widget.onMultiSelect!(_selectedItems);
                }
                Navigator.of(context).pop();
                if (widget.onDismiss != null) widget.onDismiss!();
              },
              child: Text(widget.primaryActionText),
            ),
          ],
        ),
      );
    } else {
      // For status dialogs, provide OK or OK/Cancel buttons
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.onSecondaryAction != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onSecondaryAction!();
                },
                child: Text(widget.secondaryActionText),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onPrimaryAction != null) {
                  widget.onPrimaryAction!();
                }
              },
              child: Text(widget.primaryActionText),
            ),
          ],
        ),
      );
    }
  }

  /// Returns the default icon based on dialog type
  IconData _getDefaultIcon() {
    switch (widget.type) {
      case AlertDialogType.success:
        return Icons.check_circle_outline;
      case AlertDialogType.error:
        return Icons.error_outline;
      case AlertDialogType.warning:
        return Icons.warning_amber_outlined;
      default:
        return Icons.info_outline;
    }
  }

  /// Returns the default color based on dialog type
  Color _getDefaultColor(BuildContext context) {
    switch (widget.type) {
      case AlertDialogType.success:
        return Colors.green;
      case AlertDialogType.error:
        return Colors.red;
      case AlertDialogType.warning:
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

/// TODO: Usage of this alert dialog (Need to remove in production)

/*
*
* NAlertDialog.show(
      context: context,
      type: AlertDialogType.basic,
      title: 'Information',
      message: 'This is a basic alert dialog with a simple message and action buttons.',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cancel pressed')),
            );
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OK pressed')),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
    * */