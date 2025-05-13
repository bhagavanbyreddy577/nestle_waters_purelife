import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NAppBar extends StatelessWidget implements PreferredSizeWidget {

  /// A widget to display before the [title].
  /// Typically an [IconButton] (e.g., menu or back button).
  final Widget? leading;

  /// If true, and [leading] is null, an appropriate leading widget will be
  /// automatically implied by Flutter (e.g., a [BackButton] on a non-root route,
  /// or a drawer menu icon if [Scaffold.hasDrawer] is true).
  /// Defaults to true.
  final bool automaticallyImplyLeading;

  /// The primary widget displayed in the app bar.
  /// Typically a [Text] widget. For custom styling, ensure the [title]
  /// widget itself is styled or use [titleTextStyle].
  final Widget? title;

  /// A list of Widgets to display in a row after the [title] widget.
  /// Typically these screens are [IconButton]s.
  final List<Widget>? actions;

  /// A widget to display at the bottom of the app bar.
  /// Typically a [TabBar]. Its height is added to the [preferredSize].
  final PreferredSizeWidget? bottom;

  /// The z-coordinate at which to place this app bar.
  /// Controls the size of the shadow below the app bar.
  /// Defaults to 0.0 if [backgroundColor] is transparent or translucent, otherwise 4.0.
  final double? elevation;

  /// The background color for the app bar's [Material].
  /// Defaults to the [AppBarTheme.backgroundColor] or [ThemeData.primaryColor].
  final Color? backgroundColor;

  /// The default color for [Text] and [Icon]s within the app bar.
  /// Defaults to [AppBarTheme.foregroundColor] or a color that contrasts
  /// with the [backgroundColor].
  final Color? foregroundColor;

  /// The text style for the [title] widget.
  /// If a [Text] widget is used for [title] and it has its own style,
  /// that style will take precedence.
  /// Defaults to [AppBarTheme.titleTextStyle] or [ThemeData.textTheme.titleLarge].
  final TextStyle? titleTextStyle;

  /// The style to use for the system pictograms (e.g., status bar icons).
  /// If null, a style is chosen that contrasts with the [backgroundColor].
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Whether the [title] should be centered.
  /// Defaults to [AppBarTheme.centerTitle] or platform-specific defaults.
  final bool? centerTitle;

  /// The width of the [leading] widget area.
  /// Standard Flutter AppBar typically uses [kToolbarHeight] (56.0) for this.
  /// If you provide a [leading] widget with its own intrinsic width,
  /// this might be respected by the layout.
  final double? leadingWidth;

  /// The spacing around the [title] content on the horizontal axis.
  /// This spacing is applied even if there is no [leading] content or [actions].
  /// Defaults to [NavigationToolbar.kMiddleSpacing].
  final double? titleSpacing;

  /// A [ShapeBorder] to draw at the bottom of the app bar.
  final ShapeBorder? shape;

  /// The height of the app bar section, excluding the [bottom] widget's height.
  /// Defaults to [kToolbarHeight] (56.0).
  final double preferredHeight;

  /// Creates a custom app bar.
  const NAppBar({
    Key? key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.bottom,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.titleTextStyle,
    this.systemUiOverlayStyle,
    this.centerTitle,
    this.leadingWidth = 80.0, // this can be customizable
    this.titleSpacing,
    this.shape,
    this.preferredHeight = kToolbarHeight,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
      preferredHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

    // Determine effective leading widget
    Widget? currentLeading = leading;
    if (currentLeading == null && automaticallyImplyLeading) {
      if (hasDrawer) {
        currentLeading = IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffold?.openDrawer(),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else if (canPop) {
        currentLeading = useCloseButton ? const CloseButton() : const BackButton();
      }
    }
    if (currentLeading != null && leadingWidth != null) {
      currentLeading = ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: leadingWidth!),
        child: currentLeading,
      );
    }


    // Determine effective colors, elevation, and styles
    final Color effectiveBackgroundColor = backgroundColor ??
        appBarTheme.backgroundColor ??
        theme.colorScheme.primary; // Updated to use colorScheme

    final Color effectiveForegroundColor = foregroundColor ??
        appBarTheme.foregroundColor ??
        (ThemeData.estimateBrightnessForColor(effectiveBackgroundColor) ==
            Brightness.dark
            ? Colors.white
            : Colors.black);

    final double effectiveElevation = elevation ??
        appBarTheme.elevation ??
        (effectiveBackgroundColor == Colors.transparent || effectiveBackgroundColor.alpha == 0 ? 0.0 : 4.0);


    final SystemUiOverlayStyle effectiveSystemUiOverlayStyle =
        systemUiOverlayStyle ??
            appBarTheme.systemOverlayStyle ??
            (ThemeData.estimateBrightnessForColor(effectiveBackgroundColor) ==
                Brightness.light
                ? SystemUiOverlayStyle.dark // Dark icons for light background
                : SystemUiOverlayStyle.light); // Light icons for dark background

    final TextStyle effectiveTitleTextStyle = (titleTextStyle ??
        appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
        .copyWith(color: effectiveForegroundColor);

    // Prepare title widget with default styling
    Widget? styledTitle = title;
    if (styledTitle != null) {
      styledTitle = DefaultTextStyle(
        style: effectiveTitleTextStyle,
        child: styledTitle,
      );
    }

    // Prepare actions with icon theming
    List<Widget>? themedActions = actions;
    // (IconTheme will be applied globally to the NavigationToolbar area)

    // Main content of the AppBar using NavigationToolbar for standard layout
    Widget appBarContent = NavigationToolbar(
      leading: currentLeading,
      middle: styledTitle ?? const SizedBox.shrink(),
      trailing: themedActions != null && themedActions.isNotEmpty
          ? Row(mainAxisSize: MainAxisSize.min, children: themedActions)
          : null,
      centerMiddle: centerTitle ?? appBarTheme.centerTitle ?? theme.appBarTheme.centerTitle ?? false, // Platform specific default if not set
      middleSpacing: titleSpacing ?? NavigationToolbar.kMiddleSpacing,
    );

    // Wrap the content with default text and icon themes
    appBarContent = DefaultTextStyle(
      style: effectiveTitleTextStyle.copyWith(
          fontSize: theme.textTheme.bodyMedium?.fontSize ?? 14.0), // General text in toolbar
      child: IconTheme.merge(
        data: IconThemeData(
          color: effectiveForegroundColor,
          size: appBarTheme.actionsIconTheme?.size ?? appBarTheme.iconTheme?.size ?? 24.0,
        ),
        child: appBarContent,
      ),
    );

    // Container to enforce preferredHeight for the main app bar section
    appBarContent = Container(
      height: preferredHeight,
      alignment: Alignment.center, // Vertically center content within the height
      child: appBarContent,
    );


    // If a bottom widget is provided, arrange it below the main content
    if (bottom != null) {
      appBarContent = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(child: appBarContent), // Main app bar content takes available space
          bottom!,
        ],
      );
    }

    // The main Material widget for the AppBar
    // It provides background color, elevation, and shape.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: effectiveSystemUiOverlayStyle,
      child: Material(
        color: effectiveBackgroundColor,
        elevation: effectiveElevation,
        shape: shape,
        child: SafeArea( // Ensures content respects system intrusions (status bar)
          top: true, // Only apply SafeArea to the top
          bottom: false, // Bottom SafeArea is handled by Scaffold or content
          child: appBarContent,
        ),
      ),
    );
  }
}
