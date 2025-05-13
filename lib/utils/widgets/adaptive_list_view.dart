import 'package:flutter/material.dart';

/// A generic type definition for the item builder function.
///
/// [T] is the data type of the items in the list.
/// [index] is the position of the item in the list.
/// [item] is the data item to be displayed.
/// [isGridMode] indicates whether the widget is currently in grid mode.
typedef ItemWidgetBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  T item,
  bool isGridMode,
);

/// A callback for when the end of the list is reached (for pagination).
typedef OnLoadMore = Future<void> Function();

/// A callback to refresh the data (pull-to-refresh).
typedef OnRefresh = Future<void> Function();

/// A reusable widget that can display data in either a ListView or GridView format
/// with built-in pagination support.
///
/// This widget handles common features like:
/// - Switching between list and grid views
/// - Loading states
/// - Empty states
/// - Error states
/// - Pagination (infinite scrolling)
/// - Pull-to-refresh
class NAdaptiveListView<T> extends StatefulWidget {
  /// The list of items to display.
  final List<T> items;

  /// Function that builds each item widget.
  final ItemWidgetBuilder<T> itemBuilder;

  /// Whether to display items in a grid layout. If false, displays as a list.
  final bool isGridMode;

  /// Number of columns to display when in grid mode.
  final int gridCrossAxisCount;

  /// Aspect ratio for grid items.
  final double gridChildAspectRatio;

  /// Spacing between grid items horizontally.
  final double gridCrossAxisSpacing;

  /// Spacing between grid items vertically.
  final double gridMainAxisSpacing;

  /// Padding around the list/grid.
  final EdgeInsetsGeometry? padding;

  /// Widget to display when the list is empty.
  final Widget? emptyWidget;

  /// Widget to display when loading data.
  final Widget? loadingWidget;

  /// Widget to display when an error occurs.
  final Widget? errorWidget;

  /// Function called when the end of the list is reached for pagination.
  final OnLoadMore? onLoadMore;

  /// Function called for pull-to-refresh functionality.
  final OnRefresh? onRefresh;

  /// Distance from the bottom of the list that triggers the onLoadMore callback.
  final double loadMoreThreshold;

  /// Indicates if more data is being loaded (shows loading indicator at bottom).
  final bool isLoadingMore;

  /// Indicates if this is the initial loading state.
  final bool isLoading;

  /// Indicates if all data has been loaded (pagination complete).
  final bool hasReachedMax;

  /// Indicates if an error occurred while loading data.
  final bool hasError;

  /// Optional scroll controller for the list/grid.
  final ScrollController? scrollController;

  /// Whether the list/grid should be scrollable.
  final bool shrinkWrap;

  /// Physics for the scrollable widget.
  final ScrollPhysics? physics;

  /// Whether the list/grid has a fixed extent.
  final bool addAutomaticKeepAlives;

  /// Additional builder that appears at the bottom of the list.
  final WidgetBuilder? bottomBuilder;

  /// Additional builder that appears at the top of the list.
  final WidgetBuilder? topBuilder;

  /// Primary key for the list.
  final Key? listKey;

  const NAdaptiveListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.isGridMode = false,
    this.gridCrossAxisCount = 2,
    this.gridChildAspectRatio = 1.0,
    this.gridCrossAxisSpacing = 8.0,
    this.gridMainAxisSpacing = 8.0,
    this.padding,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.onLoadMore,
    this.onRefresh,
    this.loadMoreThreshold = 200.0,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.hasReachedMax = false,
    this.hasError = false,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.bottomBuilder,
    this.topBuilder,
    this.listKey,
  }) : super(key: key);

  @override
  State<NAdaptiveListView<T>> createState() => _NAdaptiveListViewState<T>();
}

class _NAdaptiveListViewState<T> extends State<NAdaptiveListView<T>> {
  /// Internal scroll controller used when no external controller is provided.
  late ScrollController _scrollController;

