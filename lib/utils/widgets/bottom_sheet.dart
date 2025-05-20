import 'package:flutter/material.dart';

/// Enum defining different types of bottom sheets
enum BottomSheetType {
  /// Basic bottom sheet with simple content
  basic,

  /// Bottom sheet with a list of selectable items
  listSelection,

  /// Bottom sheet with form inputs
  form,

  /// Bottom sheet with confirmation actions (Yes/No)
  confirmation,

  /// Custom bottom sheet with fully customizable content
  custom,
}

/// A versatile bottom sheet widget that can render different types of bottom sheets
/// based on the provided [BottomSheetType].
class NBottomSheet extends StatelessWidget {
  /// The type of bottom sheet to display
  final BottomSheetType type;

  /// Title displayed at the top of the bottom sheet
  final String title;

  /// Optional subtitle displayed below the title
  final String? subtitle;

  /// Main content or message of the bottom sheet
  final String? message;

  /// Background color of the bottom sheet
  final Color? backgroundColor;

  /// Text color for the title and other text elements
  final Color? textColor;

  /// Whether to show a close button at the top
  final bool showCloseButton;

  /// Callback when the bottom sheet is dismissed
  final VoidCallback? onDismiss;

  /// Max height as fraction of screen height (0.0 to 1.0)
  final double maxHeightFactor;

  /// For [BottomSheetType.listSelection], the list of items to display
  final List<String>? items;

  /// For [BottomSheetType.listSelection], callback when an item is selected
  final void Function(String, int)? onItemSelected;

  /// For [BottomSheetType.form], list of form fields to display
  final List<Widget>? formFields;

  /// For [BottomSheetType.form], callback when form is submitted
  final VoidCallback? onFormSubmit;

  /// For [BottomSheetType.confirmation], text for confirm button
  final String confirmText;

  /// For [BottomSheetType.confirmation], text for cancel button
  final String cancelText;

  /// For [BottomSheetType.confirmation], callback when confirmed
  final VoidCallback? onConfirm;

  /// For [BottomSheetType.confirmation], callback when canceled
  final VoidCallback? onCancel;

  /// For [BottomSheetType.custom], a completely custom widget
  final Widget? customWidget;

  /// Duration for bottom sheet entrance animation
  final Duration animationDuration;

  /// Whether bottom sheet can be dismissed by tapping outside or dragging down
  final bool isDismissible;

  /// Border radius for the top corners of the bottom sheet
  final double borderRadius;

  /// Constructor for CustomBottomSheet
  const NBottomSheet({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
    this.message,
    this.backgroundColor,
    this.textColor,
    this.showCloseButton = true,
    this.onDismiss,
    this.maxHeightFactor = 0.9,
    this.items,
    this.onItemSelected,
    this.formFields,
    this.onFormSubmit,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.customWidget,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isDismissible = true,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle at the top
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with title and close button
              _buildHeader(context),

              // Content based on type
              Flexible(
                child: SingleChildScrollView(
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor?.withOpacity(0.8) ??
                          Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (showCloseButton)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
              if (onDismiss != null) onDismiss!();
            },
          ),
      ],
    );
  }

  /// Builds the content based on the bottom sheet type
  Widget _buildContent(BuildContext context) {
    switch (type) {
      case BottomSheetType.basic:
        return _buildBasicContent(context);
      case BottomSheetType.listSelection:
        return _buildListContent(context);
      case BottomSheetType.form:
        return _buildFormContent(context);
      case BottomSheetType.confirmation:
        return _buildConfirmationContent(context);
      case BottomSheetType.custom:
        return customWidget ?? const SizedBox.shrink();
    }
  }

  /// Builds basic content with just a message
  Widget _buildBasicContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        if (message != null)
          Text(
            message!,
            style: TextStyle(
              fontSize: 16,
              color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Builds list content for selection
  Widget _buildListContent(BuildContext context) {
    if (items == null || items!.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No items available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items!.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                items![index],
                style: TextStyle(
                  color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () {
                if (onItemSelected != null) {
                  onItemSelected!(items![index], index);
                }
                Navigator.of(context).pop();
                if (onDismiss != null) onDismiss!();
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds form content with submission button
  Widget _buildFormContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        if (formFields != null) ...formFields!,
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (onFormSubmit != null) {
              onFormSubmit!();
            }
            Navigator.of(context).pop();
            if (onDismiss != null) onDismiss!();
          },
          child: const Text('Submit'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds confirmation content with yes/no buttons
  Widget _buildConfirmationContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        if (message != null)
          Text(
            message!,
            style: TextStyle(
              fontSize: 16,
              color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if (onCancel != null) {
                  onCancel!();
                }
                Navigator.of(context).pop();
                if (onDismiss != null) onDismiss!();
              },
              child: Text(cancelText),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (onConfirm != null) {
                  onConfirm!();
                }
                Navigator.of(context).pop();
                if (onDismiss != null) onDismiss!();
              },
              child: Text(confirmText),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Static method to show the bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required BottomSheetType type,
    required String title,
    String? subtitle,
    String? message,
    Color? backgroundColor,
    Color? textColor,
    bool showCloseButton = true,
    VoidCallback? onDismiss,
    double maxHeightFactor = 0.9,
    List<String>? items,
    void Function(String, int)? onItemSelected,
    List<Widget>? formFields,
    VoidCallback? onFormSubmit,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? customWidget,
    Duration animationDuration = const Duration(milliseconds: 300),
    bool isDismissible = true,
    double borderRadius = 16.0,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: animationDuration,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      builder: (context) => NBottomSheet(
        type: type,
        title: title,
        subtitle: subtitle,
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        showCloseButton: showCloseButton,
        onDismiss: onDismiss,
        maxHeightFactor: maxHeightFactor,
        items: items,
        onItemSelected: onItemSelected,
        formFields: formFields,
        onFormSubmit: onFormSubmit,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        customWidget: customWidget,
        animationDuration: animationDuration,
        isDismissible: isDismissible,
        borderRadius: borderRadius,
      ),
    );
  }
}