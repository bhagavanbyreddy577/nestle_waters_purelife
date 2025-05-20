import 'dart:async'; // Required for Timer (debouncing) and Future (API simulation)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter

// Define a callback type for when a suggestion is selected.
// 'T' is the type of the suggestion data (e.g., String, a custom object).
typedef SuggestionSelectedCallback<T> = void Function(T suggestion);

// Define a callback type for fetching suggestions.
// It takes the current query string and returns a Future or a List of suggestions.
typedef SuggestionsCallback<T> = FutureOr<List<T>> Function(String query);

// Define a callback type for building the UI for each suggestion item.
typedef SuggestionItemBuilder<T> = Widget Function(
    BuildContext context, T suggestion);


class NSearchBar<T> extends StatefulWidget {

  /// Called when the text in the search field changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search query (e.g., by pressing enter on the keyboard).
  final ValueChanged<String>? onSubmitted;

  /// Called when a suggestion is selected from the list.
  /// The selected suggestion of type 'T' is passed as an argument.
  final SuggestionSelectedCallback<T>? onResultSelected;

  /// An asynchronous function that provides suggestions based on the current query.
  /// This is where you would typically call your API.
  /// It should return a `List<T>` or `Future<List<T>>`.
  final SuggestionsCallback<T> suggestionsCallback;

  /// A builder function to create the visual representation for each suggestion item.
  /// It receives the `BuildContext` and a single suggestion item of type `T`.
  final SuggestionItemBuilder<T> suggestionItemBuilder;

  /// Optional initial text to display in the search field.
  final String? initialText;

  /// Hint text to display when the search field is empty. Defaults to 'Search...'.
  final String? hintText;

  /// An optional icon widget to display at the beginning (left side) of the search field.
  final Widget? leadingIcon;

  /// An optional icon widget to display at the end (right side) of the search field.
  /// If null, a clear button (X) will be shown by default when text is present and the widget is enabled.
  final Widget? trailingIcon;

  /// Whether the search widget is enabled for interaction. Defaults to true.
  /// If false, the widget will be visually disabled and won't accept input.
  final bool enabled;

  /// The text style for the input field.
  final TextStyle? textStyle;

  /// The text style for the hint text.
  final TextStyle? hintStyle;

  /// The border color of the search field when it's not focused.
  final Color? borderColor;

  /// The border color of the search field when it has focus.
  final Color? focusedBorderColor;

  /// The background color of the search field.
  final Color? backgroundColor;

  /// The border radius of the search field.
  final BorderRadius? borderRadius;

  /// The box decoration for the suggestions container that appears below the search field.
  /// Allows customization of background color, border, shadow, etc., for the suggestions list.
  final BoxDecoration? suggestionsBoxDecoration;

  /// The maximum height for the suggestions container.
  /// The container will size itself dynamically based on its content, up to this height.
  /// Defaults to 200.0.
  final double? maxSuggestionsHeight;

  /// Whether to show suggestions as soon as the field is focused, even if the query is empty.
  /// Defaults to false, meaning suggestions usually appear only after typing.
  final bool showSuggestionsOnFocus;

  /// The duration to wait after the user stops typing before calling [suggestionsCallback].
  /// This helps in reducing the number of API calls. Defaults to 300 milliseconds.
  final Duration debounceDuration;

  /// A master switch to control the visibility of the suggestions list.
  /// If false, suggestions will not be shown. Defaults to true.
  final bool showSuggestions;

  /// An optional widget to display while suggestions are being loaded (e.g., from an API).
  /// Defaults to a centered `CircularProgressIndicator`.
  final Widget? loadingSuggestionsWidget;

  /// An optional widget to display when [suggestionsCallback] returns an empty list
  /// or an error occurs, and the query is not empty.
  /// Defaults to a centered 'No results found' text.
  final Widget? noSuggestionsWidget;

  const NSearchBar({
    super.key,
    required this.suggestionsCallback,
    required this.suggestionItemBuilder,
    this.onChanged,
    this.onSubmitted,
    this.onResultSelected,
    this.initialText,
    this.hintText = 'Search...',
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.textStyle,
    this.hintStyle,
    this.borderColor,
    this.focusedBorderColor,
    this.backgroundColor,
    this.borderRadius,
    this.suggestionsBoxDecoration,
    this.maxSuggestionsHeight = 200.0,
    this.showSuggestionsOnFocus = false, // Default: don't show suggestions list when no input on focus
    this.debounceDuration = const Duration(milliseconds: 300),
    this.showSuggestions = true,
    this.loadingSuggestionsWidget =
    const Center(child: Padding(
      padding: EdgeInsets.all(8.0),
      child: CircularProgressIndicator(),
    )),
    this.noSuggestionsWidget = const Center(child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('No results found'),
    )),
  });

  @override
  State<NSearchBar<T>> createState() => _NSearchBarState<T>();
}

