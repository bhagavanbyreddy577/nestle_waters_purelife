import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

/// A service class for handling Firebase Remote Configuration functionality in Flutter.
///
/// This class provides methods to initialize Firebase Remote Config, fetch and activate configs,
/// access config values in different formats, and listen for config updates.
class FirebaseRemoteConfigService {
  // Singleton pattern implementation
  static final FirebaseRemoteConfigService _instance = FirebaseRemoteConfigService._internal();

  factory FirebaseRemoteConfigService() {
    return _instance;
  }

  FirebaseRemoteConfigService._internal();

  /// The Firebase RemoteConfig instance
  late final FirebaseRemoteConfig _remoteConfig;

  /// Stream controller for broadcasting config update events
  final _configUpdatedController = StreamController<void>.broadcast();

  /// Stream that emits an event whenever config values are updated
  Stream<void> get onConfigUpdated => _configUpdatedController.stream;

  /// Default values map that will be used if remote values aren't available
  Map<String, dynamic> _defaultValues = {};

  /// Cached values to avoid unnecessary accesses to Remote Config
  final Map<String, dynamic> _cachedValues = {};

  /// Flag indicating if the service has been initialized
  bool _isInitialized = false;

  /// Returns whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initializes the Firebase Remote Config service.
  ///
  /// [fetchTimeout] - The timeout for fetch operations in seconds
  /// [minimumFetchInterval] - Minimum interval between fetch operations in seconds
  /// [defaultValues] - Default configuration values to use if remote values aren't available
  /// [fetchImmediately] - Whether to fetch and activate config values immediately after initialization
  Future<void> initialize({
    int fetchTimeout = 60,
    int minimumFetchInterval = 3600,
    Map<String, dynamic>? defaultValues,
    bool fetchImmediately = true,
  }) async {
    if (_isInitialized) {
      debugPrint('FirebaseRemoteConfigService already initialized');
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values if provided
      if (defaultValues != null && defaultValues.isNotEmpty) {
        _defaultValues = Map.from(defaultValues);
        await _remoteConfig.setDefaults(_convertToStringMap(defaultValues));
      }

      // Configure remote config settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: fetchTimeout),
        minimumFetchInterval: Duration(seconds: minimumFetchInterval),
      ));

      // Fetch and activate config if requested
      if (fetchImmediately) {
        await fetchAndActivate();
      }

