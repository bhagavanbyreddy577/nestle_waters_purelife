import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class NFileUploader {
  /// Upload single file to server
  ///
  /// Parameters:
  /// - [url]: The endpoint URL for the file upload
  /// - [filePath]: Local path to the file to be uploaded
  /// - [fieldName]: The form field name for the file (default: 'file')
  /// - [headers]: Optional HTTP headers
  /// - [params]: Additional form fields to include in the request
  /// - [onProgress]: Optional callback for upload progress updates
  /// - [timeout]: Request timeout duration
  static Future<UploadResponse> uploadFile({
    required String url,
    required String filePath,
    String fieldName = 'file',
    Map<String, String>? headers,
    Map<String, String>? params,
    Function(double progress)? onProgress,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    try {
      // Validate file exists
      final file = File(filePath);
      if (!await file.exists()) {
        return UploadResponse.failure('File not found: $filePath');
      }

      // Get file information
      final fileName = path.basename(filePath);
      final fileSize = await file.length();
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add timeout
      request.headers['connection'] = 'keep-alive';

      // Add headers if provided
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add additional parameters if provided
      if (params != null) {
        request.fields.addAll(params);
      }

      // Create file stream
      final fileStream = http.ByteStream(file.openRead());

      // Create multipart file
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileSize,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );

      // Add file to request
      request.files.add(multipartFile);

      // Track progress if callback provided
      final completer = Completer<http.StreamedResponse>();
      int bytesSent = 0;

      // Send the request
      final futureResponse = request.send().then((response) {
        if (!completer.isCompleted) {
          completer.complete(response);
        }
        return response;
      }).catchError((error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });

      // Handle progress reporting
      if (onProgress != null) {
        request.finalize().listen(
              (bytes) {
            bytesSent += bytes.length;
            final progress = bytesSent / fileSize;
            onProgress(progress);
          },
          onDone: () {},
          onError: (e) {},
          cancelOnError: true,
        );
      }

      // Wait for response with timeout
      final response = await completer.future.timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      // Process response
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        dynamic responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          responseData = responseBody;
        }

        return UploadResponse.success(
          responseData,
          statusCode: response.statusCode,
        );
      } else {
        // Error response
        return UploadResponse.failure(
          'Server error: ${response.statusCode}',
          data: responseBody,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return UploadResponse.failure('Request timed out');
    } on SocketException catch (e) {
      return UploadResponse.failure('Network error: ${e.message}');
    } on FormatException catch (e) {
      return UploadResponse.failure('Format error: ${e.message}');
    } catch (e) {
      return UploadResponse.failure('Upload failed: $e');
    }
  }

  /// Upload multiple files to server
  ///
  /// Parameters:
  /// - [url]: The endpoint URL for the file upload
  /// - [filePaths]: List of local paths to the files to be uploaded
  /// - [fieldName]: The form field name for the files (default: 'files')
  /// - [headers]: Optional HTTP headers
  /// - [params]: Additional form fields to include in the request
  /// - [onProgress]: Optional callback for overall upload progress updates
  /// - [onFileProgress]: Optional callback for individual file progress updates
  /// - [timeout]: Request timeout duration
  static Future<UploadResponse> uploadMultipleFiles({
    required String url,
    required List<String> filePaths,
    String fieldName = 'files',
    Map<String, String>? headers,
    Map<String, String>? params,
    Function(double overallProgress)? onProgress,
    Function(String filePath, double progress)? onFileProgress,
    Duration timeout = const Duration(minutes: 15),
  }) async {
    try {
      if (filePaths.isEmpty) {
        return UploadResponse.failure('No files to upload');
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add timeout
      request.headers['connection'] = 'keep-alive';

      // Add headers if provided
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add additional parameters if provided
      if (params != null) {
        request.fields.addAll(params);
      }

      // Calculate total size for progress reporting
      int totalSize = 0;
      List<File> files = [];

      for (final filePath in filePaths) {
        final file = File(filePath);
        if (await file.exists()) {
          files.add(file);
          totalSize += await file.length();
        } else {
          return UploadResponse.failure('File not found: $filePath');
        }
      }

      // Add each file to the request
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final filePath = filePaths[i];
        final fileName = path.basename(filePath);
        final fileSize = await file.length();
        final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

        final fileStream = http.ByteStream(file.openRead());

        // Use fieldName[i] format for multiple files with same field name
        final fieldNameWithIndex = '$fieldName[$i]';

        final multipartFile = http.MultipartFile(
          fieldNameWithIndex,
          fileStream,
          fileSize,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
      }

      // Send the request
      final response = await request.send().timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      // Process response
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        dynamic responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          responseData = responseBody;
        }

        return UploadResponse.success(
          responseData,
          statusCode: response.statusCode,
        );
      } else {
        // Error response
        return UploadResponse.failure(
          'Server error: ${response.statusCode}',
          data: responseBody,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return UploadResponse.failure('Request timed out');
    } on SocketException catch (e) {
      return UploadResponse.failure('Network error: ${e.message}');
    } on FormatException catch (e) {
      return UploadResponse.failure('Format error: ${e.message}');
    } catch (e) {
      return UploadResponse.failure('Upload failed: $e');
    }
  }

  /// Upload file with cancellation support
  ///
  /// Parameters:
  /// - [url]: The endpoint URL for the file upload
  /// - [filePath]: Local path to the file to be uploaded
  /// - [fieldName]: The form field name for the file (default: 'file')
  /// - [headers]: Optional HTTP headers
  /// - [params]: Additional form fields to include in the request
  /// - [onProgress]: Optional callback for upload progress updates
  /// - [cancelToken]: Token used to cancel the upload
  /// - [timeout]: Request timeout duration
  static Future<UploadResponse> uploadFileWithCancellation({
    required String url,
    required String filePath,
    required CancelToken cancelToken,
    String fieldName = 'file',
    Map<String, String>? headers,
    Map<String, String>? params,
    Function(double progress)? onProgress,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    HttpClient? client;

    try {
      // Validate file exists
      final file = File(filePath);
      if (!await file.exists()) {
        return UploadResponse.failure('File not found: $filePath');
      }

      // Register cancel callback
      cancelToken.onCancel = () {
        if (client != null) {
          client.close(force: true);
        }
      };

      // Check if already canceled
      if (cancelToken.isCanceled) {
        return UploadResponse.failure('Upload canceled');
      }

      // Create HttpClient for more control
      client = HttpClient();
      client.connectionTimeout = timeout;

      // Start request
      final request = await client.postUrl(Uri.parse(url));

      // Add headers
      request.headers.set('connection', 'keep-alive');
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      // Generate a boundary for multipart form data
      final boundary = '---------------------------${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set('content-type', 'multipart/form-data; boundary=$boundary');

      // Get file information
      final fileName = path.basename(filePath);
      final fileSize = await file.length();
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

      // Open output stream
      final requestStream = request.add;

      // Write multipart form data boundary start
      void writeString(String s) {
        requestStream(utf8.encode(s));
      }

      // Add form fields if provided
      if (params != null) {
        params.forEach((key, value) {
          writeString('--$boundary\r\n');
          writeString('Content-Disposition: form-data; name="$key"\r\n\r\n');
          writeString('$value\r\n');
        });
      }

      // Add file header
      writeString('--$boundary\r\n');
      writeString('Content-Disposition: form-data; name="$fieldName"; filename="$fileName"\r\n');
      writeString('Content-Type: $mimeType\r\n\r\n');

      // Read file in chunks and write to request
      final fileStream = file.openRead();
      int bytesSent = 0;

      await for (var chunk in fileStream) {
        // Check for cancellation
        if (cancelToken.isCanceled) {
          client.close(force: true);
          return UploadResponse.failure('Upload canceled');
        }

        requestStream(chunk);
        bytesSent += chunk.length;

        if (onProgress != null) {
          final progress = bytesSent / fileSize;
          onProgress(progress);
        }
      }

      // Add multipart form data boundary end
      writeString('\r\n--$boundary--\r\n');

      // Get response
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // Close client
      client.close();
      client = null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        dynamic responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          responseData = responseBody;
        }

        return UploadResponse.success(
          responseData,
          statusCode: response.statusCode,
        );
      } else {
        // Error response
        return UploadResponse.failure(
          'Server error: ${response.statusCode}',
          data: responseBody,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      client?.close(force: true);
      return UploadResponse.failure('Request timed out');
    } on SocketException catch (e) {
      client?.close(force: true);
      return UploadResponse.failure('Network error: ${e.message}');
    } on FormatException catch (e) {
      client?.close(force: true);
      return UploadResponse.failure('Format error: ${e.message}');
    } catch (e) {
      client?.close(force: true);
      return UploadResponse.failure('Upload failed: $e');
    }
  }

  /// Upload data from memory (e.g., from camera or other source)
  ///
  /// Parameters:
  /// - [url]: The endpoint URL for the upload
  /// - [data]: The bytes to upload
  /// - [fileName]: Name for the file
  /// - [mimeType]: MIME type of the content
  /// - [fieldName]: The form field name (default: 'file')
  /// - [headers]: Optional HTTP headers
  /// - [params]: Additional form fields to include in the request
  /// - [onProgress]: Optional callback for upload progress updates
  /// - [timeout]: Request timeout duration
  static Future<UploadResponse> uploadBytes({
    required String url,
    required Uint8List data,
    required String fileName,
    required String mimeType,
    String fieldName = 'file',
    Map<String, String>? headers,
    Map<String, String>? params,
    Function(double progress)? onProgress,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add timeout
      request.headers['connection'] = 'keep-alive';

      // Add headers if provided
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add additional parameters if provided
      if (params != null) {
        request.fields.addAll(params);
      }

      // Create multipart file from bytes
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        data,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );

      // Add file to request
      request.files.add(multipartFile);

      // Send the request
      final response = await request.send().timeout(timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      // Process response
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        dynamic responseData;
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          responseData = responseBody;
        }

        return UploadResponse.success(
          responseData,
          statusCode: response.statusCode,
        );
      } else {
        // Error response
        return UploadResponse.failure(
          'Server error: ${response.statusCode}',
          data: responseBody,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return UploadResponse.failure('Request timed out');
    } on SocketException catch (e) {
      return UploadResponse.failure('Network error: ${e.message}');
    } on FormatException catch (e) {
      return UploadResponse.failure('Format error: ${e.message}');
    } catch (e) {
      return UploadResponse.failure('Upload failed: $e');
    }
  }
}

/// Token to allow cancellation of uploads
class CancelToken {
  bool _isCanceled = false;
  Function? onCancel;

  bool get isCanceled => _isCanceled;

  void cancel() {
    _isCanceled = true;
    if (onCancel != null) {
      onCancel!();
    }
  }
}

/// Exception class for file upload errors
class FileUploadException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  FileUploadException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'FileUploadException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

/// Status of a file upload
enum UploadStatus {
  notStarted,
  uploading,
  success,
  failed,
  canceled
}

/// Response from a file upload
class UploadResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int? statusCode;

  UploadResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory UploadResponse.success(dynamic data, {int? statusCode}) {
    return UploadResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory UploadResponse.failure(String message, {dynamic data, int? statusCode}) {
    return UploadResponse(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }
}



/// TODO: Usage example(Need to remove in production)
///
/// // Single file upload with progress tracking
/// void uploadSingleFile() async {
///   final response = await FileUploader.uploadFile(
///     url: 'https://example.com/upload',
///     filePath: '/path/to/file.jpg',
///     headers: {'Authorization': 'Bearer token'},
///     params: {'userId': '123'},
///     onProgress: (progress) {
///       print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
///     },
///   );
///
///   if (response.success) {
///     print('Upload successful: ${response.data}');
///   } else {
///     print('Upload failed: ${response.message}');
///   }
/// }
///
/// // Upload with cancellation
/// void uploadWithCancellation() async {
///   final cancelToken = CancelToken();
///
///   // Start upload
///   final future = FileUploader.uploadFileWithCancellation(
///     url: 'https://example.com/upload',
///     filePath: '/path/to/large_file.mp4',
///     cancelToken: cancelToken,
///     onProgress: (progress) {
///       print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
///     },
///   );
///
///   // Cancel after 5 seconds
///   Future.delayed(Duration(seconds: 5), () {
///     print('Cancelling upload...');
///     cancelToken.cancel();
///   });
///
///   final response = await future;
///   print('Result: ${response.success ? 'Success' : 'Failed: ${response.message}'}');
/// }
/// ```