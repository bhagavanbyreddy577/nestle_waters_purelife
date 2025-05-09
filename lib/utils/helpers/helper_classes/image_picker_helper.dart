import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result model for the image picker operations
class NImagePickerResult {

  /// The selected or captured image file
  final File? file;

  /// Error message if any
  final String? errorMessage;

  /// Whether the operation was successful
  bool get isSuccess => file != null && errorMessage == null;

  NImagePickerResult({this.file, this.errorMessage});

  /// Create a success result
  factory NImagePickerResult.success(File file) => NImagePickerResult(file: file);

  /// Create an error result
  factory NImagePickerResult.error(String message) =>
      NImagePickerResult(errorMessage: message);

  /// Create a cancelled result
  factory NImagePickerResult.cancelled() =>
      NImagePickerResult(errorMessage: 'Operation cancelled by user');
}

/// Helper class for image picking operations
class NImagePickerHelper {
  /// Singleton instance
  static final NImagePickerHelper _instance = NImagePickerHelper._internal();

  /// Image picker instance
  final ImagePicker _picker = ImagePicker();

  /// Factory constructor
  factory NImagePickerHelper() {
    return _instance;
  }

  /// Internal constructor
  NImagePickerHelper._internal();

  /// Default image quality (0-100)
  final int _defaultImageQuality = 80;

  /// Check and request camera permission
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> _checkAndRequestCameraPermission(BuildContext context) async {
    // Check camera permission
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();
      return status.isGranted;
    }

    // If permission is permanently denied, open app settings
    if (status.isPermanentlyDenied) {
      // Show dialog to direct user to app settings
      final bool shouldOpenSettings = await _showPermissionDialog(
        context,
        'Camera Permission Required',
        'Camera permission is required to take photos. Please enable it in app settings.',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }

    return false;
  }

  /// Check and request photos permission
  ///
  /// Returns true if permission is granted, false otherwise
  Future<bool> _checkAndRequestPhotosPermission(BuildContext context) async {
    // Check photos permission
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Request permission
      status = await Permission.photos.request();
      return status.isGranted;
    }

    // If permission is permanently denied, open app settings
    if (status.isPermanentlyDenied) {
      // Show dialog to direct user to app settings
      final bool shouldOpenSettings = await _showPermissionDialog(
        context,
        'Photos Permission Required',
        'Photos permission is required to select photos. Please enable it in app settings.',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }

    return false;
  }

  /// Shows a permission explanation dialog
  ///
  /// Returns true if user wants to open settings, false otherwise
  Future<bool> _showPermissionDialog(
      BuildContext context,
      String title,
      String message
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Capture image from camera
  ///
  /// [context] - BuildContext for showing dialogs
  /// [imageQuality] - Quality of the image (0-100), defaults to 80
  /// [maxWidth] - Maximum width of the image (optional)
  /// [maxHeight] - Maximum height of the image (optional)
  ///
  /// Returns an ImagePickerResult with the captured image or error details
  Future<NImagePickerResult> captureFromCamera({
    required BuildContext context,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      // Check for camera permission
      final hasPermission = await _checkAndRequestCameraPermission(context);
      if (!hasPermission) {
        return NImagePickerResult.error('Camera permission denied');
      }

      // Capture image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality ?? _defaultImageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      // Handle result
      if (pickedFile == null) {
        return NImagePickerResult.cancelled();
      }

      return NImagePickerResult.success(File(pickedFile.path));
    } catch (e) {
      return NImagePickerResult.error('Failed to capture image: $e');
    }
  }

  /// Pick image from gallery
  ///
  /// [context] - BuildContext for showing dialogs
  /// [imageQuality] - Quality of the image (0-100), defaults to 80
  /// [maxWidth] - Maximum width of the image (optional)
  /// [maxHeight] - Maximum height of the image (optional)
  ///
  /// Returns an ImagePickerResult with the selected image or error details
  Future<NImagePickerResult> pickFromGallery({
    required BuildContext context,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      // Check for photos permission
      final hasPermission = await _checkAndRequestPhotosPermission(context);
      if (!hasPermission) {
        return NImagePickerResult.error('Photos permission denied');
      }

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality ?? _defaultImageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      // Handle result
      if (pickedFile == null) {
        return NImagePickerResult.cancelled();
      }

      return NImagePickerResult.success(File(pickedFile.path));
    } catch (e) {
      return NImagePickerResult.error('Failed to pick image: $e');
    }
  }

  /// Show a dialog to let user choose between camera and gallery
  ///
  /// [context] - BuildContext for showing dialogs
  /// [imageQuality] - Quality of the image (0-100), defaults to 80
  /// [maxWidth] - Maximum width of the image (optional)
  /// [maxHeight] - Maximum height of the image (optional)
  ///
  /// Returns an ImagePickerResult with the selected/captured image or error details
  Future<NImagePickerResult> showImageSourceDialog({
    required BuildContext context,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final source = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return NImagePickerResult.cancelled();
    }

    if (source == 'camera') {
      return captureFromCamera(
        context: context,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    } else {
      return pickFromGallery(
        context: context,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    }
  }
}