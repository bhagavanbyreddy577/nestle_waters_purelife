import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for input formatters
import 'package:intl/intl.dart'; // Required for date formatting (add to pubspec.yaml)

class NDatePicker extends StatefulWidget {

  /// Optional text to display above the date field.
  final String? title;

  /// Custom style for the title text.
  final TextStyle? titleStyle;

  /// Whether to display a mandatory indicator (*) next to the title.
  /// Defaults to `false`.
  final bool isMandatory;

  /// The text displayed when the field is empty.
  final String? hintText;

  /// Custom style for the hint text.
  final TextStyle? hintStyle;

  /// An optional icon to display before the date input area.
  final Widget? prefixIcon;

  /// An optional icon to display after the date input area.
  /// Often used to trigger the date picker.
  final Widget? suffixIcon;

  /// Controls the text (date) being edited.
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// The format for displaying and parsing the date.
  /// Defaults to 'yyyy-MM-dd'.
  /// Uses `intl` package format patterns.
  final String dateFormat;

  /// The initial date to show in the date picker. Defaults to `DateTime.now()`.
  final DateTime? initialDate;

  /// The earliest allowable date.
  final DateTime? firstDate;

  /// The latest allowable date.
  final DateTime? lastDate;

  /// Whether the date field is enabled or disabled.
  /// Defaults to `true`.
  final bool enabled;

  /// An optional method that validates the selected date (or text input if manual entry is allowed).
  /// Returns an error string to display if the input is invalid, or null otherwise.
  /// The `String?` value passed to the validator is the formatted date string.
  final FormFieldValidator<String>? validator;

  /// Called when the selected date changes. Passes the `DateTime?` object.
  final ValueChanged<DateTime?>? onDateSelected;

  /// Custom style for the text (date) being edited.
  final TextStyle? textStyle;

  /// The border to display when the InputDecorator is enabled and is not showing an error.
  final InputBorder? enabledBorder;

  /// The border to display when the InputDecorator has focus and is not showing an error.
  final InputBorder? focusedBorder;

  /// The border to display when the InputDecorator is disabled.
  final InputBorder? disabledBorder;

  /// The border to display when the InputDecorator shows an error.
  final InputBorder? errorBorder;

  /// The border to display when the InputDecorator has focus and shows an error.
  final InputBorder? focusedErrorBorder;

  /// The color to fill the decoration's container.
  final Color? fillColor;

  /// Whether the decoration's container should be filled.
  /// Defaults to `false`.
  final bool filled;

  /// The padding for the input decoration's container.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to allow the user to manually type the date into the text field.
  /// Defaults to `false`. If `true`, `dateFormat` is crucial for parsing.
  final bool allowManualEntry;

  /// The error message to display below the field if validation fails.
  /// This is often managed by the validator, but can be set externally.
  final String? errorText;

  const NDatePicker({
    super.key,
    this.title,
    this.titleStyle,
    this.isMandatory = false,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon = const Icon(Icons.calendar_today), // Default calendar icon
    this.controller,
    this.dateFormat = 'yyyy-MM-dd', // Default format
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.validator,
    this.onDateSelected,
    this.textStyle,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.fillColor,
    this.filled = false,
    this.contentPadding,
    this.allowManualEntry = false,
    this.errorText,
  });

  @override
  State<NDatePicker> createState() => _NDatePickerState();
}

class _NDatePickerState extends State<NDatePicker> {
  late final TextEditingController _controller;
  late final DateFormat _formatter;
  DateTime? _selectedDate;
  bool _isInitialized = false; // To ensure controller is initialized only once

  @override
  void initState() {
    super.initState();
    _formatter = DateFormat(widget.dateFormat);

    // Initialize the controller
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isInitialized = true; // Mark as initialized locally
    } else {
      _controller = widget.controller!;
    }