      _isInitialized = true;
      debugPrint('Firebase Remote Config initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firebase Remote Config: $e');
      rethrow;
    }
  }

  /// Fetches and activates remote configuration values.
  ///
  /// Returns true if new values were activated, false otherwise.
  Future<bool> fetchAndActivate() async {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return false;
    }

    try {
      // Fetch the latest config values
      await _remoteConfig.fetch();

      // Activate fetched values
      final bool activated = await _remoteConfig.activate();

      // Clear cached values to force reading new values
      if (activated) {
        _cachedValues.clear();
        _configUpdatedController.add(null);
        debugPrint('New remote config values activated');
      }

      return activated;
    } catch (e) {
      debugPrint('Error fetching or activating remote config: $e');
      return false;
    }
  }

  /// Gets the last fetch status of the Remote Config.
  RemoteConfigFetchStatus getLastFetchStatus() {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return RemoteConfigFetchStatus.noFetchYet;
    }

    return _remoteConfig.lastFetchStatus;
  }

  /// Gets the time of the last successful fetch.
  DateTime getLastFetchTime() {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return _remoteConfig.lastFetchTime;
  }

  /// Gets a config value as a String.
  ///
  /// [key] - The key for the configuration value
  /// [defaultValue] - Optional default value if key doesn't exist (overrides service defaults)
  String getString(String key, {String? defaultValue}) {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return defaultValue ?? _getDefaultValue(key) ?? '';
    }

    if (_cachedValues.containsKey(key)) {
      return _cachedValues[key] as String;
    }

    try {
      final value = _remoteConfig.getString(key);
      _cachedValues[key] = value;
      return value;
    } catch (e) {
      debugPrint('Error getting string config for key $key: $e');
      return defaultValue ?? _getDefaultValue(key) ?? '';
    }
  }

  /// Gets a config value as a bool.
  ///
  /// [key] - The key for the configuration value
  /// [defaultValue] - Optional default value if key doesn't exist (overrides service defaults)
  bool getBool(String key, {bool? defaultValue}) {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return defaultValue ?? _getDefaultValue(key) ?? false;
    }

    if (_cachedValues.containsKey(key)) {
      return _cachedValues[key] as bool;
    }

    try {
      final value = _remoteConfig.getBool(key);
      _cachedValues[key] = value;
      return value;
    } catch (e) {
      debugPrint('Error getting bool config for key $key: $e');
      return defaultValue ?? _getDefaultValue(key) ?? false;
    }
  }

  /// Gets a config value as an int.
  ///
  /// [key] - The key for the configuration value
  /// [defaultValue] - Optional default value if key doesn't exist (overrides service defaults)
  int getInt(String key, {int? defaultValue}) {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return defaultValue ?? _getDefaultValue(key) ?? 0;
    }

    if (_cachedValues.containsKey(key)) {
      return _cachedValues[key] as int;
    }

    try {
      final value = _remoteConfig.getInt(key);
      _cachedValues[key] = value;
      return value;
    } catch (e) {
      debugPrint('Error getting int config for key $key: $e');
      return defaultValue ?? _getDefaultValue(key) ?? 0;
    }
  }

  /// Gets a config value as a double.
  ///
  /// [key] - The key for the configuration value
  /// [defaultValue] - Optional default value if key doesn't exist (overrides service defaults)
  double getDouble(String key, {double? defaultValue}) {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return defaultValue ?? _getDefaultValue(key) ?? 0.0;
    }

    if (_cachedValues.containsKey(key)) {
      return _cachedValues[key] as double;
    }

    try {
      final value = _remoteConfig.getDouble(key);
      _cachedValues[key] = value;
      return value;
    } catch (e) {
      debugPrint('Error getting double config for key $key: $e');
      return defaultValue ?? _getDefaultValue(key) ?? 0.0;
    }
  }

  /// Gets a config value as a JSON object.
  ///
  /// [key] - The key for the configuration value
  /// [defaultValue] - Optional default value if key doesn't exist or parsing fails
  Map<String, dynamic>? getJson(String key, {Map<String, dynamic>? defaultValue}) {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return defaultValue ?? _getDefaultValue(key);
    }

    if (_cachedValues.containsKey(key)) {
      return _cachedValues[key] as Map<String, dynamic>;
    }

    try {
      final String jsonString = _remoteConfig.getString(key);
      if (jsonString.isEmpty) {
        return defaultValue ?? _getDefaultValue(key);
      }

      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cachedValues[key] = jsonMap;
      return jsonMap;
    } catch (e) {
      debugPrint('Error getting JSON config for key $key: $e');
      return defaultValue ?? _getDefaultValue(key);
    }
  }

  /// Gets a config value as a List.
  ///
  /// [key] - The key for the configuration value
  /// [defaultValue] - Optional default value if key doesn't exist or parsing fails
  List<dynamic>? getList(String key, {List<dynamic>? defaultValue}) {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return defaultValue ?? _getDefaultValue(key);
    }

    if (_cachedValues.containsKey(key)) {
      return _cachedValues[key] as List<dynamic>;
    }

    try {
      final String jsonString = _remoteConfig.getString(key);
      if (jsonString.isEmpty) {
        return defaultValue ?? _getDefaultValue(key);
      }

      final List<dynamic> list = json.decode(jsonString);
      _cachedValues[key] = list;
      return list;
    } catch (e) {
      debugPrint('Error getting List config for key $key: $e');
      return defaultValue ?? _getDefaultValue(key);
    }
  }

  /// Gets all configuration values as a Map.
  Map<String, dynamic> getAll() {
    if (!_isInitialized) {
      debugPrint('FirebaseRemoteConfigService not initialized yet. Call initialize() first.');
      return Map.from(_defaultValues);
    }

    final Map<String, dynamic> allValues = {};

    try {
      for (final entry in _remoteConfig.getAll().entries) {
        final value = entry.value.asString();

        // Try to parse as JSON first
        try {
          allValues[entry.key] = json.decode(value);
          continue;
        } catch (_) {
          // Not a JSON, continue with other types
        }

        // Try to parse as bool
        if (value.toLowerCase() == 'true') {
          allValues[entry.key] = true;
        } else if (value.toLowerCase() == 'false') {
          allValues[entry.key] = false;
        }
        // Try to parse as number
        else if (int.tryParse(value) != null) {
          allValues[entry.key] = int.parse(value);
        } else if (double.tryParse(value) != null) {
          allValues[entry.key] = double.parse(value);
        }
        // Keep as string
        else {
          allValues[entry.key] = value;
        }
      }

      return allValues;
    } catch (e) {
      debugPrint('Error getting all config values: $e');
      return Map.from(_defaultValues);
    }
  }

  /// Clears all cached values, forcing next access to read from remote config directly.
  void clearCache() {
    _cachedValues.clear();
    debugPrint('Remote config cache cleared');
  }

  /// Disposes of resources used by this service.
  void dispose() {
    _configUpdatedController.close();
  }

  /// Helper method to get a default value for a key.
  dynamic _getDefaultValue(String key) {
    return _defaultValues[key];
  }

  /// Converts a dynamic map to a map with string values for Remote Config.
  Map<String, String> _convertToStringMap(Map<String, dynamic> map) {
    final result = <String, String>{};

    for (final entry in map.entries) {
      if (entry.value is Map || entry.value is List) {
        result[entry.key] = json.encode(entry.value);
      } else {
        result[entry.key] = entry.value.toString();
      }
    }

    return result;
  }
}

