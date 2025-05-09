import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NCarousel extends StatefulWidget {

  /// List of items to be displayed in the carousel.
  final List<CarouselItem> items;

  /// Height of the carousel.
  final double height;

  /// Width of the carousel. If null, it takes the parent's width.
  final double? width;

  /// Border radius for the carousel container.
  final BorderRadius borderRadius;

  /// Border for the carousel container.
  final Border? border;

  /// Box shape for the carousel.
  final BoxShape shape;

  /// Duration for auto-play transitions.
  final Duration autoPlayInterval;

  /// Whether to enable auto-play.
  final bool autoPlay;

  /// Position of the indicators.
  final IndicatorPosition indicatorPosition;

  /// Style for active indicator.
  final IndicatorStyle activeIndicatorStyle;

  /// Style for inactive indicator.
  final IndicatorStyle inactiveIndicatorStyle;

  /// Whether to show indicators.
  final bool showIndicators;

  /// Callback when an item is tapped.
  final Function(int index)? onTap;

  /// Initial page index.
  final int initialPage;

  /// Page controller for manual control.
  final PageController? pageController;

  /// Curve for page transitions.
  final Curve curve;

  /// Duration for page transitions.
  final Duration duration;

  /// Padding around the carousel.
  final EdgeInsets padding;

  /// Box shadow for the carousel container.
  final List<BoxShadow>? boxShadow;

  /// Placeholder widget shown while loading images or videos.
  final Widget? placeholder;

  /// Error widget shown when media fails to load.
  final Widget? errorWidget;

  const NCarousel({
    Key? key,
    required this.items,
    this.height = 200.0,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.border,
    this.shape = BoxShape.rectangle,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.autoPlay = false,
    this.indicatorPosition = IndicatorPosition.bottom,
    this.activeIndicatorStyle = const IndicatorStyle(
      width: 8.0,
      height: 8.0,
      color: Colors.blue,
      shape: BoxShape.circle,
    ),
    this.inactiveIndicatorStyle = const IndicatorStyle(
      width: 8.0,
      height: 8.0,
      color: Colors.grey,
      shape: BoxShape.circle,
    ),
    this.showIndicators = true,
    this.onTap,
    this.initialPage = 0,
    this.pageController,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
    this.padding = EdgeInsets.zero,
    this.boxShadow,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  _NCarouselState createState() => _NCarouselState();
}

class _NCarouselState extends State<NCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = widget.pageController ?? PageController(initialPage: widget.initialPage);

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.autoPlay) {
        if (_currentPage < widget.items.length - 1) {
          _pageController.nextPage(
            duration: widget.duration,
            curve: widget.curve,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: widget.duration,
            curve: widget.curve,
          );
        }
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: widget.shape == BoxShape.rectangle ? widget.borderRadius : null,
        border: widget.border,
        shape: widget.shape,
        boxShadow: widget.boxShadow,
      ),
      child: ClipRRect(
        borderRadius: widget.shape == BoxShape.rectangle ? widget.borderRadius : BorderRadius.circular(0),
        child: Stack(
          children: [
            // Main carousel content
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => widget.onTap?.call(index),
                  child: _buildItem(widget.items[index]),
                );
              },
            ),

            // Indicators
            if (widget.showIndicators && widget.items.length > 1)
              _buildIndicators(),

            // Item count badge
            if (widget.items.length > 1)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${widget.items.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(CarouselItem item) {
    switch (item.type) {
      case CarouselItemType.image:
        return _buildImageItem(item as ImageCarouselItem);
      case CarouselItemType.video:
        return _buildVideoItem(item as VideoCarouselItem);
      case CarouselItemType.widget:
        return (item as WidgetCarouselItem).child;
    }
  }

  Widget _buildImageItem(ImageCarouselItem item) {
    if (item.isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: item.imageUrl!,
        fit: item.fit,
        placeholder: (context, url) => widget.placeholder ?? const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => widget.errorWidget ?? const Center(child: Icon(Icons.error)),
      );
    } else {
      return Image.asset(
        item.assetPath!,
        fit: item.fit,
        errorBuilder: (context, error, stackTrace) =>
        widget.errorWidget ?? const Center(child: Icon(Icons.error)),
      );
    }
  }

  Widget _buildVideoItem(VideoCarouselItem item) {
    return VideoPlayerWidget(
      videoUrl: item.videoUrl,
      assetPath: item.assetPath,
      isNetworkVideo: item.isNetworkVideo,
      fit: item.fit,
      autoPlay: item.autoPlay,
      looping: item.looping,
      showControls: item.showControls,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
    );
  }

  Widget _buildIndicators() {
    Widget indicators = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
            (index) => _buildIndicator(index),
      ),
    );

    switch (widget.indicatorPosition) {
      case IndicatorPosition.bottom:
        return Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: indicators,
        );
      case IndicatorPosition.inside:
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.black.withOpacity(0.3),
            child: indicators,
          ),
        );
    }
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    final style = isActive
        ? widget.activeIndicatorStyle
        : widget.inactiveIndicatorStyle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: style.width,
      height: style.height,
      decoration: BoxDecoration(
        color: style.color,
        shape: style.shape,
        borderRadius: style.shape == BoxShape.rectangle
            ? BorderRadius.circular(style.borderRadius ?? 0)
            : null,
        border: style.border,
      ),
    );
  }
}

