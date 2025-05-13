import 'package:flutter/material.dart';

enum DividerOrientation {
  horizontal,
  vertical,
}

class NDivider extends StatelessWidget {

  /// The orientation of the divider.
  /// Defaults to [DividerOrientation.horizontal].
  final DividerOrientation orientation;

  /// The thickness of the divider.
  /// For a horizontal divider, this is its height.
  /// For a vertical divider, this is its width.
  /// Defaults to 1.0.
  final double thickness;

  /// The color of the divider.
  /// Defaults to [Colors.grey].
  final Color color;

  /// The extent of the divider.
  /// For a horizontal divider, this is its width. If null, it will take the full available width.
  /// For a vertical divider, this is its height. If null, it will take the full available height.
  final double? extent;

  /// The amount of empty space to indent the divider on the leading side.
  /// For a horizontal divider, this is the left indent.
  /// For a vertical divider, this is the top indent.
  /// Defaults to 0.0.
  final double indent;

  /// The amount of empty space to indent the divider on the trailing side.
  /// For a horizontal divider, this is the right indent.
  /// For a vertical divider, this is the bottom indent.
  /// Defaults to 0.0.
  final double endIndent;

  /// Creates a custom divider.
  ///
  /// The [orientation] defaults to [DividerOrientation.horizontal].
  /// The [thickness] defaults to 1.0.
  /// The [color] defaults to `Colors.grey[400]`.
  /// The [indent] and [endIndent] defaults to 0.0.
  const NDivider({
    super.key,
    this.orientation = DividerOrientation.horizontal,
    this.thickness = 1.0,
    this.color = Colors.grey, // Using a more common default like Colors.grey
    this.extent,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Based on the orientation, return either a SizedBox with height (for horizontal)
    // or width (for vertical) representing the divider.
    if (orientation == DividerOrientation.horizontal) {
      // Horizontal Divider
      return SizedBox(
        height: thickness, // Thickness becomes the height
        width: extent, // Optional width for the horizontal divider
        child: Padding(
          padding: EdgeInsets.only(left: indent, right: endIndent),
          child: Container(
            color: color,
          ),
        ),
      );
    } else {
      // Vertical Divider
      return SizedBox(
        width: thickness, // Thickness becomes the width
        height: extent, // Optional height for the vertical divider
        child: Padding(
          padding: EdgeInsets.only(top: indent, bottom: endIndent),
          child: Container(
            color: color,
          ),
        ),
      );
    }
  }
}