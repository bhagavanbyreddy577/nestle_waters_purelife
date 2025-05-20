import 'dart:async';
import 'dart:isolate';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// A service class for handling Firebase Crashlytics functionality.
///
/// This class provides methods to initialize Crashlytics, record errors,
/// set user identifiers, log messages, and handle both caught and uncaught exceptions.
class FirebaseCrashlyticsService {

  // Singleton pattern implementation
  static final FirebaseCrashlyticsService _instance = FirebaseCrashlyticsService._internal();

  factory FirebaseCrashlyticsService() {
    return _instance;
  }

  FirebaseCrashlyticsService._internal();

  /// The Firebase Crashlytics instance
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initializes Firebase Crashlytics and sets up error handling.
  ///
  /// [enableInDevMode] - Whether to enable Crashlytics in debug/development mode
  /// [recordFlutterFatalErrors] - Whether to record Flutter fatal errors
  Future<void> initialize({
    bool enableInDevMode = false,
    bool recordFlutterFatalErrors = true,
  }) async {
    // Enable Crashlytics data collection
    await _crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode || enableInDevMode);

    // Pass all uncaught Flutter errors to Crashlytics
    if (recordFlutterFatalErrors) {
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics.recordFlutterFatalError(details);
      };
    }

    // Handle errors from the current Isolate
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await _crashlytics.recordError(
        errorAndStacktrace[0],
        errorAndStacktrace[1],
        fatal: true,
      );
    }).sendPort);

    // Handle asynchronous errors that aren't caught by the Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('Firebase Crashlytics initialized successfully');
  }

  /// Records a non-fatal error with an optional stack trace and error information.
  ///
  /// [exception] - The exception or error to be recorded
  /// [stack] - The associated stack trace (optional)
  /// [reason] - The reason for the error (optional)
  /// [information] - Additional error information (optional)
  /// [printLog] - Whether to print the error to console logs (optional)
  /// [fatal] - Whether the error is fatal (optional)
  Future<void> recordError(
      dynamic exception, {
        StackTrace? stack,
        String? reason,
        Map<String, dynamic>? information,
        bool printLog = true,
        bool fatal = false,
      }) async {
    if (printLog) {
      debugPrint('ERROR: $exception');
      if (stack != null) debugPrint('STACKTRACE: $stack');
      if (reason != null) debugPrint('REASON: $reason');
    }

    // Add custom keys for additional context
    if (information != null) {
      for (final entry in information.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value.toString());
      }
    }

    if (reason != null) {
      await _crashlytics.setCustomKey('reason', reason);
    }

    // Record the error to Crashlytics
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Sets a user identifier for better crash reporting.
  ///
  /// [identifier] - A unique identifier representing the user
  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  /// Logs a message that will be included in crash reports.
  ///
  /// [message] - The message to be logged
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// Sets custom keys that will be included in crash reports.
  ///
  /// [key] - The key for the custom data
  /// [value] - The value of the custom data
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Sets multiple custom keys at once.
  ///
  /// [customKeys] - Map of key-value pairs to be included in crash reports
  Future<void> setCustomKeys(Map<String, dynamic> customKeys) async {
    for (final entry in customKeys.entries) {
      await _crashlytics.setCustomKey(entry.key, entry.value.toString());
    }
  }

  /// Forces a crash for testing Crashlytics implementation.
  ///
  /// WARNING: Only use this method in development/testing environments!
  void forceCrash() {
    _crashlytics.crash();
  }

  /// Runs the given function in a try-catch block and records any errors to Crashlytics.
  ///
  /// [function] - The function to run and monitor for errors
  /// [fatal] - Whether any caught errors should be treated as fatal
  Future<T?> runCatching<T>(
      Future<T> Function() function, {
        bool fatal = false,
      }) async {
    try {
      return await function();
    } catch (e, stack) {
      await recordError(e, stack: stack, fatal: fatal);
      return null;
    }
  }
}


/// TODO: Usage example (Need to remove in production)
/*
*
* Initialize in your main.dart file
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'path/to/firebase_crashlytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Crashlytics
  await FirebaseCrashlyticsService().initialize(
    enableInDevMode: true,  // Set to false for production
    recordFlutterFatalErrors: true,
  );

  runApp(MyApp());
}
*
*
* Usage examples throughout your app
Recording a caught exception:
try {
  // Some code that might throw an error
  int result = 1 ~/ 0;  // Division by zero error
} catch (e, stack) {
  await FirebaseCrashlyticsService().recordError(
    e,
    stack: stack,
    reason: 'Division calculation error',
    information: {'calculation': '1/0'},
  );
}
*
* Setting user information:
// After user login
await FirebaseCrashlyticsService().setUserIdentifier('user123');
await FirebaseCrashlyticsService().setCustomKeys({
  'userPlan': 'premium',
  'userRegion': 'US',
});
*
* Using the helper method to wrap code:
Future<void> fetchData() async {
  await FirebaseCrashlyticsService().runCatching(() async {
    // Your code that might throw an error
    final response = await apiClient.getData();
    return response;
  });
}
*
*
* Logging information for crash context:
await FirebaseCrashlyticsService().log('User initiated payment flow');
*
* */