import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

/// A helper class for file operations using the dio package.
/// Handles file uploads and downloads with proper permission management
/// for both Android and iOS platforms.
class NFileOperationsHelper {
  /// The Dio instance for making HTTP requests
  final Dio _dio;

  /// Default constructor that initializes Dio with default options
  NFileOperationsHelper({Dio? dio}) : _dio = dio ?? Dio();

  /// Configures Dio with custom options
  void configureDio({
    BaseOptions? options,
    Map<String, dynamic>? headers,
    int? connectTimeout,
    int? receiveTimeout,
  }) {
    if (options != null) {
      _dio.options = options;
    }

    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }

    if (connectTimeout != null) {
      _dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
    }

    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
    }
  }

  /// Requests storage permission for reading files
  /// Returns true if permission is granted, false otherwise
  Future<bool> _requestReadPermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API level 33+), we need to use the granular permissions
      if (await Permission.storage.status != PermissionStatus.granted) {
        var status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      // iOS has a different permission model,
      // but we'll check photo library access for completeness
      if (await Permission.photos.status != PermissionStatus.granted) {
        var status = await Permission.photos.request();
        return status.isGranted;
      }
      return true;
    }
    return false;
  }

  /// Requests storage permission for writing files
  /// Returns true if permission is granted, false otherwise
  Future<bool> _requestWritePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API level 33+), we need to use the granular permissions
      if (await Permission.storage.status != PermissionStatus.granted) {
        var status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      // iOS has a different permission model for writing files
      return true; // iOS allows writing to app's documents directory by default
    }
    return false;
  }

  /// Uploads a file to the specified URL
  ///
  /// Parameters:
  /// - filePath: Path to the file to be uploaded
  /// - url: URL to upload the file to
  /// - method: HTTP method to use (default: POST)
  /// - field: Field name for the file in the multipart request (default: 'file')
  /// - fileName: Custom filename for the uploaded file (default: extracted from filePath)
  /// - data: Additional data to include in the request (default: empty)
  /// - onSendProgress: Callback for tracking upload progress
  ///
  /// Returns a Response object from Dio
  Future<Response> uploadFile({
    required String filePath,
    required String url,
    String method = 'POST',
    String field = 'file',
    String? fileName,
    Map<String, dynamic> data = const {},
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Request read permission
      bool hasPermission = await _requestReadPermission();
      if (!hasPermission) {
        throw Exception('Storage read permission denied');
      }

      // Check if file exists
      File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      // Create FormData
      FormData formData = FormData.fromMap({
        ...data,
        field: await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? path.basename(filePath),
        ),
      });

      // Make request based on method
      Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            url,
            data: formData,
            onSendProgress: onSendProgress,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            url,
            data: formData,
            onSendProgress: onSendProgress,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response;
    } catch (e) {
      if (e is DioException) {
        throw Exception('Upload failed: ${e.message}');
      }
      throw Exception('Upload failed: $e');
    }
  }

  /// Downloads a file from the specified URL
  ///
  /// Parameters:
  /// - url: URL to download the file from
  /// - savePath: Path where the file should be saved.
  ///   If null, saves to app's documents directory with filename from URL
  /// - overwrite: Whether to overwrite existing file (default: false)
  /// - onReceiveProgress: Callback for tracking download progress
  ///
  /// Returns the path where the file was saved
  Future<String> downloadFile({
    required String url,
    String? savePath,
    bool overwrite = false,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Request write permission
      bool hasPermission = await _requestWritePermission();
      if (!hasPermission) {
        throw Exception('Storage write permission denied');
      }

      // Determine where to save the file
      String finalSavePath;
      if (savePath != null) {
        finalSavePath = savePath;
      } else {
        // Extract filename from URL
        String fileName = path.basename(url);
        if (fileName.isEmpty || !fileName.contains('.')) {
          fileName = 'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
        }

        // Get app documents directory
        Directory appDocDir = await getApplicationDocumentsDirectory();
        finalSavePath = path.join(appDocDir.path, fileName);
      }

      // Check if file already exists
      File file = File(finalSavePath);
      if (await file.exists() && !overwrite) {
        throw Exception('File already exists: $finalSavePath');
      }

      // Ensure directory exists
      await Directory(path.dirname(finalSavePath)).create(recursive: true);

      // Download file
      await _dio.download(
        url,
        finalSavePath,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: true,
      );

      return finalSavePath;
    } catch (e) {
      if (e is DioException) {
        throw Exception('Download failed: ${e.message}');
      }
      throw Exception('Download failed: $e');
    }
  }
}


