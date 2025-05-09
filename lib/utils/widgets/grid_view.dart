import 'package:flutter/material.dart';

class NGridView<T> extends StatelessWidget {

  /// The list of data items to display.
  final List<T> items;

  /// A builder function that constructs the widget for each item in the grid.
  ///
  /// The builder function is provided with the [BuildContext], the current item [T],
  /// and its [index] in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// A delegate that controls the layout of the children within the grid.
  ///
  /// The [gridDelegate] is responsible for creating the constraints used by
  /// the children, determining the placement of the children, and determining
  /// the size of the grid.  You must provide a non-null value for this.
  final SliverGridDelegate gridDelegate;

  /// The amount of space by which to inset the entire grid.
  final EdgeInsetsGeometry? padding;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size.
  final bool shrinkWrap;

  /// Creates a custom grid view.
  ///
  /// The [items], [itemBuilder], and [gridDelegate] parameters are required.
  const NGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: gridDelegate,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}