/// Widget for displaying videos in the carousel
class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String? assetPath;
  final bool isNetworkVideo;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final Widget? placeholder;
  final Widget? errorWidget;

  const VideoPlayerWidget({
    Key? key,
    this.videoUrl,
    this.assetPath,
    required this.isNetworkVideo,
    this.fit = BoxFit.cover,
    this.autoPlay = true,
    this.looping = true,
    this.showControls = true,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      if (widget.isNetworkVideo) {
        _controller = VideoPlayerController.network(widget.videoUrl!);
      } else {
        _controller = VideoPlayerController.asset(widget.assetPath!);
      }

      await _controller.initialize();

      if (widget.autoPlay) {
        _controller.play();
      }

      _controller.setLooping(widget.looping);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      print('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? const Center(child: Icon(Icons.error));
    }

    if (!_isInitialized) {
      return widget.placeholder ?? const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        FittedBox(
          fit: widget.fit,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        if (widget.showControls)
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.blue,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.white,
            ),
          ),
        if (widget.showControls)
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
          ),
      ],
    );
  }
}

/// Base class for carousel items
abstract class CarouselItem {
  final CarouselItemType type;

  CarouselItem({required this.type});
}

/// Image item for the carousel
class ImageCarouselItem extends CarouselItem {
  final String? imageUrl;
  final String? assetPath;
  final bool isNetworkImage;
  final BoxFit fit;

  ImageCarouselItem({
    this.imageUrl,
    this.assetPath,
    required this.isNetworkImage,
    this.fit = BoxFit.cover,
  }) : assert(isNetworkImage ? imageUrl != null : assetPath != null),
        super(type: CarouselItemType.image);

  /// Create an image item from a network URL
  factory ImageCarouselItem.network(String url, {BoxFit fit = BoxFit.cover}) {
    return ImageCarouselItem(
      imageUrl: url,
      isNetworkImage: true,
      fit: fit,
    );
  }

  /// Create an image item from an asset path
  factory ImageCarouselItem.asset(String path, {BoxFit fit = BoxFit.cover}) {
    return ImageCarouselItem(
      assetPath: path,
      isNetworkImage: false,
      fit: fit,
    );
  }
}

/// Video item for the carousel
class VideoCarouselItem extends CarouselItem {
  final String? videoUrl;
  final String? assetPath;
  final bool isNetworkVideo;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool showControls;

  VideoCarouselItem({
    this.videoUrl,
    this.assetPath,
    required this.isNetworkVideo,
    this.fit = BoxFit.cover,
    this.autoPlay = true,
    this.looping = true,
    this.showControls = true,
  }) : assert(isNetworkVideo ? videoUrl != null : assetPath != null),
        super(type: CarouselItemType.video);

  /// Create a video item from a network URL
  factory VideoCarouselItem.network(
      String url, {
        BoxFit fit = BoxFit.cover,
        bool autoPlay = true,
        bool looping = true,
        bool showControls = true,
      }) {
    return VideoCarouselItem(
      videoUrl: url,
      isNetworkVideo: true,
      fit: fit,
      autoPlay: autoPlay,
      looping: looping,
      showControls: showControls,
    );
  }

  /// Create a video item from an asset path
  factory VideoCarouselItem.asset(
      String path, {
        BoxFit fit = BoxFit.cover,
        bool autoPlay = true,
        bool looping = true,
        bool showControls = true,
      }) {
    return VideoCarouselItem(
      assetPath: path,
      isNetworkVideo: false,
      fit: fit,
      autoPlay: autoPlay,
      looping: looping,
      showControls: showControls,
    );
  }
}

/// Custom widget item for the carousel
class WidgetCarouselItem extends CarouselItem {
  final Widget child;

  WidgetCarouselItem({required this.child}) : super(type: CarouselItemType.widget);
}

/// Enum for carousel item types
enum CarouselItemType {
  image,
  video,
  widget,
}

/// Enum for indicator positions
enum IndicatorPosition {
  bottom,
  inside,
}

/// Style class for indicators
class IndicatorStyle {
  final double width;
  final double height;
  final Color color;
  final BoxShape shape;
  final double? borderRadius;
  final Border? border;

  const IndicatorStyle({
    required this.width,
    required this.height,
    required this.color,
    required this.shape,
    this.borderRadius,
    this.border,
  });
}