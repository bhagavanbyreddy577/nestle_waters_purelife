import 'package:flutter/material.dart';

enum ListOrientation {
  horizontal,
  vertical,
}

class NListView<T> extends StatelessWidget {

  /// The list of data items to display.
  final List<T> items;

  /// A builder function that constructs the widget for each item in the list.
  ///
  /// The builder function is provided with the [BuildContext], the current item [T],
  /// and its [index] in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// The orientation of the list.
  /// Defaults to [ListOrientation.vertical].
  final ListOrientation orientation;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// cannot beLazy-loaded offscreen - it must all be laid out to determine the
  /// scroll view's extent in the [scrollDirection].
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The number of logical pixels between each child.
  final double spacing;

  /// Creates a custom list view.
  ///
  /// The [items] and [itemBuilder] parameters are required.
  const NListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.orientation = ListOrientation.vertical,
    this.padding,
    this.physics,
    this.shrinkWrap = false, // Default shrinkWrap to false for performance
    this.spacing = 0.0, // Default spacing between items
  });

  @override
  Widget build(BuildContext context) {
    // Determine the scroll direction based on the orientation
    Axis scrollDirection = orientation == ListOrientation.horizontal
        ? Axis.horizontal
        : Axis.vertical;

    // ListView.builder is efficient for lists with a large number of items.
    return ListView.separated(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        // Call the provided itemBuilder to build each item
        return itemBuilder(context, items[index], index);
      },
      separatorBuilder: (BuildContext context, int index) {
        // Return a SizedBox for spacing based on orientation
        return orientation == ListOrientation.horizontal
            ? SizedBox(width: spacing)
            : SizedBox(height: spacing);
      },
    );
  }
}