// TODO: Usage example (Need to remove in production)
/*
*
* Initialize in your main.dart file
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'path/to/firebase_remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Remote Config with default values
  await FirebaseRemoteConfigService().initialize(
    fetchTimeout: 60, // 60 seconds timeout
    minimumFetchInterval: 3600, // 1 hour minimum fetch interval
    defaultValues: {
      'welcome_message': 'Welcome to our app!',
      'is_feature_enabled': false,
      'item_count': 10,
      'pricing': 9.99,
      'feature_list': json.encode(['feature1', 'feature2', 'feature3']),
      'app_config': json.encode({
        'theme': 'light',
        'version': '1.0.0',
        'cache_ttl': 3600,
      }),
    },
    fetchImmediately: true, // Fetch values immediately
  );

  runApp(MyApp());
}
*
*
Usage examples throughout your app
Basic usage:
// Get simple config values with type-specific getters
String welcomeMessage = FirebaseRemoteConfigService().getString('welcome_message');
bool isFeatureEnabled = FirebaseRemoteConfigService().getBool('is_feature_enabled');
int itemCount = FirebaseRemoteConfigService().getInt('item_count');
double pricing = FirebaseRemoteConfigService().getDouble('pricing');

// Display in UI
Text(welcomeMessage);
if (isFeatureEnabled) {
  // Show the feature
}

*
* Working with complex types:
// Get a JSON object
Map<String, dynamic>? appConfig = FirebaseRemoteConfigService().getJson('app_config');
if (appConfig != null) {
  String theme = appConfig['theme'] ?? 'light';
  String version = appConfig['version'] ?? '1.0.0';
  int cacheTtl = appConfig['cache_ttl'] ?? 3600;

  // Use these values in your app
}
// Get a list
List<dynamic>? features = FirebaseRemoteConfigService().getList('feature_list');
if (features != null) {
  for (String feature in features.cast<String>()) {
    print('Feature available: $feature');
  }
}

*
* Manually refreshing config values:
Future<void> refreshConfig() async {
  bool activated = await FirebaseRemoteConfigService().fetchAndActivate();
  if (activated) {
    print('New config values activated');
  } else {
    print('No new config values found');
  }
}
// Call when needed, e.g. on app resume or user action
ElevatedButton(
  onPressed: refreshConfig,
  child: Text('Refresh App Settings'),
)
*
*
Using the RemoteConfigBuilder widget for reactive UI:
// This widget will automatically rebuild when config values change
RemoteConfigBuilder(
  // Optional: specify which keys should trigger a rebuild
  keysToWatch: ['welcome_message', 'app_theme'],
  // Optional: show a loading widget while waiting for initial fetch
  loadingWidget: CircularProgressIndicator(),
  builder: (context) {
    String message = FirebaseRemoteConfigService().getString('welcome_message');
    String theme = FirebaseRemoteConfigService().getString('app_theme');

    return Column(
      children: [
        Text(message),
        Text('Current theme: $theme'),
      ],
    );
  },
)

*
*
* Listening for config changes programmatically:
class _MyComponentState extends State<MyComponent> {
  late StreamSubscription _configSubscription;

  @override
  void initState() {
    super.initState();

    // Listen for config updates
    _configSubscription = FirebaseRemoteConfigService().onConfigUpdated.listen((_) {
      // Config updated, refresh UI or take action
      setState(() {});
    });
  }

  @override
  void dispose() {
    _configSubscription.cancel();
    super.dispose();
  }

  // Rest of your component...
}
*
*
* */