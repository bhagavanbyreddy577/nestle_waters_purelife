import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ShareHelper class provides comprehensive sharing functionality for ecommerce products
/// Supports text, links, and images sharing across Android and iOS platforms
class NShareHelper {
  // Private constructor to prevent instantiation
  NShareHelper._();

  /// Shares product details with text content
  ///
  /// [productName] - Name of the product to share
  /// [productPrice] - Price of the product
  /// [productDescription] - Brief description of the product
  /// [productUrl] - Deep link or web URL to the product
  /// [context] - BuildContext for positioning share dialog (optional)
  static Future<void> shareProduct({
    required String productName,
    required String productPrice,
    String? productDescription,
    String? productUrl,
    BuildContext? context,
  }) async {
    try {
      // Build the share text content
      String shareText = _buildProductShareText(
        productName: productName,
        productPrice: productPrice,
        productDescription: productDescription,
        productUrl: productUrl,
      );

      // Get share position for iPad positioning
      Rect? sharePositionOrigin;
      if (context != null) {
        sharePositionOrigin = _getSharePosition(context);
      }

      // Share the content
      await Share.share(
        shareText,
        subject: 'Check out this product: $productName',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint('Error sharing product: $e');
      // Optionally show error to user
      if (context != null) {
        _showShareError(context);
      }
    }
  }

  /// Shares product with image
  ///
  /// [productName] - Name of the product
  /// [productPrice] - Price of the product
  /// [imageUrl] - URL of the product image
  /// [productDescription] - Brief description (optional)
  /// [productUrl] - Product link (optional)
  /// [context] - BuildContext for positioning (optional)
  static Future<void> shareProductWithImage({
    required String productName,
    required String productPrice,
    required String imageUrl,
    String? productDescription,
    String? productUrl,
    BuildContext? context,
  }) async {
    try {
      // Build share text
      String shareText = _buildProductShareText(
        productName: productName,
        productPrice: productPrice,
        productDescription: productDescription,
        productUrl: productUrl,
      );

      // Get share position for iPad
      Rect? sharePositionOrigin;
      if (context != null) {
        sharePositionOrigin = _getSharePosition(context);
      }

      // Share with image URL
      await Share.shareUri(
        Uri.parse(imageUrl),
        sharePositionOrigin: sharePositionOrigin,
      );

      // Also share the text content
      await Share.share(
        shareText,
        subject: 'Check out this product: $productName',
        sharePositionOrigin: sharePositionOrigin,
      );

    } catch (e) {
      debugPrint('Error sharing product with image: $e');
      if (context != null) {
        _showShareError(context);
      }
    }
  }

  /// Shares product with local image file
  ///
  /// [productName] - Name of the product
  /// [productPrice] - Price of the product
  /// [imagePath] - Local file path to the image
  /// [productDescription] - Brief description (optional)
  /// [productUrl] - Product link (optional)
  /// [context] - BuildContext for positioning (optional)
  static Future<void> shareProductWithLocalImage({
    required String productName,
    required String productPrice,
    required String imagePath,
    String? productDescription,
    String? productUrl,
    BuildContext? context,
  }) async {
    try {
      // Build share text
      String shareText = _buildProductShareText(
        productName: productName,
        productPrice: productPrice,
        productDescription: productDescription,
        productUrl: productUrl,
      );

      // Get share position
      Rect? sharePositionOrigin;
      if (context != null) {
        sharePositionOrigin = _getSharePosition(context);
      }

      // Create XFile from local path
      final XFile imageFile = XFile(imagePath);

      // Share with local image file
      await Share.shareXFiles(
        [imageFile],
        text: shareText,
        subject: 'Check out this product: $productName',
        sharePositionOrigin: sharePositionOrigin,
      );

    } catch (e) {
      debugPrint('Error sharing product with local image: $e');
      if (context != null) {
        _showShareError(context);
      }
    }
  }

  /// Shares a simple product link
  ///
  /// [productUrl] - URL to share
  /// [productName] - Name of the product (optional)
  /// [context] - BuildContext for positioning (optional)
  static Future<void> shareProductLink({
    required String productUrl,
    String? productName,
    BuildContext? context,
  }) async {
    try {
      String shareText = productName != null
          ? 'Check out this product: $productName\n$productUrl'
          : productUrl;

      Rect? sharePositionOrigin;
      if (context != null) {
        sharePositionOrigin = _getSharePosition(context);
      }

      await Share.share(
        shareText,
        subject: productName != null ? 'Check out: $productName' : 'Product Link',
        sharePositionOrigin: sharePositionOrigin,
      );

    } catch (e) {
      debugPrint('Error sharing product link: $e');
      if (context != null) {
        _showShareError(context);
      }
    }
  }

  /// Copies product details to clipboard
  ///
  /// [productName] - Name of the product
  /// [productPrice] - Price of the product
  /// [productDescription] - Description (optional)
  /// [productUrl] - Product URL (optional)
  /// [context] - BuildContext to show confirmation (optional)
  static Future<void> copyProductToClipboard({
    required String productName,
    required String productPrice,
    String? productDescription,
    String? productUrl,
    BuildContext? context,
  }) async {
    try {
      String shareText = _buildProductShareText(
        productName: productName,
        productPrice: productPrice,
        productDescription: productDescription,
        productUrl: productUrl,
      );

      await Clipboard.setData(ClipboardData(text: shareText));

      // Show confirmation to user
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product details copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
    }
  }

  /// Builds formatted share text for product
  ///
  /// Private helper method to create consistent share text format
  static String _buildProductShareText({
    required String productName,
    required String productPrice,
    String? productDescription,
    String? productUrl,
  }) {
    StringBuffer shareText = StringBuffer();

    shareText.writeln('🛍️ Check out this amazing product!');
    shareText.writeln('');
    shareText.writeln('📦 Product: $productName');
    shareText.writeln('💰 Price: $productPrice');

    if (productDescription != null && productDescription.isNotEmpty) {
      shareText.writeln('📝 Description: $productDescription');
    }

    if (productUrl != null && productUrl.isNotEmpty) {
      shareText.writeln('');
      shareText.writeln('🔗 View Product: $productUrl');
    }

    shareText.writeln('');
    shareText.write('Shared via [Your App Name]');

    return shareText.toString();
  }

  /// Gets the share position for iPad popup positioning
  ///
  /// Private helper method to calculate share dialog position
  static Rect? _getSharePosition(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }

  /// Shows error message when sharing fails
  ///
  /// Private helper method to display error to user
  static void _showShareError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to share product. Please try again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

/// TODO: Usage Example (Need to remove in production)
/*
*
* /// Example usage of ShareHelper class
class ShareHelperExample {

  /// Example: Share product from a product detail page
  static void shareProductExample(BuildContext context) {
    ShareHelper.shareProduct(
      productName: 'Wireless Bluetooth Headphones',
      productPrice: '\$79.99',
      productDescription: 'High-quality wireless headphones with noise cancellation',
      productUrl: 'https://yourstore.com/products/wireless-headphones-123',
      context: context,
    );
  }

  /// Example: Share product with image
  static void shareProductWithImageExample(BuildContext context) {
    ShareHelper.shareProductWithImage(
      productName: 'Smart Watch Pro',
      productPrice: '\$299.99',
      imageUrl: 'https://yourstore.com/images/smartwatch-pro.jpg',
      productDescription: 'Advanced smartwatch with health monitoring',
      productUrl: 'https://yourstore.com/products/smartwatch-pro-456',
      context: context,
    );
  }

  /// Example: Share from a share button widget
  static Widget buildShareButton({
    required String productName,
    required String productPrice,
    String? productDescription,
    String? productUrl,
    String? imageUrl,
  }) {
    return Builder(
      builder: (context) => ElevatedButton.icon(
        onPressed: () {
          if (imageUrl != null) {
            ShareHelper.shareProductWithImage(
              productName: productName,
              productPrice: productPrice,
              imageUrl: imageUrl,
              productDescription: productDescription,
              productUrl: productUrl,
              context: context,
            );
          } else {
            ShareHelper.shareProduct(
              productName: productName,
              productPrice: productPrice,
              productDescription: productDescription,
              productUrl: productUrl,
              context: context,
            );
          }
        },
        icon: const Icon(Icons.share),
        label: const Text('Share Product'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// Example: Bottom sheet with share options
  static void showShareOptions({
    required BuildContext context,
    required String productName,
    required String productPrice,
    String? productDescription,
    String? productUrl,
    String? imageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Details'),
                onTap: () {
                  Navigator.pop(context);
                  ShareHelper.shareProduct(
                    productName: productName,
                    productPrice: productPrice,
                    productDescription: productDescription,
                    productUrl: productUrl,
                    context: context,
                  );
                },
              ),

              if (imageUrl != null)
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Share with Image'),
                  onTap: () {
                    Navigator.pop(context);
                    ShareHelper.shareProductWithImage(
                      productName: productName,
                      productPrice: productPrice,
                      imageUrl: imageUrl,
                      productDescription: productDescription,
                      productUrl: productUrl,
                      context: context,
                    );
                  },
                ),

              if (productUrl != null)
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Share Link Only'),
                  onTap: () {
                    Navigator.pop(context);
                    ShareHelper.shareProductLink(
                      productUrl: productUrl,
                      productName: productName,
                      context: context,
                    );
                  },
                ),

              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy to Clipboard'),
                onTap: () {
                  Navigator.pop(context);
                  ShareHelper.copyProductToClipboard(
                    productName: productName,
                    productPrice: productPrice,
                    productDescription: productDescription,
                    productUrl: productUrl,
                    context: context,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
*********************************************************************************
Configuration steps:

# Share Helper Configuration Guide

## Required Dependencies

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  share_plus: ^7.2.2  # Latest version as of 2024
```

Then run:
```bash
flutter pub get
```

## Android Configuration

### 1. Update `android/app/src/main/AndroidManifest.xml`

Add the following permissions and activity configurations:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="28" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32" />

    <application
        android:label="Your App Name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <!-- Your main activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- Add intent filters for sharing -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https"
                      android:host="yourstore.com" />
            </intent-filter>

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Add FileProvider for sharing files -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 2. Create File Provider Paths

Create file: `android/app/src/main/res/xml/file_paths.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-files-path name="external_files" path="."/>
    <external-cache-path name="external_cache" path="."/>
    <cache-path name="cache" path="."/>
    <files-path name="files" path="."/>
</paths>
```

### 3. Update Gradle Configuration (Optional)

In `android/app/build.gradle`, ensure minimum SDK version supports sharing:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.yourcompany.yourapp"
        minSdkVersion 21  // Minimum for share_plus
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

## iOS Configuration

### 1. Update `ios/Runner/Info.plist`

Add the following configurations:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing configurations -->

    <!-- Add URL scheme for deep linking (optional) -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.yourcompany.yourapp</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>yourapp</string>
                <string>https</string>
            </array>
        </dict>
    </array>

    <!-- Add photo library usage description if sharing images -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to photo library to share product images.</string>

    <!-- Add camera usage description if needed -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to capture and share product photos.</string>

    <!-- Required for iOS 14+ -->
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>

    <!-- Support document types for sharing -->
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Images</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.image</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### 2. iOS Deployment Target

Ensure your iOS deployment target is at least 12.0 in `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## Usage Examples

### Basic Product Sharing

```dart
// In your product detail page
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProduct(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Your product details
          ElevatedButton(
            onPressed: () => _shareProduct(context),
            child: const Text('Share Product'),
          ),
        ],
      ),
    );
  }

  void _shareProduct(BuildContext context) {
    ShareHelper.shareProduct(
      productName: product.name,
      productPrice: product.price,
      productDescription: product.description,
      productUrl: product.url,
      context: context,
    );
  }
}
```

### Share Button Widget

```dart
// Reusable share button widget
class ProductShareButton extends StatelessWidget {
  final Product product;

  const ProductShareButton({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShareHelperExample.buildShareButton(
      productName: product.name,
      productPrice: product.price,
      productDescription: product.description,
      productUrl: product.url,
      imageUrl: product.imageUrl,
    );
  }
}
```

### Share Options Bottom Sheet

```dart
// Show share options in product card
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Product image and details
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showShareOptions(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    ShareHelperExample.showShareOptions(
      context: context,
      productName: product.name,
      productPrice: product.price,
      productDescription: product.description,
      productUrl: product.url,
      imageUrl: product.imageUrl,
    );
  }
}
```

## Testing

1. **Android Testing:**
   - Test on different Android versions (API 21+)
   - Verify sharing works with various apps (WhatsApp, Telegram, Gmail, etc.)
   - Test file sharing permissions

2. **iOS Testing:**
   - Test on iOS 12+ devices
   - Verify iPad popup positioning works correctly
   - Test sharing to different apps (Messages, Mail, Social media)

3. **Cross-platform Testing:**
   - Test text-only sharing
   - Test sharing with images (both URL and local files)
   - Test clipboard functionality
   - Verify error handling

## Troubleshooting

### Common Issues:

1. **File Provider Error (Android):**
   - Ensure `file_paths.xml` is created correctly
   - Check FileProvider authority matches `${applicationId}.fileprovider`

2. **Sharing Not Working on iOS:**
   - Verify Info.plist configurations
   - Check iOS deployment target is 12.0+

3. **Image Sharing Issues:**
   - Ensure proper permissions for photo access
   - Check image file paths and URLs are valid

4. **Share Dialog Not Appearing:**
   - Verify context is valid when calling share methods
   - Check if device has apps that can handle sharing

### Performance Tips:

1. Use `shareProductLink()` for lightweight sharing
2. Optimize image sizes before sharing
3. Cache frequently shared content
4. Handle network errors gracefully when sharing images from URLs

*/