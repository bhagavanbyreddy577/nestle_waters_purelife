import 'package:flutter/material.dart';

class NListTile extends StatelessWidget {

  /// Primary content of the list tile
  final Widget? title;

  /// Optional smaller text to display below the title
  final Widget? subtitle;

  /// Optional widget to display before the title
  final Widget? leading;

  /// Optional widget to display after the title
  final Widget? trailing;

  /// Called when the user taps this list tile
  final VoidCallback? onTap;

  /// Called when the user long-presses this list tile
  final VoidCallback? onLongPress;

  /// Background color of the list tile
  final Color? backgroundColor;

  /// Background color of the list tile when pressed
  final Color? splashColor;

  /// Color to highlight the tile when focused
  final Color? focusColor;

  /// Color to highlight the tile when hovered
  final Color? hoverColor;

  /// The border radius of the list tile
  final BorderRadius? borderRadius;

  /// The shadow elevation of the list tile
  final double elevation;

  /// The padding inside the list tile
  final EdgeInsetsGeometry contentPadding;

  /// Whether the list tile is enabled
  final bool enabled;

  /// Whether the list tile is selected
  final bool selected;

  /// Whether the list tile is dense
  final bool dense;

  /// The vertical alignment of the title and subtitle
  final CrossAxisAlignment contentAlignment;

  /// The horizontal space between the leading widget and the title
  final double leadingSpacing;

  /// The horizontal space between the title and the trailing widget
  final double trailingSpacing;

  /// The vertical space between the title and subtitle
  final double titleSubtitleSpacing;

  /// Custom style to apply to the title when selected
  final TextStyle? selectedTitleStyle;

  /// Custom style to apply to the subtitle when selected
  final TextStyle? selectedSubtitleStyle;

  /// Whether to show a divider at the bottom of the list tile
  final bool showDivider;

  /// The color of the divider, if shown
  final Color? dividerColor;

  /// The height of the divider, if shown
  final double dividerHeight;

  /// The indent of the divider from the leading edge
  final double dividerIndent;

  /// The indent of the divider from the trailing edge
  final double dividerEndIndent;

  /// Whether to clip the content to the border radius
  final bool clipBehavior;

  /// The margin around the list tile
  final EdgeInsetsGeometry margin;

  /// Creates a [NListTile] widget.
  ///
  /// Many of the parameters have defaults and are optional.
  const NListTile({
    Key? key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.splashColor,
    this.focusColor,
    this.hoverColor,
    this.borderRadius,
    this.elevation = 0,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.enabled = true,
    this.selected = false,
    this.dense = false,
    this.contentAlignment = CrossAxisAlignment.start,
    this.leadingSpacing = 16,
    this.trailingSpacing = 16,
    this.titleSubtitleSpacing = 4,
    this.selectedTitleStyle,
    this.selectedSubtitleStyle,
    this.showDivider = false,
    this.dividerColor,
    this.dividerHeight = 0.5,
    this.dividerIndent = 16,
    this.dividerEndIndent = 0,
    this.clipBehavior = true,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine the title style based on selection state
    final TextStyle defaultTitleStyle = theme.textTheme.titleMedium!;
    final TextStyle effectiveTitleStyle = selected
        ? (selectedTitleStyle ?? defaultTitleStyle.copyWith(color: theme.colorScheme.primary))
        : defaultTitleStyle;

    // Determine the subtitle style based on selection state
    final TextStyle defaultSubtitleStyle = theme.textTheme.bodyMedium!;
    final TextStyle effectiveSubtitleStyle = selected
        ? (selectedSubtitleStyle ?? defaultSubtitleStyle.copyWith(color: theme.colorScheme.primary.withOpacity(0.8)))
        : defaultSubtitleStyle;

    // Build the title widget if provided
    Widget? titleWidget;
    if (title != null) {
      if (title is Text) {
        // Apply the effective style if the title is a Text widget
        final Text textTitle = title as Text;
        titleWidget = Text(
          textTitle.data ?? '',
          style: textTitle.style != null
              ? textTitle.style!.merge(effectiveTitleStyle)
              : effectiveTitleStyle,
          maxLines: textTitle.maxLines,
          overflow: textTitle.overflow,
          textAlign: textTitle.textAlign,
        );
      } else {
        titleWidget = title;
      }
    }

    // Build the subtitle widget if provided
    Widget? subtitleWidget;
    if (subtitle != null) {
      if (subtitle is Text) {
        // Apply the effective style if the subtitle is a Text widget
        final Text textSubtitle = subtitle as Text;
        subtitleWidget = Text(
          textSubtitle.data ?? '',
          style: textSubtitle.style != null
              ? textSubtitle.style!.merge(effectiveSubtitleStyle)
              : effectiveSubtitleStyle,
          maxLines: textSubtitle.maxLines,
          overflow: textSubtitle.overflow,
          textAlign: textSubtitle.textAlign,
        );
      } else {
        subtitleWidget = subtitle;
      }
    }

    // Build the main content row
    Widget content = Row(
      crossAxisAlignment: contentAlignment,
      children: [
        // Leading widget with spacing
        if (leading != null) ...[
          leading!,
          SizedBox(width: leadingSpacing),
        ],

        // Title and subtitle in a column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (titleWidget != null) titleWidget,
              if (titleWidget != null && subtitleWidget != null)
                SizedBox(height: titleSubtitleSpacing),
              if (subtitleWidget != null) subtitleWidget,
            ],
          ),
        ),

        // Trailing widget with spacing
        if (trailing != null) ...[
          SizedBox(width: trailingSpacing),
          trailing!,
        ],
      ],
    );

    // Apply padding to the content
    content = Padding(
      padding: contentPadding,
      child: content,
    );

    // Create the main material widget with ink effects
    final BorderRadius effectiveBorderRadius = borderRadius ?? BorderRadius.circular(0);

    Widget result = Material(
      color: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      borderRadius: effectiveBorderRadius,
      clipBehavior: clipBehavior ? Clip.antiAlias : Clip.none,
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        splashColor: splashColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        borderRadius: effectiveBorderRadius,
        child: content,
      ),
    );

    // Add divider if needed
    if (showDivider) {
      result = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          result,
          Container(
            margin: EdgeInsets.only(left: dividerIndent, right: dividerEndIndent),
            height: dividerHeight,
            color: dividerColor ?? theme.dividerColor,
          ),
        ],
      );
    }

    // Apply margin if needed
    if (margin != EdgeInsets.zero) {
      result = Padding(
        padding: margin,
        child: result,
      );
    }

    return result;
  }
}
