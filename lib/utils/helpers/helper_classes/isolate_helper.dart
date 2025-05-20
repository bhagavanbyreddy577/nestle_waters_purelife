import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';

/// Message type for communication between isolates
class IsolateMessage {
  final String type; // 'http' or 'graphql'
  final Map<String, dynamic> data;

  IsolateMessage({required this.type, required this.data});

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
    };
  }

  factory IsolateMessage.fromMap(Map<String, dynamic> map) {
    return IsolateMessage(
      type: map['type'],
      data: Map<String, dynamic>.from(map['data']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory IsolateMessage.fromJson(String source) =>
      IsolateMessage.fromMap(jsonDecode(source));
}

/// Result returned from isolate operations
class IsolateResult<T> {
  final bool success;
  final T? data;
  final String? error;

  IsolateResult({
    required this.success,
    this.data,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }

  factory IsolateResult.fromMap(Map<String, dynamic> map) {
    return IsolateResult<T>(
      success: map['success'] as bool,
      data: map['data'] as T?,
      error: map['error'] as String?,
    );
  }

  @override
  String toString() =>
      'IsolateResult(success: $success, data: $data, error: $error)';
}

/// Main helper class for performing isolate operations
class NIsolateHelper {
  /// Performs HTTP operations in an isolate
  ///
  /// Example usage:
  /// ```dart
  /// final result = await IsolateHelper.performHttpRequest(
  ///   method: 'GET',
  ///   url: 'https://api.example.com/products',
  ///   headers: {'Authorization': 'Bearer token'},
  /// );
  ///
  /// if (result.success) {
  ///   final jsonData = jsonDecode(result.data);
  ///   // Process data
  /// } else {
  ///   print('Error: ${result.error}');
  /// }
  /// ```
  static Future<IsolateResult<String>> performHttpRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    try {
      final message = IsolateMessage(
        type: 'http',
        data: {
          'method': method,
          'url': url,
          'headers': headers,
          'body': body is String ? body : body?.toString(),
        },
      );

      final result = await compute(_isolateHttpHandler, message.toJson());
      final Map<String, dynamic> resultMap = jsonDecode(result);
      return IsolateResult<String>(
        success: resultMap['success'],
        data: resultMap['data'],
        error: resultMap['error'],
      );
    } catch (e) {
      return IsolateResult<String>(
        success: false,
        error: 'Isolate error: ${e.toString()}',
      );
    }
  }

  /// Performs GraphQL operations in an isolate
  ///
  /// Example usage:
  /// ```dart
  /// final result = await IsolateHelper.performGraphQLQuery(
  ///   url: 'https://api.example.com/graphql',
  ///   query: '''
  ///     query GetProducts {
  ///       products {
  ///         id
  ///         name
  ///         price
  ///       }
  ///     }
  ///   ''',
  ///   variables: {'limit': 10},
  ///   headers: {'Authorization': 'Bearer token'},
  /// );
  ///
  /// if (result.success) {
  ///   final data = result.data;
  ///   final products = data['products'];
  ///   // Process products
  /// } else {
  ///   print('Error: ${result.error}');
  /// }
  /// ```
  static Future<IsolateResult<Map<String, dynamic>>> performGraphQLQuery({
    required String url,
    required String query,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
  }) async {
    try {
      final message = IsolateMessage(
        type: 'graphql',
        data: {
          'url': url,
          'query': query,
          'variables': variables,
          'headers': headers,
        },
      );

      final result = await compute(_isolateGraphQLHandler, message.toJson());
      final Map<String, dynamic> resultMap = jsonDecode(result);
      return IsolateResult<Map<String, dynamic>>(
        success: resultMap['success'],
        data: resultMap['success'] ? Map<String, dynamic>.from(resultMap['data']) : null,
        error: resultMap['error'],
      );
    } catch (e) {
      return IsolateResult<Map<String, dynamic>>(
        success: false,
        error: 'Isolate error: ${e.toString()}',
      );
    }
  }

  /// Executes a custom task in an isolate
  ///
  /// Example usage:
  /// ```dart
  /// final result = await IsolateHelper.executeTask<List<Product>>(
  ///   task: (data) {
  ///     // Perform heavy computation
  ///     final List<dynamic> rawProducts = data['products'];
  ///     return rawProducts.map((p) => Product.fromJson(p)).toList();
  ///   },
  ///   data: {'products': jsonData},
  /// );
  ///
  /// if (result.success) {
  ///   final products = result.data;
  ///   // Use processed products
  /// } else {
  ///   print('Error: ${result.error}');
  /// }
  /// ```
  static Future<IsolateResult<T>> executeTask<T>({
    required FutureOr<T> Function(Map<String, dynamic> data) task,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Create isolate message for custom task
      final payload = _IsolateTaskPayload<T>(
        task: task,
        data: data,
      );

      final result = await compute(_isolateTaskHandler<T>, payload);
      return result;
    } catch (e) {
      return IsolateResult<T>(
        success: false,
        error: 'Isolate task error: ${e.toString()}',
      );
    }
  }
}

/// Handler for HTTP requests in isolate
Future<String> _isolateHttpHandler(String messageJson) async {
  try {
    final message = IsolateMessage.fromJson(messageJson);
    final data = message.data;
    final method = data['method'] as String;
    final url = data['url'] as String;
    final headers = data['headers'] != null
        ? Map<String, String>.from(data['headers'])
        : null;
    final body = data['body'];

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(Uri.parse(url), headers: headers);
        break;
      case 'POST':
        response = await http.post(Uri.parse(url), headers: headers, body: body);
        break;
      case 'PUT':
        response = await http.put(Uri.parse(url), headers: headers, body: body);
        break;
      case 'DELETE':
        response = await http.delete(Uri.parse(url), headers: headers);
        break;
      case 'PATCH':
        response = await http.patch(Uri.parse(url), headers: headers, body: body);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonEncode({
        'success': true,
        'data': response.body,
      });
    } else {
      return jsonEncode({
        'success': false,
        'error': 'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
      });
    }
  } catch (e) {
    return jsonEncode({
      'success': false,
      'error': e.toString(),
    });
  }
}

/// Handler for GraphQL operations in isolate
Future<String> _isolateGraphQLHandler(String messageJson) async {
  try {
    final message = IsolateMessage.fromJson(messageJson);
    final data = message.data;
    final url = data['url'] as String;
    final query = data['query'] as String;
    final variables = data['variables'] as Map<String, dynamic>?;
    final Map<String, String> emptyHeaders = {};
    final headers = data['headers'] != null
        ? Map<String, String>.from(data['headers'])
        : emptyHeaders;

    // Set up GraphQL client
    final HttpLink httpLink = HttpLink(url, defaultHeaders: headers);
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    // Execute the query
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      return jsonEncode({
        'success': false,
        'error': result.exception.toString(),
      });
    } else {
      return jsonEncode({
        'success': true,
        'data': result.data,
      });
    }
  } catch (e) {
    return jsonEncode({
      'success': false,
      'error': e.toString(),
    });
  }
}

