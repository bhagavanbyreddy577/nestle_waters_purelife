import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:nestle_waters_purelife/core/services/network/dio/dio_client_service.dart';
import 'package:nestle_waters_purelife/utils/exceptions/custom_failures.dart';

/// Network service implementation using Dio
class DioClientServiceImpl implements DioClientService {
  // Constants
  static const int _defaultConnectTimeout = 30000; // 30 seconds
  static const int _defaultReceiveTimeout = 30000; // 30 seconds
  static const int _defaultSendTimeout = 30000; // 30 seconds
  static const int _defaultRetryCount = 3;
  static const int _defaultRetryDelay = 1000; // 1 second

  // Dio instance
  final Dio _dio;

  // Retry configuration
  final int _maxRetries;
  final int _retryDelay;

  // Internal token storage
  String? _authToken;

  /// NetworkServiceImpl constructor
  ///
  /// [baseUrl] - Optional base URL for the API
  /// [headers] - Optional default headers
  /// [connectTimeout] - Connection timeout in milliseconds
  /// [receiveTimeout] - Receive timeout in milliseconds
  /// [sendTimeout] - Send timeout in milliseconds
  /// [retryCount] - Number of times to retry failed requests
  /// [retryDelay] - Delay between retries in milliseconds
  /// [interceptors] - Optional list of custom interceptors
  DioClientServiceImpl({
    String? baseUrl,
    Map<String, dynamic>? headers,
    int connectTimeout = _defaultConnectTimeout,
    int receiveTimeout = _defaultReceiveTimeout,
    int sendTimeout = _defaultSendTimeout,
    int retryCount = _defaultRetryCount,
    int retryDelay = _defaultRetryDelay,
    List<Interceptor>? interceptors,
  })  : _maxRetries = retryCount,
        _retryDelay = retryDelay,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? '',
            connectTimeout: Duration(milliseconds: connectTimeout),
            receiveTimeout: Duration(milliseconds: receiveTimeout),
            sendTimeout: Duration(milliseconds: sendTimeout),
            headers: headers ?? {},
            validateStatus: (status) {
              return status != null && status < 500;
            },
          ),
        ) {
    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }

    // Add retry interceptor
    _dio.interceptors.add(_createRetryInterceptor());

    // Add authentication interceptor
    _dio.interceptors.add(_createAuthInterceptor());

    // Add custom interceptors if provided
    if (interceptors != null && interceptors.isNotEmpty) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  /// Creates a retry interceptor to handle request retries
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (_shouldRetry(error)) {
          int retryCount = 0;

          while (retryCount < _maxRetries) {
            try {
              retryCount++;
              await Future.delayed(Duration(milliseconds: _retryDelay * retryCount));

              // Clone the original request
              final options = error.requestOptions;
              final response = await _dio.request<dynamic>(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                  responseType: options.responseType,
                  contentType: options.contentType,
                  validateStatus: options.validateStatus,
                  receiveTimeout: options.receiveTimeout,
                  sendTimeout: options.sendTimeout,
                ),
              );

              return handler.resolve(response);
            } on DioException catch (e) {
              if (retryCount >= _maxRetries) {
                return handler.next(e);
              }
            }
          }
        }

        return handler.next(error);
      },
    );
  }

  /// Creates an authentication interceptor to handle token management
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle token expiration (401 status)
          if (error.response?.statusCode == 401) {
            // TODO: Implement token refresh logic here if needed
            // This is a placeholder where you would typically refresh the token
            // and retry the request with the new token
          }
          return handler.next(error);
        }
    );
  }

  /// Determines if a request should be retried based on the error
  bool _shouldRetry(DioException error) {
    // Retry for network errors, timeout errors, and server errors (5xx)
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.badResponse && error.response?.statusCode != null && error.response!.statusCode! >= 500;
  }

  /// Set custom base URL for the service
  @override
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Set custom headers for the service
  @override
  void setHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Set auth token for authenticated requests
  @override
  void setToken(String token) {
    _authToken = token;
  }

  /// Clear auth token
  @override
  void clearToken() {
    _authToken = null;
  }

  /// Make a GET request to the specified endpoint
  @override
  Future<Either<Failure, T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      }) async {
    return _executeRequest<T>(
          () => _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
        ),
        cancelToken: cancelToken,
      ),
    );
  }

  /// Make a POST request to the specified endpoint
  @override
  Future<Either<Failure, T>> post<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      }) async {
    return _executeRequest<T>(
          () => _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
        ),
        cancelToken: cancelToken,
      ),
    );
  }

  /// Make a PUT request to the specified endpoint
  @override
  Future<Either<Failure, T>> put<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      }) async {
    return _executeRequest<T>(
          () => _dio.put<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
        ),
        cancelToken: cancelToken,
      ),
    );
  }

  /// Make a PATCH request to the specified endpoint
  @override
  Future<Either<Failure, T>> patch<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      }) async {
    return _executeRequest<T>(
          () => _dio.patch<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
        ),
        cancelToken: cancelToken,
      ),
    );
  }

  /// Make a DELETE request to the specified endpoint
  @override
  Future<Either<Failure, T>> delete<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      }) async {
    return _executeRequest<T>(
          () => _dio.delete<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
        ),
        cancelToken: cancelToken,
      ),
    );
  }

  /// Upload file(s) with progress tracking
  @override
  Future<Either<Failure, T>> uploadFile<T>(
      String endpoint, {
        required Map<String, File> files,
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
        Function(int sent, int total)? onSendProgress,
      }) async {
    try {
      // Create form data
      final formData = FormData();

      // Add regular data fields if any
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      // Add files
      await Future.forEach(files.entries, (entry) async {
        final fileName = entry.value.path.split('/').last;
        formData.files.add(
          MapEntry(
            entry.key,
            await MultipartFile.fromFile(
              entry.value.path,
              filename: fileName,
            ),
          ),
        );
      });

      // Execute POST request with form data
      final response = await _dio.post<T>(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      return Right(response.data as T);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Download file with progress tracking
  @override
  Future<Either<Failure, String>> downloadFile(
      String url,
      String savePath, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
        Function(int received, int total)? onReceiveProgress,
      }) async {
    try {
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: timeout,
        ),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return Right(savePath);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Create a new cancel token for request cancellation
  @override
  CancelToken createCancelToken() {
    return CancelToken();
  }

  /// Cancel a request using the cancel token
  @override
  void cancelRequest(CancelToken cancelToken) {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('Request cancelled by user');
    }
  }

  /// Helper method to execute a request and handle errors
  Future<Either<Failure, T>> _executeRequest<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();

      // Handle error responses (4xx)
      if (response.statusCode != null &&
          response.statusCode! >= 400 &&
          response.statusCode! < 500) {
        return Left(_handleErrorResponse(response));
      }

      return Right(response.data as T);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Handle error responses from the server
  Failure _handleErrorResponse<T>(Response<T> response) {
    switch (response.statusCode) {
      case 400:
        return ValidationFailure(
          message: 'Bad request',
          code: 400,
          data: response.data,
        );
      case 401:
        return AuthFailure(
          message: 'Unauthorized',
          code: 401,
          data: response.data,
        );
      case 403:
        return AuthFailure(
          message: 'Forbidden',
          code: 403,
          data: response.data,
        );
      case 404:
        return NotFoundFailure(
          message: 'Resource not found',
          code: 404,
          data: response.data,
        );
      case 429:
        return RateLimitFailure(
          message: 'Too many requests',
          code: 429,
          data: response.data,
        );
      default:
        return ServerFailure(
          message: 'Server error',
          code: response.statusCode ?? 0,
          data: response.data,
        );
    }
  }

  /// Handle errors and convert them to appropriate Failure types
  Failure _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          return CancelledFailure(
            message: 'Request cancelled',
            error: error,
          );
        case DioExceptionType.connectionTimeout:
          return TimeoutFailure(
            message: 'Connection timeout',
            error: error,
          );
        case DioExceptionType.receiveTimeout:
          return TimeoutFailure(
            message: 'Receive timeout',
            error: error,
          );
        case DioExceptionType.sendTimeout:
          return TimeoutFailure(
            message: 'Send timeout',
            error: error,
          );
        case DioExceptionType.badResponse:
        // Handle error responses
          if (error.response != null) {
            return _handleErrorResponse(error.response!);
          }
          return ServerFailure(
            message: 'Server error',
            error: error,
          );
        case DioExceptionType.connectionError:
          return NetworkFailure(
            message: 'No internet connection',
            error: error,
          );
        default:
          return UnknownFailure(
            message: 'Unknown error occurred',
            error: error,
          );
      }
    } else if (error is SocketException) {
      return NetworkFailure(
        message: 'No internet connection',
        error: error,
      );
    } else if (error is TimeoutException) {
      return TimeoutFailure(
        message: 'Operation timed out',
        error: error,
      );
    } else {
      return UnknownFailure(
        message: 'Unknown error occurred',
        error: error,
      );
    }
  }
}

