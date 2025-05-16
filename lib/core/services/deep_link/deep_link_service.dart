import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// This service handles:
/// 1. Initial deep link that opened the app
/// 2. Deep links received while the app is running
/// 3. Extracting and parsing query parameters
/// 4. Navigating to the appropriate route based on the link
class DeepLinkService {

  /// Instance of AppLinks from the app_links package
  final AppLinks _appLinks = AppLinks();

  /// Router to use for navigation
  final GoRouter _router;

  /// Stream controller to broadcast deep link events
  final StreamController<Uri> _deepLinkStreamController = StreamController<Uri>.broadcast();

  /// Stream of deep link events that can be listened to
  Stream<Uri> get deepLinkStream => _deepLinkStreamController.stream;

  /// Get the initial URI which opened the app
  Future<Uri?> get initialUri => _appLinks.getInitialLink();

  /// Singleton instance
  static DeepLinkService? _instance;

  /// Factory constructor for singleton pattern
  factory DeepLinkService(GoRouter router) {
    _instance ??= DeepLinkService._internal(router);
    return _instance!;
  }

  /// Private constructor for singleton
  DeepLinkService._internal(this._router) {
    _init();
  }

  /// Initialize the deep link service
  Future<void> _init() async {
    // Handle the initial deep link that may have opened the app
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        if (kDebugMode) {
          print('Initial deep link: $initialLink');
        }
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial deep link: $e');
      }
    }

    // Listen for deep links while app is running
    _appLinks.uriLinkStream.listen((uri) {
      if (kDebugMode) {
        print('Received deep link while app running: $uri');
      }
      _handleDeepLink(uri);
    }, onError: (error) {
      if (kDebugMode) {
        print('Error receiving deep link: $error');
      }
    });
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    // Broadcast the URI to listeners
    _deepLinkStreamController.add(uri);

    // Extract the path and query parameters
    final path = uri.path;
    final queryParams = uri.queryParameters;

    // Navigate based on the deep link
    _navigateToDeepLink(path, queryParams);
  }

  /// Navigate to the appropriate route based on the deep link
  void _navigateToDeepLink(String path, Map<String, String> queryParams) {
    // Add our router here to navigate to the appropriate screen
    /*switch (path) {
      case '/product':
        final productId = queryParams['id'];
        if (productId != null) {
          _router.go('/product/$productId', extra: queryParams);
        }
        break;

      case '/category':
        final categoryId = queryParams['id'];
        if (categoryId != null) {
          _router.go('/category/$categoryId', extra: queryParams);
        }
        break;

      case '/user-profile':
        final userId = queryParams['id'];
        if (userId != null) {
          _router.go('/profile/$userId', extra: queryParams);
        }
        break;

      case '/promo':
      // Pass all query parameters as extra
        _router.go('/promotions', extra: queryParams);
        break;

      case '/search':
        final query = queryParams['q'];
        if (query != null) {
          _router.go('/search', extra: {'query': query, ...queryParams});
        }
        break;

      default:
      // Handle unknown paths or redirect to home
        _router.go('/', extra: queryParams);
        break;
    }*/
  }

  /// Parse Uri string to Uri object
  Uri? parseUri(String uriString) {
    try {
      return Uri.parse(uriString);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing URI: $e');
      }
      return null;
    }
  }

  /// Check if a path is a deep link path
  bool isDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      // Check if the URI has your app's scheme
      return uri.scheme == 'myapp' ||
          (uri.scheme == 'https' && uri.host == 'myapp.example.com');
    } catch (e) {
      return false;
    }
  }

  /// Process a manually entered URL or link from elsewhere in the app
  void processManualLink(String url) {
    final uri = parseUri(url);
    if (uri != null) {
      _handleDeepLink(uri);
    }
  }

  /// Dispose the service, closing streams
  void dispose() {
    _deepLinkStreamController.close();
  }
}


