import 'dart:convert';
import 'package:flutter/foundation.dart';

/// A comprehensive JSON helper class that provides utility methods for
/// JSON encoding, decoding, validation, and file operations with proper
/// error handling and logging.
class NJsonHelper {

  /// Private constructor to prevent instantiation
  NJsonHelper._();

  /// Decodes a JSON string to a Map<String, dynamic>
  ///
  /// [jsonString] - The JSON string to decode
  /// [defaultValue] - Default value to return if decoding fails (optional)
  ///
  /// Returns the decoded Map or defaultValue if decoding fails
  /// Throws [JsonException] if decoding fails and no defaultValue is provided
  static Map<String, dynamic> decodeToMap(
      String jsonString, {
        Map<String, dynamic>? defaultValue,
      }) {
    try {
      if (jsonString.isEmpty) {
        throw const JsonException('JSON string is empty');
      }

      final decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        throw const JsonException('JSON does not represent a Map');
      }

      return decoded;
    } catch (e) {
      _logError('decodeToMap', e);

      if (defaultValue != null) {
        return defaultValue;
      }

      if (e is JsonException) {
        rethrow;
      }

      throw JsonException('Failed to decode JSON to Map: ${e.toString()}');
    }
  }

  /// Decodes a JSON string to a List<dynamic>
  ///
  /// [jsonString] - The JSON string to decode
  /// [defaultValue] - Default value to return if decoding fails (optional)
  ///
  /// Returns the decoded List or defaultValue if decoding fails
  /// Throws [JsonException] if decoding fails and no defaultValue is provided
  static List<dynamic> decodeToList(
      String jsonString, {
        List<dynamic>? defaultValue,
      }) {
    try {
      if (jsonString.isEmpty) {
        throw const JsonException('JSON string is empty');
      }

      final decoded = json.decode(jsonString);

      if (decoded is! List) {
        throw const JsonException('JSON does not represent a List');
      }

      return decoded;
    } catch (e) {
      _logError('decodeToList', e);

      if (defaultValue != null) {
        return defaultValue;
      }

      if (e is JsonException) {
        rethrow;
      }

      throw JsonException('Failed to decode JSON to List: ${e.toString()}');
    }
  }

  /// Decodes a JSON string to any dynamic type
  ///
  /// [jsonString] - The JSON string to decode
  /// [defaultValue] - Default value to return if decoding fails (optional)
  ///
  /// Returns the decoded object or defaultValue if decoding fails
  /// Throws [JsonException] if decoding fails and no defaultValue is provided
  static dynamic decode(
      String jsonString, {
        dynamic defaultValue,
      }) {
    try {
      if (jsonString.isEmpty) {
        throw const JsonException('JSON string is empty');
      }

      return json.decode(jsonString);
    } catch (e) {
      _logError('decode', e);

      if (defaultValue != null) {
        return defaultValue;
      }

      throw JsonException('Failed to decode JSON: ${e.toString()}');
    }
  }

  /// Encodes a Map to JSON string
  ///
  /// [map] - The Map to encode
  /// [prettyPrint] - Whether to format the JSON with indentation (default: false)
  ///
  /// Returns the JSON string representation
  /// Throws [JsonException] if encoding fails
  static String encodeMap(
      Map<String, dynamic> map, {
        bool prettyPrint = false,
      }) {
    try {
      if (prettyPrint) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(map);
      }
      return json.encode(map);
    } catch (e) {
      _logError('encodeMap', e);
      throw JsonException('Failed to encode Map to JSON: ${e.toString()}');
    }
  }

  /// Encodes a List to JSON string
  ///
  /// [list] - The List to encode
  /// [prettyPrint] - Whether to format the JSON with indentation (default: false)
  ///
  /// Returns the JSON string representation
  /// Throws [JsonException] if encoding fails
  static String encodeList(
      List<dynamic> list, {
        bool prettyPrint = false,
      }) {
    try {
      if (prettyPrint) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(list);
      }
      return json.encode(list);
    } catch (e) {
      _logError('encodeList', e);
      throw JsonException('Failed to encode List to JSON: ${e.toString()}');
    }
  }

  /// Encodes any object to JSON string
  ///
  /// [object] - The object to encode
  /// [prettyPrint] - Whether to format the JSON with indentation (default: false)
  ///
  /// Returns the JSON string representation
  /// Throws [JsonException] if encoding fails
  static String encode(
      dynamic object, {
        bool prettyPrint = false,
      }) {
    try {
      if (prettyPrint) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(object);
      }
      return json.encode(object);
    } catch (e) {
      _logError('encode', e);
      throw JsonException('Failed to encode object to JSON: ${e.toString()}');
    }
  }

  /// Validates if a string is valid JSON
  ///
  /// [jsonString] - The string to validate
  ///
  /// Returns true if valid JSON, false otherwise
  static bool isValidJson(String jsonString) {
    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Safely gets a value from a Map with type checking
  ///
  /// [map] - The Map to get value from
  /// [key] - The key to look for
  /// [defaultValue] - Default value if key doesn't exist or type mismatch
  ///
  /// Returns the value cast to type T or defaultValue
  static T? safeGet<T>(
      Map<String, dynamic> map,
      String key, {
        T? defaultValue,
      }) {
    try {
      if (!map.containsKey(key)) {
        return defaultValue;
      }

      final value = map[key];

      if (value is T) {
        return value;
      }

      // Try to convert common types
      if (T == String && value != null) {
        return value.toString() as T;
      }

      if (T == int && value is num) {
        return value.toInt() as T;
      }

      if (T == double && value is num) {
        return value.toDouble() as T;
      }

      return defaultValue;
    } catch (e) {
      _logError('safeGet', e);
      return defaultValue;
    }
  }

  /// Pretty prints JSON with proper indentation
  ///
  /// [jsonString] - JSON string to format
  /// [indent] - Indentation string (default: '  ')
  ///
  /// Returns formatted JSON string
  /// Throws [JsonException] if input is not valid JSON
  static String prettyPrint(String jsonString, {String indent = '  '}) {
    try {
      final object = json.decode(jsonString);
      final encoder = JsonEncoder.withIndent(indent);
      return encoder.convert(object);
    } catch (e) {
      _logError('prettyPrint', e);
      throw JsonException('Failed to pretty print JSON: ${e.toString()}');
    }
  }

  /// Logs errors in debug mode
  ///
  /// [method] - Method name where error occurred
  /// [error] - The error object
  static void _logError(String method, dynamic error) {
    if (kDebugMode) {
      print('JsonHelper.$method Error: $error');
    }
  }
}

