import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

/// Result of a file download operation
class DownloadResult {
  /// Whether the download was successful
  final bool success;

  /// Path to the downloaded file (only available if success is true)
  final String? filePath;

  /// Error message (only available if success is false)
  final String? error;

  /// Progress value between 0.0 and 1.0
  final double progress;

  DownloadResult({
    required this.success,
    this.filePath,
    this.error,
    this.progress = 0.0,
  });

  @override
  String toString() => 'DownloadResult(success: $success, filePath: $filePath, error: $error, progress: $progress)';
}

/// Helper class for downloading files from the internet
class NFileDownloaderHelper {
  /// Private constructor to prevent direct instantiation
  NFileDownloaderHelper._();

  /// Singleton instance
  static final NFileDownloaderHelper _instance = NFileDownloaderHelper._();

  /// Access the singleton instance
  static NFileDownloaderHelper get instance => _instance;

  /// Map to keep track of active downloads
  final Map<String, StreamController<DownloadResult>> _activeDownloads = {};

  /// Check and request permissions required for downloading and saving files
  ///
  /// Returns true if all permissions are granted, false otherwise
  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+ (SDK 33+)
      if (await Permission.mediaLibrary.status.isDenied) {
        final status = await Permission.mediaLibrary.request();
        if (!status.isGranted) {
          return false;
        }
      }