/// TODO: Usage Example (Need to remove in production)
/*
*
*
* class ExampleRepositoryImpl implements ExampleRepository {
  // Get the NetworkService instance from service locator
  final NetworkService _networkService = getIt<NetworkService>();

  ExampleRepositoryImpl() {
    // You can configure network service for this specific repository
    // _networkService.setBaseUrl('https://api.yourspecificservice.com');
    // _networkService.setHeaders({'Custom-Header': 'Value'});
  }

  @override
  Future<Either<Failure, List<UserModel>>> getUsers() async {
    try {
      // Make a GET request to fetch users
      final result = await _networkService.get<Map<String, dynamic>>(
        '/users',
        queryParameters: {'limit': 10},
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          final List<dynamic> usersList = data['data'] as List<dynamic>;
          final users = usersList.map((json) => UserModel.fromJson(json)).toList();
          return Right(users);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get users'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserById(int id) async {
    // Make a GET request to fetch a specific user
    final result = await _networkService.get<Map<String, dynamic>>(
      '/users/$id',
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          final user = UserModel.fromJson(data['data']);
          return Right(user);
        } catch (e) {
          return Left(ServerFailure(message: 'Failed to parse user data'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, UserModel>> createUser(UserModel user) async {
    // Make a POST request to create a user
    final result = await _networkService.post<Map<String, dynamic>>(
      '/users',
      data: user.toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          final createdUser = UserModel.fromJson(data['data']);
          return Right(createdUser);
        } catch (e) {
          return Left(ServerFailure(message: 'Failed to parse user data'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, PostModel>> createPostWithImage(
    PostModel post,
    File image,
  ) async {
    // Create a cancel token for potential cancellation
    final cancelToken = _networkService.createCancelToken();

    // Upload file with the post data
    final result = await _networkService.uploadFile<Map<String, dynamic>>(
      '/posts',
      files: {'image': image},
      data: post.toJson(),
      cancelToken: cancelToken,
      onSendProgress: (sent, total) {
        // Here you can update UI with upload progress
        final progress = (sent / total) * 100;
        print('Upload progress: $progress%');
      },
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          final createdPost = PostModel.fromJson(data['data']);
          return Right(createdPost);
        } catch (e) {
          return Left(ServerFailure(message: 'Failed to parse post data'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, String>> downloadFile(String fileUrl) async {
    // Define where to save the file
    final savePath = '/path/to/downloads/file.pdf';

    // Download the file
    final result = await _networkService.downloadFile(
      fileUrl,
      savePath,
      onReceiveProgress: (received, total) {
        // Here you can update UI with download progress
        final progress = (received / total) * 100;
        print('Download progress: $progress%');
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, bool>> authenticateUser(String email, String password) async {
    try {
      // Login request
      final result = await _networkService.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return result.fold(
        (failure) => Left(failure),
        (data) {
          // Extract token from response
          final token = data['token'] as String?;

          if (token != null && token.isNotEmpty) {
            // Set token for subsequent requests
            _networkService.setToken(token);
            return const Right(true);
          } else {
            return Left(AuthFailure(message: 'Invalid credentials'));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Authentication failed'));
    }
  }

  @override
  void logout() {
    // Clear token on logout
    _networkService.clearToken();
  }
}
*
* */