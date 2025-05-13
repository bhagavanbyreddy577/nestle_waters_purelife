import 'package:flutter/material.dart';

class NImage extends StatelessWidget {

  /// The URL of the network image. Provide either this or [assetPath].
  final String? imageUrl;

  /// The path of the local asset image. Provide either this or [imageUrl].
  final String? assetPath;

  /// How the image should be inscribed into the space allocated during layout.
  /// Defaults to `BoxFit.cover`.
  final BoxFit fit;

  /// The width of the widget.
  final double? width;

  /// The height of the widget.
  final double? height;

  /// The shape of the image container.
  /// Defaults to `BoxShape.rectangle`.
  final BoxShape shape;

  /// The border radius for the image container, applicable if [shape] is `BoxShape.rectangle`.
  /// Defaults to `BorderRadius.zero`.
  final BorderRadiusGeometry? borderRadius;

  /// The border for the image container.
  /// Example: `Border.all(color: Colors.blue, width: 2.0)`.
  final BoxBorder? border;

  /// The background color to fill behind the image.
  /// Useful if the image has transparency or doesn't fully cover the area.
  /// Defaults to `Colors.transparent`.
  final Color backgroundColor;

  /// A widget to display while a network image is loading.
  /// Defaults to a `CircularProgressIndicator`.
  final Widget? loadingIndicator;

  /// A widget to display if a network image fails to load.
  /// Defaults to an `Icon(Icons.broken_image)`.
  final Widget? errorPlaceholder;

  /// Optional text to overlay on top of the image.
  final String? overlayText;

  /// The text style for the [overlayText].
  /// Defaults to the current theme's `bodyMedium` style with white color.
  final TextStyle? overlayTextStyle;

  /// The alignment for the [overlayText] if it spans multiple lines.
  final TextAlign? overlayTextAlign;

  /// The alignment of the [overlayText] within the image bounds.
  /// Defaults to `Alignment.center`.
  final AlignmentGeometry overlayTextAlignment;

  /// Padding around the [overlayText].
  /// Defaults to `EdgeInsets.all(8.0)`.
  final EdgeInsetsGeometry overlayTextPadding;

  /// Optional background color for the [overlayText] container.
  /// Useful for improving text readability over busy images.
  final Color? overlayTextBackgroundColor;

  /// Creates a CustomImageWidget.
  ///
  /// Either [imageUrl] or [assetPath] must be provided, but not both.
  const NImage({
    Key? key,
    this.imageUrl,
    this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.border,
    this.backgroundColor = Colors.transparent,
    this.loadingIndicator,
    this.errorPlaceholder,
    this.overlayText,
    this.overlayTextStyle,
    this.overlayTextAlign,
    this.overlayTextAlignment = Alignment.center,
    this.overlayTextPadding = const EdgeInsets.all(8.0),
    this.overlayTextBackgroundColor,
  })  : assert(
  (imageUrl != null && assetPath == null) ||
      (imageUrl == null && assetPath != null),
  'Either imageUrl or assetPath must be provided, but not both.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the default text style if not provided
    final TextStyle defaultOverlayTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ??
            const TextStyle(color: Colors.white, fontSize: 14);

    // Build the core image widget (network or asset)
    Widget imageContent;
    if (imageUrl != null) {
      imageContent = Image.network(
        imageUrl!,
        fit: fit,
        width: width,  // Letting the outer Container control primary size
        height: height, // but these can help Image.network with initial constraints
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child; // Image successfully loaded
          return loadingIndicator ??
              Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null, // Indeterminate progress if total bytes not known
                ),
              );
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          // You could log the error here if needed: print('Network image error: $error');
          return errorPlaceholder ??
              const Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  color: Colors.grey,
                  size: 48.0, // Provide a default size for the error icon
                ),
              );
        },
      );
    } else {
      // assetPath must be non-null due to the assertion in the constructor
      imageContent = Image.asset(
        assetPath!,
        fit: fit,
        width: width,
        height: height,
        // Note: Image.asset doesn't have a direct errorBuilder for "file not found" like Image.network.
        // If an asset is not found, Flutter typically shows a specific error placeholder.
        // For robust asset error handling (e.g., checking existence), one might use rootBundle.load
        // before attempting to display, but that's an async operation and adds complexity.
      );
    }

    // Apply Text Overlay if provided
    if (overlayText != null && overlayText!.isNotEmpty) {
      imageContent = Stack(
        // The Stack itself can have a default alignment, but the Align widget
        // provides more explicit control for the text block.
        children: [
          Positioned.fill(child: imageContent), // Image fills the stack
          Align(
            alignment: overlayTextAlignment,
            child: Container(
              color: overlayTextBackgroundColor, // Optional background for text
              padding: overlayTextPadding,
              child: Text(
                overlayText!,
                style: overlayTextStyle ?? defaultOverlayTextStyle,
                textAlign: overlayTextAlign,
              ),
            ),
          ),
        ],
      );
    }

    // Apply Shape, Border, BorderRadius using a Container.
    // The Container's decoration will handle the shape and border,
    // and its `clipBehavior` will clip the `imageContent`.
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: shape,
        // borderRadius is only applicable if shape is rectangle.
        // BoxDecoration handles this: if shape is circle, borderRadius is ignored.
        borderRadius: (shape == BoxShape.rectangle) ? borderRadius : null,
        border: border,
      ),
      // Clip.antiAlias provides smoother edges for clipped content.
      clipBehavior: Clip.antiAlias,
      child: imageContent,
    );
  }
}