    // Set initial date in controller if provided and valid
    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _controller.text = _formatter.format(_selectedDate!);
    }

    // Add listener for manual entry if allowed
    if (widget.allowManualEntry) {
      _controller.addListener(_handleManualInput);
    }
  }

  @override
  void dispose() {
    if (widget.allowManualEntry) {
      _controller.removeListener(_handleManualInput);
    }
    // Dispose the local controller only if it was created here
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  // Update controller if external controller text changes (e.g., form reset)
  // or if initialDate changes
  @override
  void didUpdateWidget(NDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update formatter if dateFormat changes
    if (widget.dateFormat != oldWidget.dateFormat) {
      _formatter = DateFormat(widget.dateFormat);
      // Reformat the current date if needed
      if (_selectedDate != null) {
        _controller.text = _formatter.format(_selectedDate!);
      }
    }

    // Update controller text if initialDate changes and differs from current
    if (widget.initialDate != oldWidget.initialDate && widget.initialDate != _selectedDate) {
      _selectedDate = widget.initialDate;
      _controller.text = _selectedDate != null ? _formatter.format(_selectedDate!) : '';
      // Notify listener about the change
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(_selectedDate);
      }
    }

    // If switching between external/internal controller, handle initialization
    if (widget.controller != oldWidget.controller) {
      // Dispose old local controller if needed
      if (oldWidget.controller == null && _isInitialized) {
        _controller.removeListener(_handleManualInput); // Remove listener before disposing
        _controller.dispose();
        _isInitialized = false; // No longer managing local controller
      }
      // Set up new controller
      if (widget.controller == null) {
        _controller = TextEditingController(text: _controller.text); // Keep current text
        _isInitialized = true;
        if (widget.allowManualEntry) _controller.addListener(_handleManualInput);
      } else {
        _controller = widget.controller!;
        // Ensure listener is attached if manual entry is allowed
        if (widget.allowManualEntry) _controller.addListener(_handleManualInput);
      }
    }

    // Add/remove listener based on allowManualEntry changes
    if (widget.allowManualEntry != oldWidget.allowManualEntry) {
      if (widget.allowManualEntry) {
        _controller.addListener(_handleManualInput);
      } else {
        _controller.removeListener(_handleManualInput);
      }
    }
  }


  /// Handles text changes when manual entry is allowed.
  void _handleManualInput() {
    // Try parsing the date from the text field
    DateTime? parsedDate;
    try {
      if (_controller.text.isNotEmpty) {
        parsedDate = _formatter.parseStrict(_controller.text);
      } else {
        parsedDate = null; // Handle empty input
      }
    } catch (e) {
      // Parsing failed, treat as invalid date for now
      parsedDate = null;
      // Optionally, you could provide immediate feedback here,
      // but usually validation handles this on submit/blur.
    }

    // Update the internal state only if the parsed date is different
    if (parsedDate != _selectedDate) {
      setState(() {
        _selectedDate = parsedDate;
      });
      // Notify the listener
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(_selectedDate);
      }
    }
  }


  /// Shows the date picker dialog.
  Future<void> _selectDate(BuildContext context) async {
    // Hide keyboard if it's open
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900), // Default first date
      lastDate: widget.lastDate ?? DateTime(2101),   // Default last date
      helpText: widget.hintText ?? 'Select Date', // Use hint text as help text
      // You can customize other properties like locale, builder, etc.
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatter.format(_selectedDate!);
      });
      // Notify the listener
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(_selectedDate);
      }
      // Trigger validation if needed after selection
      // (Form validation usually happens on save/submit)
      // _formKey.currentState?.validate(); // Example if using a Form key
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Default border style if none provided
    const defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(color: Colors.grey),
    );

    // Default focused border style
    final defaultFocusedBorder = defaultBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
    );

    // Default error border style
    final defaultErrorBorder = defaultBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.error, width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Take minimum vertical space
      children: [
        // --- Title Section ---
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0), // Space below title
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title!,
                  style: widget.titleStyle ??
                      textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.enabled
                            ? colorScheme.onSurface
                            : Colors.grey, // Dim title when disabled
                      ),
                ),
                if (widget.isMandatory)
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: colorScheme.error, // Use error color for '*'
                        fontSize: (widget.titleStyle?.fontSize ??
                            textTheme.titleSmall?.fontSize ??
                            14) *
                            1.1, // Slightly larger asterisk
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // --- TextFormField Section ---
        TextFormField(
          controller: _controller,
          readOnly: !widget.allowManualEntry, // Make read-only if manual entry is disabled
          enabled: widget.enabled,
          validator: (value) {
            // Combine internal parsing validation (if manual) with external validator
            if (widget.allowManualEntry && value != null && value.isNotEmpty) {
              try {
                _formatter.parseStrict(value);
              } catch (e) {
                return 'Invalid date format (${widget.dateFormat})';
              }
            }
            // Call external validator if provided
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null; // No error
          },
          onTap: widget.enabled && !widget.allowManualEntry
              ? () => _selectDate(context) // Show picker on tap only if not manual entry
              : null,
          style: widget.textStyle ?? textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText ?? widget.dateFormat, // Show format as hint
            hintStyle: widget.hintStyle ??
                textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            prefixIcon: widget.prefixIcon,
            // Make suffix icon tappable to open picker, even with manual entry
            suffixIcon: widget.suffixIcon != null
                ? InkWell(
              onTap: widget.enabled ? () => _selectDate(context) : null,
              child: widget.suffixIcon,
            )
                : null,
            // Apply custom borders or fall back to defaults
            enabledBorder: widget.enabledBorder ?? defaultBorder,
            focusedBorder: widget.focusedBorder ?? defaultFocusedBorder,
            disabledBorder: widget.disabledBorder ?? defaultBorder.copyWith(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: widget.errorBorder ?? defaultErrorBorder,
            focusedErrorBorder: widget.focusedErrorBorder ?? defaultErrorBorder.copyWith(
              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            ),
            border: widget.enabledBorder ?? defaultBorder, // General border
            isDense: true, // Reduces vertical padding
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            fillColor: widget.fillColor ?? (widget.enabled ? Colors.transparent : Colors.grey.shade100),
            filled: widget.filled || !widget.enabled, // Fill if explicitly set or disabled
            errorText: widget.errorText, // Display external error text if provided
          ),
          // Use textInputAction appropriate for date fields if needed
          // textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