      // For Android 10+ (SDK 29+)
      if (await Permission.storage.status.isDenied) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          return false;
        }
      }

      return true;
    } else if (Platform.isIOS) {
      // iOS requires permissions for Photos if saving to gallery
      // For regular file storage, no permission is needed
      return true;
    }

    return false;
  }

  /// Get the appropriate directory for saving downloaded files
  ///
  /// [directory] parameter can be:
  /// - 'documents': App's documents directory (default)
  /// - 'temporary': App's temporary directory
  /// - 'external': External storage directory (Android only)
  /// - 'cache': App's cache directory
  Future<Directory> _getDirectory(String directory) async {
    switch (directory.toLowerCase()) {
      case 'documents':
        return await getApplicationDocumentsDirectory();
      case 'temporary':
        return await getTemporaryDirectory();
      case 'external':
        if (Platform.isAndroid) {
          final dirs = await getExternalStorageDirectories();
          if (dirs != null && dirs.isNotEmpty) {
            return dirs.first;
          }
          throw Exception('External storage is not available');
        } else {
          // Fall back to documents directory on iOS
          return await getApplicationDocumentsDirectory();
        }
      case 'cache':
        return await getTemporaryDirectory();
      default:
        return await getApplicationDocumentsDirectory();
    }
  }

  /// Extract filename from URL or use provided filename
  String _getFilename(String url, String? filename) {
    if (filename != null && filename.isNotEmpty) {
      return filename;
    }

    // Extract filename from URL
    final uri = Uri.parse(url);
    String fileName = path.basename(uri.path);

    // If no filename could be extracted, generate a timestamp-based one
    if (fileName.isEmpty || !fileName.contains('.')) {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      fileName = 'download_$timestamp.file';
    }

    return fileName;
  }

  /// Download a file from the given URL and save it to the device
  ///
  /// Parameters:
  /// - [url]: The URL of the file to download
  /// - [filename]: Optional filename to use (default: extracted from URL)
  /// - [directory]: Type of directory to save the file (documents, temporary, external, cache)
  /// - [headers]: Optional HTTP headers for the download request
  ///
  /// Returns a Stream of [DownloadResult] that provides download progress and final result
  Stream<DownloadResult> downloadFile({
    required String url,
    String? filename,
    String directory = 'documents',
    Map<String, String>? headers,
  }) async* {
    // Create a unique key for this download
    final downloadKey = '${url}_${DateTime.now().millisecondsSinceEpoch}';

    // Create a stream controller for this download
    final streamController = StreamController<DownloadResult>.broadcast();
    _activeDownloads[downloadKey] = streamController;

    try {
      // Check permissions
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        streamController.add(DownloadResult(
          success: false,
          error: 'Storage permission denied',
          progress: 0.0,
        ));
        yield* streamController.stream;
        return;
      }

      // Get appropriate directory
      final saveDir = await _getDirectory(directory);

      // Get filename
      final saveFilename = _getFilename(url, filename);
      final savePath = path.join(saveDir.path, saveFilename);

      // Create file
      final file = File(savePath);

      // Make HTTP request
      final request = http.Request('GET', Uri.parse(url));
      if (headers != null) {
        request.headers.addAll(headers);
      }

      final httpClient = http.Client();
      final response = await httpClient.send(request);

      if (response.statusCode != 200) {
        streamController.add(DownloadResult(
          success: false,
          error: 'HTTP error: ${response.statusCode}',
          progress: 0.0,
        ));
        yield* streamController.stream;
        return;
      }

      // Get total size for progress calculation
      final totalBytes = response.contentLength ?? -1;
      int receivedBytes = 0;

      // Create file and prepare for writing
      final sink = file.openWrite();

      // Listen to response stream and write to file
      await response.stream.forEach((List<int> chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        // Calculate progress
        double progress = totalBytes > 0 ? receivedBytes / totalBytes : 0.0;

        // Send progress update
        streamController.add(DownloadResult(
          success: false, // Not complete yet
          progress: progress,
        ));
      });

      // Close file
      await sink.flush();
      await sink.close();

      // Complete download
      streamController.add(DownloadResult(
        success: true,
        filePath: savePath,
        progress: 1.0,
      ));

      yield* streamController.stream;

    } catch (e) {
      streamController.add(DownloadResult(
        success: false,
        error: 'Download error: ${e.toString()}',
        progress: 0.0,
      ));
      yield* streamController.stream;
    } finally {
      // Clean up
      await streamController.close();
      _activeDownloads.remove(downloadKey);
    }
  }

  /// Cancel an active download
  ///
  /// [url]: The URL of the download to cancel
  void cancelDownload(String url) {
    final keysToRemove = _activeDownloads.keys
        .where((key) => key.startsWith('${url}_'))
        .toList();

    for (final key in keysToRemove) {
      _activeDownloads[key]?.close();
      _activeDownloads.remove(key);
    }
  }

  /// Cancel all active downloads
  void cancelAllDownloads() {
    for (final controller in _activeDownloads.values) {
      controller.close();
    }
    _activeDownloads.clear();
  }

  /// Download a file and return the result when complete (no progress updates)
  ///
  /// This is a simplified version for when progress updates aren't needed
  Future<DownloadResult> downloadFileSimple({
    required String url,
    String? filename,
    String directory = 'documents',
    Map<String, String>? headers,
  }) async {
    final completer = Completer<DownloadResult>();

    downloadFile(
      url: url,
      filename: filename,
      directory: directory,
      headers: headers,
    ).listen(
          (result) {
        // Only complete when the download is finished (success or error)
        if (result.success || (result.error != null && result.error!.isNotEmpty)) {
          completer.complete(result);
        }
      },
      onError: (error) {
        completer.complete(DownloadResult(
          success: false,
          error: error.toString(),
        ));
      },
    );

    return completer.future;
  }
}

/// Example usage for the file downloader
class FileDownloadExample {
  /// Example of how to download a file with progress updates
  static void downloadWithProgress() {
    final downloader = NFileDownloaderHelper.instance;

    // Start the download
    final downloadStream = downloader.downloadFile(
      url: 'https://example.com/sample.pdf',
      filename: 'my_file.pdf',
      directory: 'documents',
      headers: {'Authorization': 'Bearer YOUR_TOKEN'},
    );

    // Listen to download progress and result
    downloadStream.listen(
          (result) {
        if (result.success) {
          // Download completed successfully
          print('File downloaded to: ${result.filePath}');
          // You can now use the downloaded file
          // For example, open it with a plugin like open_file
        } else if (result.error != null) {
          // An error occurred
          print('Download error: ${result.error}');
        } else {
          // Progress update
          final percentage = (result.progress * 100).toStringAsFixed(1);
          print('Download progress: $percentage%');
        }
      },
      onError: (error) {
        print('Download stream error: $error');
      },
    );
  }