/*
*
* //Configuring deep links in native side (Android and IOS)
*
* # Platform Configuration for Deep Links in Flutter

## 1. Update pubspec.yaml

First, add the required dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  app_links: ^3.4.3  # Use latest version
  go_router: ^13.0.0  # Use latest version
```

Run `flutter pub get` to install the dependencies.

## 2. Android Configuration

### Step 1: Update AndroidManifest.xml

Add the following inside the `<activity>` tag in your `android/app/src/main/AndroidManifest.xml` file:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <!-- For app scheme deep links (myapp://) -->
    <data android:scheme="myapp" />

    <!-- For https links (https://myapp.example.com) -->
    <data android:scheme="https"
          android:host="myapp.example.com" />
</intent-filter>
```

### Step 2: Create an assetlinks.json file

Create an `assetlinks.json` file and host it at `https://myapp.example.com/.well-known/assetlinks.json`:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.myapp",
    "sha256_cert_fingerprints": [
      "YOUR_APP_FINGERPRINT"
    ]
  }
}]
```

To get your SHA-256 fingerprint, use the following command:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds, use your upload keystore instead.

## 3. iOS Configuration

### Step 1: Update Info.plist

Add the following to your `ios/Runner/Info.plist` file inside the `<dict>` tag:

```xml
<!-- For URL Schemes (myapp://) -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.myapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>

<!-- For Universal Links (https://myapp.example.com) -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:myapp.example.com</string>
</array>
```

### Step 2: Create an apple-app-site-association file

Create an `apple-app-site-association` (AASA) file (no file extension) and host it at `https://myapp.example.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.example.myapp",
        "paths": ["*"]
      }
    ]
  }
}
```

Replace `TEAM_ID` with your Apple Developer Team ID.

### Step 3: Enable Associated Domains capability

1. In Xcode, open your project
2. Navigate to your target's "Signing & Capabilities" tab
3. Click "+" and add "Associated Domains"
4. Add "applinks:myapp.example.com"

## 4. Testing Deep Links

### For Android:

```bash
# Using adb (Android Debug Bridge)
adb shell am start -a android.intent.action.VIEW -d "myapp://product?id=123"

# For HTTPS links
adb shell am start -a android.intent.action.VIEW -d "https://myapp.example.com/product?id=123"
```

### For iOS Simulator:

```bash
# Using xcrun
xcrun simctl openurl booted "myapp://product?id=123"

# For HTTPS links
xcrun simctl openurl booted "https://myapp.example.com/product?id=123"
```

### For Physical iOS Device:
Create a simple HTML file with links to test on a physical device:

```html
<a href="myapp://product?id=123">Open Product in App</a>
<a href="https://myapp.example.com/product?id=123">Open Product via Universal Link</a>
```
*
* *************************************************************************************************
*
* // Usage Example:
*
* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'deep_link_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create the router configuration
  late final GoRouter _router;

  // Create the deep link service
  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();

    // Define your application routes
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            // Extract route parameters
            final productId = state.pathParameters['id'];

            // Extract extra parameters (query parameters from deep link)
            final extraParams = state.extra as Map<String, String>?;

            return ProductDetailPage(
              productId: productId!,
              extraParams: extraParams,
            );
          },
        ),
        GoRoute(
          path: '/category/:id',
          builder: (context, state) {
            final categoryId = state.pathParameters['id'];
            final extraParams = state.extra as Map<String, String>?;

            return CategoryPage(
              categoryId: categoryId!,
              extraParams: extraParams,
            );
          },
        ),
        GoRoute(
          path: '/profile/:id',
          builder: (context, state) {
            final userId = state.pathParameters['id'];
            final extraParams = state.extra as Map<String, String>?;

            return UserProfilePage(
              userId: userId!,
              extraParams: extraParams,
            );
          },
        ),
        GoRoute(
          path: '/promotions',
          builder: (context, state) {
            final extraParams = state.extra as Map<String, String>?;

            return PromotionsPage(
              promoData: extraParams,
            );
          },
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) {
            final extraParams = state.extra as Map<String, dynamic>?;

            return SearchPage(
              query: extraParams?['query'] as String? ?? '',
              filters: extraParams,
            );
          },
        ),
      ],
    );

    // Initialize deep link service with the router
    _deepLinkService = DeepLinkService(_router);

    // Optional: Listen to deep link events for custom handling
    _deepLinkService.deepLinkStream.listen((uri) {
      // Custom handling of deep links if needed
      debugPrint('Deep link received in main.dart: ${uri.toString()}');

      // You could show a snackbar, dialog, or perform other actions here
      // For example, tracking analytics events for deep links
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Deep Link Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Use the GoRouter for routing
      routerConfig: _router,
    );
  }

  @override
  void dispose() {
    // Properly dispose the deep link service
    _deepLinkService.dispose();
    super.dispose();
  }
}

// Example pages

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Page'),
            const SizedBox(height: 20),
            // Example of manually triggering deep links within the app
            ElevatedButton(
              onPressed: () {
                // You can use the DeepLinkService to handle internal links
                final deepLinkService = DeepLinkService(GoRouter.of(context));
                deepLinkService.processManualLink('myapp://product?id=123&color=red');
              },
              child: const Text('Go to Product 123'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final Map<String, String>? extraParams;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.extraParams,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product $productId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Product ID: $productId'),
            const SizedBox(height: 20),
            if (extraParams != null && extraParams!.isNotEmpty)
              ...extraParams!.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String categoryId;
  final Map<String, String>? extraParams;

  const CategoryPage({
    super.key,
    required this.categoryId,
    this.extraParams,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category $categoryId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Category ID: $categoryId'),
            const SizedBox(height: 20),
            if (extraParams != null)
              ...extraParams!.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

class UserProfilePage extends StatelessWidget {
  final String userId;
  final Map<String, String>? extraParams;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.extraParams,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile $userId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: $userId'),
            const SizedBox(height: 20),
            if (extraParams != null)
              ...extraParams!.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

class PromotionsPage extends StatelessWidget {
  final Map<String, String>? promoData;

  const PromotionsPage({
    super.key,
    this.promoData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Promotions Page'),
            const SizedBox(height: 20),
            if (promoData != null && promoData!.isNotEmpty)
              ...promoData!.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  final String query;
  final Map<String, dynamic>? filters;

  const SearchPage({
    super.key,
    required this.query,
    this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search: $query')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Search Query: $query'),
            const SizedBox(height: 20),
            if (filters != null)
              ...filters!.entries
                  .where((entry) => entry.key != 'query')
                  .map(
                    (entry) => Text('${entry.key}: ${entry.value}'),
                  ),
          ],
        ),
      ),
    );
  }
}
*
*
* */