/// Custom exception class for JSON operations
class JsonException implements Exception {
  /// Error message
  final String message;

  /// Creates a JsonException with the given message
  const JsonException(this.message);

  @override
  String toString() => 'JsonException: $message';
}

/// Extension methods for Map to add JSON functionality
extension JsonMapExtension on Map<String, dynamic> {
  /// Converts this Map to JSON string
  String toJsonString({bool prettyPrint = false}) {
    return NJsonHelper.encodeMap(this, prettyPrint: prettyPrint);
  }

  /// Safely gets a value with type checking
  T? safeGet<T>(String key, {T? defaultValue}) {
    return NJsonHelper.safeGet<T>(this, key, defaultValue: defaultValue);
  }
}

/// Extension methods for String to add JSON functionality
extension JsonStringExtension on String {
  /// Converts this JSON string to Map
  Map<String, dynamic> toMap({Map<String, dynamic>? defaultValue}) {
    return NJsonHelper.decodeToMap(this, defaultValue: defaultValue);
  }

  /// Converts this JSON string to List
  List<dynamic> toList({List<dynamic>? defaultValue}) {
    return NJsonHelper.decodeToList(this, defaultValue: defaultValue);
  }

  /// Checks if this string is valid JSON
  bool get isValidJson => NJsonHelper.isValidJson(this);

  /// Pretty prints this JSON string
  String prettyJson({String indent = '  '}) {
    return NJsonHelper.prettyPrint(this, indent: indent);
  }
}