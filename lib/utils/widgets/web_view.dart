import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NWebViewScreen extends StatefulWidget {

  /// The URL to load in the WebView.
  final String url;

  /// The title of the app bar.
  final String title;

  /// Whether to show a back button in the app bar.
  final bool showBackButton;

  /// The background color of the screen.
  final Color backgroundColor;

  /// Whether to enable JavaScript.
  final bool enableJavaScript;

  /// Whether to show the WebView's navigation controls (back/forward).
  final bool showNavigationControl;

  /// Constructor for the WebViewScreen.
  ///
  /// The [url] is required and specifies the URL to load.
  const NWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Web Page', // Default title.
    this.showBackButton = true,
    this.backgroundColor = Colors.white, // Default background color.
    this.enableJavaScript = true,
    this.showNavigationControl = false,
  });

  @override
  _NWebViewScreenState createState() => _NWebViewScreenState();
}

class _NWebViewScreenState extends State<NWebViewScreen> {
  late final WebViewController _webViewController;
  var _loadingPercentage = 0; // Track loading percentage

  @override
  void initState() {
    super.initState();
    // Initialize the WebView controller.
    _initializeWebView();
  }

  void _initializeWebView() {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(
          widget.enableJavaScript ? JavaScriptMode.unrestricted : JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _loadingPercentage = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingPercentage = 100;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    _webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor, // Set the background color.
      appBar: AppBar(
        title: Text(widget.title), // Use the provided title.
        // Show back button if enabled.
        leading: widget.showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
            : null,
        actions: widget.showNavigationControl
            ? [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              if (await _webViewController.canGoBack()) {
                await _webViewController.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              if (await _webViewController.canGoForward()) {
                await _webViewController.goForward();
              }
            },
          ),
        ]
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          _loadingPercentage < 100 ?
          LinearProgressIndicator(
            value: _loadingPercentage / 100,
          ) : Container(),
        ],
      ),
    );
  }
}