  /// Flag to track if we've already called onLoadMore to prevent multiple calls.
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _setupScrollListener();
  }

  @override
  void didUpdateWidget(NAdaptiveListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update scroll controller if it changed
    if (widget.scrollController != oldWidget.scrollController) {
      _scrollController.removeListener(_onScroll);
      _scrollController = widget.scrollController ?? ScrollController();
      _setupScrollListener();
    }

    // Reset loading more state when data changes
    if (widget.items != oldWidget.items) {
      _isLoadingMore = false;
    }
  }

  /// Sets up the scroll listener for pagination.
  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  /// Scroll listener that triggers pagination when approaching the end of the list.
  void _onScroll() {
    if (widget.onLoadMore == null ||
        widget.hasReachedMax ||
        widget.isLoadingMore ||
        _isLoadingMore) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // If we're close enough to the bottom, load more data
    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      _isLoadingMore = true;
      widget.onLoadMore!().then((_) {
        _isLoadingMore = false;
      }).catchError((error) {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it internally
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading widget if in loading state
    if (widget.isLoading) {
      return _buildLoadingWidget();
    }

    // Show error widget if there's an error
    if (widget.hasError) {
      return _buildErrorWidget();
    }

    // Show empty widget if the list is empty
    if (widget.items.isEmpty) {
      return _buildEmptyWidget();
    }

    // Build the main list/grid with pull-to-refresh if needed
    return widget.onRefresh != null
        ? RefreshIndicator(
            onRefresh: widget.onRefresh!,
            child: _buildMainContent(),
          )
        : _buildMainContent();
  }

  /// Builds the main content (either ListView or GridView).
  Widget _buildMainContent() {
    return widget.isGridMode ? _buildGridView() : _buildListView();
  }

  /// Builds a ListView with all configured options.
  Widget _buildListView() {
    return ListView.builder(
      key: widget.listKey,
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _calculateItemCount(),
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      itemBuilder: (context, index) {
        return _buildItem(context, index);
      },
    );
  }

  /// Builds a GridView with all configured options.
  Widget _buildGridView() {
    return GridView.builder(
      key: widget.listKey,
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _calculateItemCount(),
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridCrossAxisCount,
        childAspectRatio: widget.gridChildAspectRatio,
        crossAxisSpacing: widget.gridCrossAxisSpacing,
        mainAxisSpacing: widget.gridMainAxisSpacing,
      ),
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      itemBuilder: (context, index) {
        return _buildItem(context, index);
      },
    );
  }

  /// Calculates the total item count including additional items (loading indicators, etc.).
  int _calculateItemCount() {
    int count = widget.items.length;

    // Add 1 for top builder if present
    if (widget.topBuilder != null) {
      count += 1;
    }

    // Add 1 for bottom builder or loading indicator
    if (widget.bottomBuilder != null ||
        (widget.isLoadingMore && !widget.hasReachedMax)) {
      count += 1;
    }

    return count;
  }

  /// Builds the appropriate widget for each position in the list.
  Widget _buildItem(BuildContext context, int index) {
    // Handle top builder (index 0)
    if (widget.topBuilder != null && index == 0) {
      return widget.topBuilder!(context);
    }

    // Adjust index if we have a top builder
    int adjustedIndex = index;
    if (widget.topBuilder != null) {
      adjustedIndex = index - 1;
    }

    // Handle bottom builder or loading indicator (last position)
    if (adjustedIndex == widget.items.length) {
      if (widget.bottomBuilder != null) {
        return widget.bottomBuilder!(context);
      }

      if (widget.isLoadingMore && !widget.hasReachedMax) {
        return _buildLoadMoreIndicator();
      }

      return const SizedBox.shrink();
    }

    // Regular item
    if (adjustedIndex < widget.items.length) {
      final item = widget.items[adjustedIndex];
      return widget.itemBuilder(
        context,
        adjustedIndex,
        item,
        widget.isGridMode,
      );
    }

    return const SizedBox.shrink();
  }

  /// Builds the loading indicator shown at the bottom when loading more items.
  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  /// Builds the widget shown when the list is empty.
  Widget _buildEmptyWidget() {
    return widget.emptyWidget ??
        const Center(
          child: Text('No items available'),
        );
  }

  /// Builds the widget shown when data is loading.
  Widget _buildLoadingWidget() {
    return widget.loadingWidget ??
        const Center(
          child: CircularProgressIndicator(),
        );
  }

  /// Builds the widget shown when an error occurs.
  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 16),
              ),
              if (widget.onRefresh != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.onRefresh,
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        );
  }
}

/// Example implementation of a paginated data source.
///
/// This class helps manage the state for pagination and can be used with AdaptiveListView.
class PaginatedDataSource<T> {
  /// Current list of items.
  List<T> items = [];

  /// Current page number (usually starts at 1).
  int currentPage = 1;

  /// Whether more data is currently being loaded.
  bool isLoading = false;

  /// Whether all data has been loaded.
  bool hasReachedMax = false;

  /// Whether an error occurred during loading.
  bool hasError = false;

  /// Function to load data for a specific page.
  final Future<List<T>> Function(int page) fetchData;

  /// Number of items per page.
  final int itemsPerPage;

  PaginatedDataSource({
    required this.fetchData,
    this.itemsPerPage = 20,
  });