class _NSearchBarState<T> extends State<NSearchBar<T>> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  List<T> _suggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;

  // OverlayEntry is used to show the suggestions list "floating" below the search field.
  OverlayEntry? _suggestionsOverlayEntry;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _removeSuggestionsOverlay(); // Clean up the overlay
    super.dispose();
  }

  /// Handles changes in the text field.
  void _onTextChanged() {
    // Notify the parent widget about the change.
    widget.onChanged?.call(_textController.text);

    // If suggestions are disabled, or the text is empty and we're not showing suggestions on focus,
    // clear existing suggestions and hide the overlay.
    if (!widget.showSuggestions || (_textController.text.isEmpty && !widget.showSuggestionsOnFocus)) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoadingSuggestions = false;
        });
      }
      _removeSuggestionsOverlay(); // Ensure overlay is removed
      _rebuildSuggestionsOverlay(); // Rebuild to ensure it reflects the empty state if it was meant to be visible
      return;
    }


    // Debounce the fetching of suggestions.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (_textController.text.isNotEmpty || (widget.showSuggestionsOnFocus && _focusNode.hasFocus)) {
        _fetchSuggestions(_textController.text);
      } else {
        // If text becomes empty and not showing on focus, clear suggestions.
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isLoadingSuggestions = false;
          });
          _rebuildSuggestionsOverlay(); // Update overlay (it might hide itself)
        }
      }
    });

    // The text field itself might need a rebuild (e.g., to show/hide the clear button).
    if (mounted) {
      setState(() {});
    }
  }

  /// Handles focus changes on the text field.
  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // If focused, and either text is present or showSuggestionsOnFocus is true,
      // then fetch/show suggestions.
      if (_textController.text.isNotEmpty || widget.showSuggestionsOnFocus) {
        _fetchSuggestions(_textController.text); // Fetch suggestions
        _showSuggestionsOverlay(); // Ensure overlay is created if not already
      }
    } else {
      // When focus is lost, remove the suggestions overlay after a short delay.
      // This delay allows a tap on a suggestion item to register before the overlay disappears.
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) { // Check focus again to ensure it wasn't regained
          _removeSuggestionsOverlay();
        }
      });
    }
    // Rebuild to reflect focus changes (e.g., border color).
    if (mounted) {
      setState(() {});
    }
  }

  /// Fetches suggestions using the provided [suggestionsCallback].
  Future<void> _fetchSuggestions(String query) async {
    if (!widget.showSuggestions) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoadingSuggestions = false;
        });
      }
      _rebuildSuggestionsOverlay();
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingSuggestions = true;
      });
    }
    _rebuildSuggestionsOverlay(); // Show loading indicator in overlay

    try {
      final suggestions = await widget.suggestionsCallback(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
          _suggestions = []; // Clear suggestions on error
        });
      }
      print('Error fetching suggestions: $e'); // Log error
    }
    _rebuildSuggestionsOverlay(); // Update overlay with new suggestions or empty state
  }

  /// Handles the selection of a suggestion item.
  void _onSuggestionSelected(T suggestion) {
    // By default, convert suggestion to string. For custom objects, you might
    // want a `suggestionToString` callback in the main widget if `toString()` isn't suitable.
    final String suggestionText = suggestion.toString();

    _textController.text = suggestionText; // Place the selected item's text into the search box.
    _textController.selection =
        TextSelection.fromPosition(TextPosition(offset: suggestionText.length)); // Move cursor to end.

    widget.onResultSelected?.call(suggestion); // Notify parent.

    if (mounted) {
      setState(() {
        _suggestions = []; // Clear current suggestions.
        _isLoadingSuggestions = false;
      });
    }
    _removeSuggestionsOverlay(); // The result container should disappear.
    _focusNode.unfocus(); // Optionally unfocus the search field.
  }

  /// Clears the text in the search field.
  void _clearText() {
    _textController.clear();
    widget.onChanged?.call(''); // Notify change (empty text)
    if (mounted) {
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
    }
    _rebuildSuggestionsOverlay(); // Update overlay (it should hide or show empty state based on focus)
    // _focusNode.requestFocus(); // Optionally keep focus
  }

  // --- Overlay Management for Suggestions ---

  /// Creates and shows the suggestions overlay.
  void _showSuggestionsOverlay() {
    if (_suggestionsOverlayEntry != null) {
      _suggestionsOverlayEntry!.markNeedsBuild(); // If already visible, just rebuild
      return;
    }
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _suggestionsOverlayEntry = OverlayEntry(
      builder: (context) {
        // Position the overlay below the search text field.
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 4.0, // Small gap below the TextField
          width: size.width,
          child: Material( // Material for theming, elevation, and shape
            elevation: widget.suggestionsBoxDecoration?.boxShadow != null ? 0 : 4.0, // Use elevation if no custom shadow
            shape: widget.suggestionsBoxDecoration?.border != null || widget.suggestionsBoxDecoration?.borderRadius != null
                ? RoundedRectangleBorder(
              borderRadius: (widget.suggestionsBoxDecoration?.borderRadius?.resolve(Directionality.of(context)) ?? BorderRadius.zero),
              // This is a simplified way to get a side; proper shaping might need more complex handling if `suggestionsBoxDecoration.shape` is used.
              side: _getBorderSideFromDecoration(widget.suggestionsBoxDecoration),
            )
                : null,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: widget.maxSuggestionsHeight ?? 200.0, // Flexible height
              ),
              decoration: widget.suggestionsBoxDecoration ?? // Default decoration if none provided
                  BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
              child: _buildSuggestionsListWidget(),
            ),
          ),
        );
      },
    );
    overlay.insert(_suggestionsOverlayEntry!);
  }

  BorderSide _getBorderSideFromDecoration(BoxDecoration? decoration) {
    if (decoration?.border is Border) {
      final border = decoration!.border as Border;
      // This is a simplification. A BoxBorder can have different sides.
      // Here, we arbitrarily pick the 'top' side if available, or default.
      return border.top;
    }
    return BorderSide.none;
  }


  /// Removes the suggestions overlay from the screen.
  void _removeSuggestionsOverlay() {
    _suggestionsOverlayEntry?.remove();
    _suggestionsOverlayEntry = null;
  }

  /// Rebuilds the suggestions overlay if it's currently visible.
  void _rebuildSuggestionsOverlay() {
    // Only show overlay if focused and (text is present OR showSuggestionsOnFocus is true)
    // OR if loading (to show loading indicator)
    final bool shouldBeVisible = _focusNode.hasFocus && widget.showSuggestions &&
        (_textController.text.isNotEmpty || widget.showSuggestionsOnFocus || _isLoadingSuggestions);

    if (shouldBeVisible) {
      _showSuggestionsOverlay(); // This will create or mark for rebuild
    } else {
      _removeSuggestionsOverlay();
    }
  }


  /// Builds the list widget that displays the suggestions.
  Widget _buildSuggestionsListWidget() {
    if (_isLoadingSuggestions) {
      return widget.loadingSuggestionsWidget!; // Assumed not null due to default
    }

    // "By default results should not be listed at the bottom when no input."
    // This is handled here: if no text, and not showing on focus, and not loading, show nothing.
    if (_suggestions.isEmpty && _textController.text.isEmpty && !widget.showSuggestionsOnFocus) {
      return const SizedBox.shrink();
    }

    if (_suggestions.isEmpty && (_textController.text.isNotEmpty || widget.showSuggestionsOnFocus)) {
      return widget.noSuggestionsWidget!; // Assumed not null
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true, // Essential for dynamic height within constraints
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        // Use InkWell for tap feedback and handling.
        return InkWell(
          onTap: () => _onSuggestionSelected(suggestion),
          child: widget.suggestionItemBuilder(context, suggestion),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine effective styles and colors, falling back to theme defaults if not provided.
    final effectiveTextStyle = widget.textStyle ?? theme.textTheme.titleMedium;
    final effectiveHintStyle =
        widget.hintStyle ?? theme.textTheme.titleMedium?.copyWith(color: theme.hintColor);
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(8.0);

    // Determine the suffix icon. Show a clear button if enabled, text is present, and no custom trailingIcon is provided.
    Widget? suffixIconWidget = widget.trailingIcon;
    if (widget.trailingIcon == null && _textController.text.isNotEmpty && widget.enabled) {
      suffixIconWidget = IconButton(
        icon: const Icon(Icons.clear, size: 20),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: _clearText,
        tooltip: 'Clear search',
      );
    }

    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: widget.enabled,
      style: effectiveTextStyle,
      onSubmitted: (value) {
        widget.onSubmitted?.call(value);
        _removeSuggestionsOverlay(); // Hide suggestions on submit
        _focusNode.unfocus();
      },
      // Input formatter to prevent leading spaces.
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'^\s')),
      ],
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: effectiveHintStyle,
        prefixIcon: widget.leadingIcon,
        suffixIcon: suffixIconWidget,
        filled: true,
        fillColor: widget.backgroundColor ?? theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust padding as needed
        border: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: widget.borderColor ?? theme.colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: widget.borderColor ?? theme.colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? theme.primaryColor,
            width: 1.5, // Slightly thicker border when focused
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(
            color: (widget.borderColor ?? theme.disabledColor).withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
