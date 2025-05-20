import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:nestle_waters_purelife/utils/exceptions/custom_failures.dart';

/// NetworkService interface that defines all network operations
abstract class DioClientService {
  /// Set custom base URL for the service
  void setBaseUrl(String baseUrl);

  /// Set custom headers for the service
  void setHeaders(Map<String, dynamic> headers);

  /// Set auth token for authenticated requests
  void setToken(String token);

  /// Clear auth token
  void clearToken();

  /// Make a GET request to the specified endpoint
  Future<Either<Failure, T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      });

  /// Make a POST request to the specified endpoint
  Future<Either<Failure, T>> post<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      });

  /// Make a PUT request to the specified endpoint
  Future<Either<Failure, T>> put<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      });

  /// Make a PATCH request to the specified endpoint
  Future<Either<Failure, T>> patch<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      });

  /// Make a DELETE request to the specified endpoint
  Future<Either<Failure, T>> delete<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
      });

  /// Upload file(s) with progress
  Future<Either<Failure, T>> uploadFile<T>(
      String endpoint, {
        required Map<String, File> files,
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
        Function(int sent, int total)? onSendProgress,
      });

  /// Download file with progress
  Future<Either<Failure, String>> downloadFile(
      String url,
      String savePath, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
        Duration? timeout,
        Function(int received, int total)? onReceiveProgress,
      });

  /// Create a new cancel token for request cancellation
  CancelToken createCancelToken();

  /// Cancel a request using the cancel token
  void cancelRequest(CancelToken cancelToken);
}