  /// Loads the first page of data.
  Future<void> loadInitialData() async {
    if (isLoading) return;

    items = [];
    currentPage = 1;
    isLoading = true;
    hasError = false;
    hasReachedMax = false;

    try {
      final newItems = await fetchData(currentPage);
      items = newItems;
      hasReachedMax = newItems.length < itemsPerPage;
    } catch (e) {
      hasError = true;
    } finally {
      isLoading = false;
    }
  }

  /// Loads the next page of data.
  Future<void> loadNextPage() async {
    if (isLoading || hasReachedMax) return;

    isLoading = true;
    hasError = false;

    try {
      final nextPage = currentPage + 1;
      final newItems = await fetchData(nextPage);

      if (newItems.isEmpty) {
        hasReachedMax = true;
      } else {
        items.addAll(newItems);
        currentPage = nextPage;
        hasReachedMax = newItems.length < itemsPerPage;
      }
    } catch (e) {
      hasError = true;
    } finally {
      isLoading = false;
    }
  }

  /// Refreshes the data (typically used with pull-to-refresh).
  Future<void> refresh() async {
    await loadInitialData();
  }
}

// TODO: Usage example (Need to remove in production)
/*
*
* import 'package:flutter/material.dart';
import 'adaptive_list_view.dart';

/// Example screen demonstrating the use of AdaptiveListView for both list and grid layouts
/// with pagination support.
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  /// Flag to toggle between list and grid layouts
  bool _isGridMode = false;

  /// Simulated data source for pagination
  late PaginatedDataSource<Product> _dataSource;

  @override
  void initState() {
    super.initState();

    // Initialize the data source with a function to fetch data
    _dataSource = PaginatedDataSource<Product>(
      fetchData: _fetchProducts,
      itemsPerPage: 10,
    );

    // Load initial data
    _dataSource.loadInitialData();
  }

  /// Simulates fetching products from an API with pagination
  Future<List<Product>> _fetchProducts(int page) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate 10 products for the requested page (up to page 3)
    if (page > 3) {
      return []; // No more data after page 3
    }

    return List.generate(
      10,
      (index) => Product(
        id: (page - 1) * 10 + index + 1,
        name: 'Product ${(page - 1) * 10 + index + 1}',
        price: 10.0 + ((page - 1) * 10 + index) * 5.0,
        imageUrl: 'https://via.placeholder.com/150?text=Product+${(page - 1) * 10 + index + 1}',
        description: 'This is a description for Product ${(page - 1) * 10 + index + 1}. '
            'It contains some details about the product features and specifications.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Toggle button to switch between list and grid views
          IconButton(
            icon: Icon(_isGridMode ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridMode = !_isGridMode;
              });
            },
            tooltip: _isGridMode ? 'Show as list' : 'Show as grid',
          ),
        ],
      ),
      body: AnimatedBuilder(
        // Rebuild when the data source changes
        animation: ValueNotifier(_dataSource),
        builder: (context, _) {
          return AdaptiveListView<Product>(
            // Core properties
            items: _dataSource.items,
            isGridMode: _isGridMode,

            // Grid configuration
            gridCrossAxisCount: 2,
            gridChildAspectRatio: 0.8,
            gridCrossAxisSpacing: 16.0,
            gridMainAxisSpacing: 16.0,

            // Padding for both list and grid
            padding: const EdgeInsets.all(16.0),

            // Item builder for both list and grid layouts
            itemBuilder: (context, index, product, isGridMode) {
              // Return different layouts based on the current mode
              return isGridMode
                  ? _buildGridItem(product)
                  : _buildListItem(product);
            },

            // Pagination properties
            isLoading: _dataSource.isLoading && _dataSource.items.isEmpty,
            isLoadingMore: _dataSource.isLoading && _dataSource.items.isNotEmpty,
            hasReachedMax: _dataSource.hasReachedMax,
            hasError: _dataSource.hasError,
            onLoadMore: _dataSource.loadNextPage,
            onRefresh: _dataSource.refresh,

            // Optional custom widgets
            emptyWidget: const Center(
              child: Text('No products available', style: TextStyle(fontSize: 18)),
            ),
            errorWidget: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load products', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _dataSource.refresh,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a grid item for the product
  Widget _buildGridItem(Product product) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          AspectRatio(
            aspectRatio: 1.2,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 40),
                );
              },
            ),
          ),

          // Product details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a list item for the product
  Widget _buildListItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Handle product selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: ${product.name}')),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            SizedBox(
              width: 100,
              height: 100,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),

            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A model class representing a product.
class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}
*
*
* */