/// TODO: Usage Example (Need to remove in production)
/*
*
* class FileOperationsDemo extends StatefulWidget {
  const FileOperationsDemo({Key? key}) : super(key: key);

  @override
  State<FileOperationsDemo> createState() => _FileOperationsDemoState();
}

class _FileOperationsDemoState extends State<FileOperationsDemo> {
  // Initialize our helper class
  final FileOperationsHelper _fileHelper = FileOperationsHelper();

  // State variables
  bool _isUploading = false;
  bool _isDownloading = false;
  double _uploadProgress = 0.0;
  double _downloadProgress = 0.0;
  String _message = '';
  String? _downloadedFilePath;
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    // Configure Dio with custom settings if needed
    _fileHelper.configureDio(
      headers: {'Authorization': 'Bearer your-token-here'},
      connectTimeout: 30000, // 30 seconds
      receiveTimeout: 30000, // 30 seconds
    );
  }

  // Pick image from gallery to upload
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedFilePath = image.path;
          _message = 'File selected: ${image.name}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error picking image: $e';
      });
    }
  }

  // Upload the selected file
  Future<void> _uploadFile() async {
    if (_selectedFilePath == null) {
      setState(() {
        _message = 'Please select a file first';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _message = 'Starting upload...';
    });

    try {
      // Example upload URL - replace with your actual API endpoint
      final response = await _fileHelper.uploadFile(
        filePath: _selectedFilePath!,
        url: 'https://your-api-endpoint.com/upload',
        field: 'image', // Field name expected by your server
        data: {
          // Additional data to send with the file
          'description': 'Image uploaded from Flutter app',
          'userId': '123456',
        },
        onSendProgress: (int sent, int total) {
          setState(() {
            _uploadProgress = sent / total;
            _message = 'Uploading: ${(_uploadProgress * 100).toStringAsFixed(2)}%';
          });
        },
      );

      setState(() {
        _message = 'Upload successful! Server response: ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _message = 'Upload error: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Download a file from URL
  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _message = 'Starting download...';
    });

    try {
      // Example download URL - replace with your actual file URL
      final downloadUrl = 'https://example.com/sample-file.pdf';

      final filePath = await _fileHelper.downloadFile(
        url: downloadUrl,
        // You can specify a custom save path or let it use the default
        // savePath: '/custom/path/filename.pdf',
        overwrite: true,
        onReceiveProgress: (int received, int total) {
          setState(() {
            _downloadProgress = received / total;
            _message = 'Downloading: ${(_downloadProgress * 100).toStringAsFixed(2)}%';
          });
        },
      );

      setState(() {
        _downloadedFilePath = filePath;
        _message = 'Download successful! File saved at: $filePath';
      });
    } catch (e) {
      setState(() {
        _message = 'Download error: $e';
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  // Open the downloaded file
  Future<void> _openDownloadedFile() async {
    if (_downloadedFilePath == null) {
      setState(() {
        _message = 'No file has been downloaded yet';
      });
      return;
    }

    setState(() {
      _message = 'Opening file: $_downloadedFilePath';
    });

    // In a real app, you would use a package like open_file, url_launcher,
    // or flutter_pdfview to open the file based on its type
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Operations Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select File'),
            ),
            const SizedBox(height: 16),
            if (_selectedFilePath != null) ...[
              Text('Selected file: ${_selectedFilePath!.split('/').last}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadFile,
                child: const Text('Upload File'),
              ),
              if (_isUploading) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _uploadProgress),
              ],
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isDownloading ? null : _downloadFile,
              child: const Text('Download Sample File'),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _downloadProgress),
            ],
            if (_downloadedFilePath != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openDownloadedFile,
                child: const Text('Open Downloaded File'),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Status:'),
            Text(_message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
*
* *********************************************************************************
*
*
*
* Android Native Configuration
For Android, you need to configure the manifest file to request the appropriate permissions:
Android Manifest Changes
Add these permissions to your android/app/src/main/AndroidManifest.xml file:
xml<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet permission - Required for upload/download -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- Storage permissions - For devices running Android 12 (API level 32) or lower -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <!-- For Android 13+ (API level 33+), add these granular media permissions -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- For Android 10+ (API level 29+), add this to manage all files -->
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
                     tools:ignore="ScopedStorage" />

    <!-- ... rest of your manifest ... -->
</manifest>
Android 10+ (API 29+) Special Handling
For Android 10 and above, Google introduced scoped storage. If you need to access files outside your app's directory, you'll need additional configuration:

Add the requestLegacyExternalStorage flag to your manifest's application tag (for Android 10 compatibility):

xml<application
    android:requestLegacyExternalStorage="true"
    ... >

For Android 11+ (API 30+), to access all files, you'll need to:

Implement a special flow to direct users to Settings to enable "Manage All Files"
The permission_handler package can help with this using Permission.manageExternalStorage.request()



iOS Native Configuration
For iOS, you need to add usage descriptions in the Info.plist file:
Info.plist Changes
Update your ios/Runner/Info.plist file to include:
xml<plist version="1.0">
<dict>
    <!-- Photo Library access - For uploading images -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to your photo library to upload images.</string>

    <!-- Photo Library Add Usage - For saving images -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>This app needs permission to save images to your photo library.</string>

    <!-- Documents folder access - For downloading files -->
    <key>NSDocumentsFolderUsageDescription</key>
    <string>This app needs access to your documents folder to save downloaded files.</string>

    <!-- If you need to access the camera for photos to upload -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs access to your camera to take photos for upload.</string>

    <!-- ... other configurations ... -->
</dict>
</plist>
iOS File Sharing Configuration
If you want downloaded files to be visible in the Files app and iTunes file sharing:
Add to your Info.plist:
xml<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
Additional Native Configuration Notes
Android R Java File Fix (if needed)
Sometimes after adding permissions, the R.java file might not regenerate properly. If you encounter build errors:

Clean the project: flutter clean
Delete the build folder: rm -rf build/
Rebuild: flutter pub get and flutter run

Android Network Security Configuration
For Android 9+ (API 28+), to allow HTTP connections (not just HTTPS), add a network security configuration:

Create file android/app/src/main/res/xml/network_security_config.xml:

xml<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>

Reference it in your manifest:

xml<application
    android:networkSecurityConfig="@xml/network_security_config"
    ... >
iOS App Transport Security
For HTTP connections on iOS:
xml<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
Permission Flow Implementation Notes
When using the FileOperationsHelper class:

The class handles requesting permissions at runtime using the permission_handler package
For optimal user experience, explain why you need permissions before requesting them
For Android's "Manage All Files" permission, provide clear instructions to users on how to enable it if needed
*
*
* */