/// Payload class for custom task execution
class _IsolateTaskPayload<T> {
  final FutureOr<T> Function(Map<String, dynamic> data) task;
  final Map<String, dynamic> data;

  _IsolateTaskPayload({required this.task, required this.data});
}

/// Handler for custom task execution in isolate
Future<IsolateResult<T>> _isolateTaskHandler<T>(_IsolateTaskPayload<T> payload) async {
  try {
    final result = await payload.task(payload.data);
    return IsolateResult<T>(
      success: true,
      data: result,
    );
  } catch (e) {
    return IsolateResult<T>(
      success: false,
      error: e.toString(),
    );
  }
}

/// Extension to convert IsolateResult to Map for serialization
extension IsolateResultExtension<T> on IsolateResult<T> {
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': data,
      'error': error,
    };
  }
}


/// TODO: Usage example (Need to remove in production)
/*
* The helper class I've created:

Performs heavy tasks in background threads using Flutter's isolate mechanism
Works with both HTTP and GraphQL operations
Handles all exceptions gracefully and provides clear error messages
Is reusable across your app with a simple API
Works on both Android and iOS platforms (isolates are supported on both)

Main Features

HTTP Operations: Easily perform GET, POST, PUT, DELETE, and PATCH requests in isolates
GraphQL Support: Execute GraphQL queries in isolates
Custom Task Execution: Run any heavy computation in isolates with your own functions
Error Handling: Comprehensive exception handling and reporting
Type Safety: Uses generics for proper type support

Usage Examples
HTTP Request Example
dart// Fetch product data
final result = await IsolateHelper.performHttpRequest(
  method: 'GET',
  url: 'https://api.example.com/products',
  headers: {'Authorization': 'Bearer $token'},
);

if (result.success) {
  final productData = jsonDecode(result.data!);
  // Process the product data
} else {
  print('Error fetching products: ${result.error}');
}
GraphQL Query Example
dart// Fetch products using GraphQL
final result = await IsolateHelper.performGraphQLQuery(
  url: 'https://api.example.com/graphql',
  query: '''
    query GetProducts {
      products {
        id
        name
        price
        imageUrl
      }
    }
  ''',
  headers: {'Authorization': 'Bearer $token'},
);

if (result.success) {
  final products = result.data!['products'];
  // Process the products
} else {
  print('GraphQL error: ${result.error}');
}
Custom Task Example
dart// Process image data in background
final result = await IsolateHelper.executeTask<List<ProcessedImage>>(
  task: (data) {
    // This runs in an isolate
    final rawImages = data['images'] as List;
    return rawImages.map((img) => processImage(img)).toList();
  },
  data: {'images': rawImageData},
);
*
* */