  /// Example of how to download a file without progress updates
  static Future<void> downloadSimple() async {
    final downloader = NFileDownloaderHelper.instance;

    try {
      final result = await downloader.downloadFileSimple(
        url: 'https://example.com/sample.pdf',
        filename: 'my_file.pdf',
      );

      if (result.success) {
        print('File downloaded to: ${result.filePath}');
        // Use the downloaded file
      } else {
        print('Download failed: ${result.error}');
      }
    } catch (e) {
      print('Download exception: $e');
    }
  }

  /// Example of how to download and save an image from your e-commerce app
  static Future<void> downloadProductImage(String imageUrl, String productName) async {
    final downloader = NFileDownloaderHelper.instance;

    // Generate a clean filename from product name
    final cleanName = productName.replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '_')
        .toLowerCase();

    // Get file extension from URL
    final extension = path.extension(imageUrl).isNotEmpty
        ? path.extension(imageUrl)
        : '.jpg';

    final filename = '$cleanName$extension';

    try {
      final result = await downloader.downloadFileSimple(
        url: imageUrl,
        filename: filename,
        directory: Platform.isIOS ? 'documents' : 'external',
      );

      if (result.success) {
        print('Product image downloaded to: ${result.filePath}');
      } else {
        print('Product image download failed: ${result.error}');
      }
    } catch (e) {
      print('Product image download exception: $e');
    }
  }
}


/// TODO: Usage exmaple (Need top remove in production)
/*
*
* # Native Setup Required for File Downloader

## Android Setup

1. **Add permissions to AndroidManifest.xml** (located at `android/app/src/main/AndroidManifest.xml`):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.yourapp">

    <!-- Internet permission -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- Storage permissions -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />

    <!-- For Android 13+ -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- ... rest of your manifest ... -->
</manifest>
```

2. **Update the minSdkVersion** in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // Ensure minSdkVersion is 21 or higher
        minSdkVersion 21
        // ...
    }
}
```

## iOS Setup

1. **Update Info.plist** (located at `ios/Runner/Info.plist`):

```xml
<dict>
    <!-- ... other configurations ... -->

    <!-- For saving images to Photos -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>This app needs access to save images to your photo library.</string>

    <!-- For accessing file system -->
    <key>UISupportsDocumentBrowser</key>
    <true/>
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
</dict>
```

## Flutter Project Setup

1. **Add required packages** to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5  # For network requests
  path_provider: ^2.0.11  # For accessing file system directories
  permission_handler: ^10.2.0  # For handling permissions
  path: ^1.8.2  # For path manipulation
  # Optional packages for additional functionality
  open_file: ^3.2.1  # For opening downloaded files
  flutter_local_notifications: ^13.0.0  # For showing download notifications
```

2. **Run flutter pub get** to install dependencies:

```bash
flutter pub get
```

## Usage Example

```dart
import 'package:your_app/utils/file_downloader.dart';

void downloadProductImage() {
  // For progress tracking
  FileDownloader.instance.downloadFile(
    url: 'https://your-ecommerce.com/products/image123.jpg',
    filename: 'awesome_product.jpg',
  ).listen((result) {
    if (result.success) {
      print('Download completed: ${result.filePath}');
    } else if (result.error != null) {
      print('Error: ${result.error}');
    } else {
      print('Progress: ${(result.progress * 100).toStringAsFixed(0)}%');
    }
  });

  // OR for simple usage without progress
  FileDownloader.instance.downloadFileSimple(
    url: 'https://your-ecommerce.com/products/image123.jpg',
    filename: 'awesome_product.jpg',
  ).then((result) {
    if (result.success) {
      print('Download completed: ${result.filePath}');
    } else {
      print('Error: ${result.error}');
    }
  });
}
```
*
* */