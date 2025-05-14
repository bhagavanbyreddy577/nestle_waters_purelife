import 'dart:async';
import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:flutter/foundation.dart';

/// A service class to handle all analytics events using the Adjust SDK.
///
/// This class provides methods to initialize the Adjust SDK, track events,
/// and handle attribution changes.
class AnalyticsService {
  /// Singleton instance of AnalyticsService
  static final AnalyticsService _instance = AnalyticsService._internal();

  /// Factory constructor to return the singleton instance
  factory AnalyticsService() => _instance;

  /// Private constructor for singleton pattern
  AnalyticsService._internal();

  /// Flag to check if the service is initialized
  bool _isInitialized = false;

  /// Environment mode for the Adjust SDK (sandbox or production)
  late final AdjustEnvironment _environment;

  /// Initialize the Adjust SDK with the given configuration.
  ///
  /// [appToken] The app token from the Adjust dashboard
  /// [environment] The environment to use (sandbox or production)
  /// [logLevel] The log level for debugging purposes
  /// [isAttributionCallback] Whether to listen for attribution changes
  Future<void> initialize({
    required String appToken,
    AdjustEnvironment environment = AdjustEnvironment.sandbox,
    AdjustLogLevel logLevel = AdjustLogLevel.verbose,
    bool isAttributionCallback = false,
  }) async {
    if (_isInitialized) {
      debugPrint('AnalyticsService already initialized');
      return;
    }

    _environment = environment;

    // Create Adjust config
    final AdjustConfig config = AdjustConfig(
      appToken,
      environment,
    );

    // Set log level for debugging
    config.logLevel = logLevel;

    // Configure attribution callback if needed
    if (isAttributionCallback) {
      config.attributionCallback = _attributionChangedCallback;
    }

    // Initialize Adjust SDK
    Adjust.initSdk(config);
    _isInitialized = true;
    debugPrint('AnalyticsService initialized successfully with environment: $environment');
  }

  /// Track an event with the given event token.
  ///
  /// [eventToken] The event token from the Adjust dashboard
  /// [parameters] Additional parameters to send with the event (optional)
  /// [revenue] Revenue information (optional)
  /// [currency] Currency code for revenue (optional)
  Future<void> trackEvent({
    required String eventToken,
    Map<String, String>? parameters,
    double? revenue,
    String? currency,
  }) async {
    _checkInitialization();

    final AdjustEvent event = AdjustEvent(eventToken);

    // Add custom parameters if provided
    if (parameters != null && parameters.isNotEmpty) {
      parameters.forEach((key, value) {
        event.addCallbackParameter(key, value);
      });
    }

    // Add revenue data if provided
    if (revenue != null && currency != null) {
      event.setRevenue(revenue, currency);
    }

    // Track the event
    Adjust.trackEvent(event);
    debugPrint('Event tracked with token: $eventToken');
  }

  /// Enable or disable the SDK temporarily.
  ///
  /// [enabled] Whether to enable the SDK
  void setEnabled(bool enabled) {
    _checkInitialization();
    Adjust.enable();
    debugPrint('Adjust SDK ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Check if the SDK is currently enabled.
  ///
  /// Returns a Future that completes with a boolean value indicating if the SDK is enabled.
  Future<bool> isEnabled() async {
    _checkInitialization();
    return await Adjust.isEnabled() ?? false;
  }

  /// Get current attribution data.
  ///
  /// Returns a Future that completes with the current attribution data.
  Future<AdjustAttribution?> getAttribution() async {
    _checkInitialization();
    return await Adjust.getAttribution();
  }

  /// Get the Adjust ID (device identifier).
  ///
  /// Returns a Future that completes with the Adjust ID.
  Future<String?> getAdjustId() async {
    _checkInitialization();
    return await Adjust.getAdid();
  }

  /// Get the Google Advertising ID (Android) or IDFA (iOS).
  ///
  /// Returns a Future that completes with the advertising ID.
  Future<String?> getAdvertisingId() async {
    _checkInitialization();
    if (Platform.isAndroid) {
      return await Adjust.getGoogleAdId();
    } else if (Platform.isIOS) {
      return await Adjust.getIdfa();
    }
    return null;
  }

  /// Set a user's push token for integrations requiring it.
  ///
  /// [token] The push notification token
  void setPushToken(String token) {
    _checkInitialization();
    Adjust.setPushToken(token);
    debugPrint('Push token set: $token');
  }

  /// Add a session callback parameter that will be sent with every session.
  ///
  /// [key] The parameter key
  /// [value] The parameter value
  void addSessionParameter(String key, String value) {
    _checkInitialization();
    Adjust.addGlobalCallbackParameter(key, value);
    debugPrint('Session parameter added: $key=$value');
  }

  /// Remove a specific session callback parameter.
  ///
  /// [key] The parameter key to remove
  void removeSessionParameter(String key) {
    _checkInitialization();
    Adjust.removeGlobalCallbackParameter(key);
    debugPrint('Session parameter removed: $key');
  }

  /*/// Reset all session callback parameters.
  void resetSessionParameters() {
    _checkInitialization();
    Adjust.resetSessionCallbackParameters();
    debugPrint('Session parameters reset');
  }*/

  /// Handle attribution changes from the Adjust SDK.
  ///
  /// This is called by the SDK when the attribution changes.
  void _attributionChangedCallback(AdjustAttribution attribution) {
    debugPrint('Attribution changed: ${attribution.toString()}');
    // Implement your attribution change logic here
    // For example, you might want to update user properties or trigger other events
  }

  /// Check if the service is initialized and throw an exception if not.
  void _checkInitialization() {
    if (!_isInitialized) {
      throw StateError('AnalyticsService must be initialized before use. Call initialize() first.');
    }
  }

  /// Get the current environment mode.
  AdjustEnvironment get environment => _environment;
}


/// TODO: Installation and Usage example (Need to remove in production)
/*
*
* # How to Configure Adjust SDK in Your Flutter Project

## Installation

1. Add the Adjust SDK to your `pubspec.yaml`:

```yaml
dependencies:
  adjust_sdk: ^4.33.0  # Use latest version available
```

2. Run `flutter pub get` to install the dependency.

## Native Platform Configuration

### Android Configuration

1. **AndroidManifest.xml** - Add permissions:

Open `android/app/src/main/AndroidManifest.xml` and add the following permissions inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

2. **Proguard rules** (if you're using ProGuard):

Create or modify `android/app/proguard-rules.pro` and add:

```
-keep class com.adjust.sdk.** { *; }
-keep class com.google.android.gms.common.ConnectionResult {
    int SUCCESS;
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient {
    com.google.android.gms.ads.identifier.AdvertisingIdClient$Info getAdvertisingIdInfo(android.content.Context);
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info {
    java.lang.String getId();
    boolean isLimitAdTrackingEnabled();
}
```

3. **Update build.gradle** (optional if needed for Play Install Referrer):

Open `android/app/build.gradle` and ensure you have:

```gradle
dependencies {
    // ... other dependencies
    implementation 'com.android.installreferrer:installreferrer:2.2'
}
```

### iOS Configuration

1. **Add required frameworks**:

Open your `ios/Podfile` and add the following at the end:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      # Flutter.framework does not contain a i386 slice.
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'i386 arm64'
    end
  end
end
```

2. **Update Info.plist**:

Open `ios/Runner/Info.plist` and add:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

3. **Enable SKAdNetwork** (for iOS 14+ attribution):

Add the following inside your `Info.plist` file within the `<dict>` tag:

```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Add any other required network IDs -->
</array>
```

4. **App Tracking Transparency** (for iOS 14+):

For iOS 14+, you'll need to request permission for tracking. The AnalyticsService assumes you're handling this separately using the `app_tracking_transparency` package.

## Implement App Tracking Transparency for iOS 14+ (Recommended)

1. Add the package:

```yaml
dependencies:
  app_tracking_transparency: ^2.0.4
```

2. Request tracking permission before initializing the AnalyticsService:

```dart
Future<void> requestTrackingPermission() async {
  if (Platform.isIOS) {
    final status = await AppTrackingTransparency.requestTrackingAuthorization();
    print('Tracking authorization status: $status');
  }
}
```
**********************************************************************************
*
## Usage Examples

### Initialize the SDK

Initialize the SDK in your app's startup process (typically in `main.dart` or your app initialization class):

```dart
import 'package:your_app/services/analytics_service.dart';

Future<void> initializeAnalytics() async {
  // For iOS, request tracking permission first
  if (Platform.isIOS) {
    await requestTrackingPermission();
  }

  await AnalyticsService().initialize(
    appToken: 'YOUR_ADJUST_APP_TOKEN',
    environment: kReleaseMode
        ? AdjustEnvironment.production
        : AdjustEnvironment.sandbox,
    logLevel: kDebugMode
        ? AdjustLogLevel.verbose
        : AdjustLogLevel.suppress,
    isAttributionCallback: true,
  );
}
```

### Track Events

```dart
// Track a simple event
await AnalyticsService().trackEvent(
  eventToken: 'abc123',
);

// Track an event with parameters
await AnalyticsService().trackEvent(
  eventToken: 'abc123',
  parameters: {
    'product_id': '12345',
    'category': 'shoes',
  },
);

// Track a revenue event
await AnalyticsService().trackEvent(
  eventToken: 'purchase_event_token',
  revenue: 9.99,
  currency: 'USD',
  parameters: {
    'product_id': '12345',
    'transaction_id': 'TX-789',
  },
);
```

### Get Attribution Data

```dart
// Get the current attribution data
final attribution = await AnalyticsService().getAttribution();
if (attribution != null) {
  print('Campaign: ${attribution.campaign}');
  print('Adgroup: ${attribution.adgroup}');
  print('Creative: ${attribution.creative}');
  print('Network: ${attribution.network}');
}

// Get the Adjust ID
final adjustId = await AnalyticsService().getAdjustId();
print('Adjust ID: $adjustId');
```

### Control SDK State

```dart
// Disable tracking temporarily (e.g., for GDPR opt-out)
AnalyticsService().setEnabled(false);

// Re-enable tracking
AnalyticsService().setEnabled(true);

// Check if tracking is enabled
final isEnabled = await AnalyticsService().isEnabled();
print('Tracking enabled: $isEnabled');
```

### Session Parameters

```dart
// Add session parameters that will be sent with every event
AnalyticsService().addSessionParameter('user_type', 'premium');
AnalyticsService().addSessionParameter('app_version', '1.2.3');

// Remove a specific session parameter
AnalyticsService().removeSessionParameter('user_type');

// Reset all session parameters
AnalyticsService().resetSessionParameters();
```

### Set Push Token

```dart
// Set the push token for integrations
void setDeviceToken(String token) {
  AnalyticsService().setPushToken(token);
}
```

## Best Practices

1. Initialize the SDK as early as possible in your app lifecycle.
2. For iOS, always request tracking permission before initializing the SDK.
3. Use descriptive event names and consistent parameter naming.
4. Consider disabling tracking if the user opts out of analytics.
5. Handle attribution changes to track campaign performance.
6. Create constants for event tokens to avoid typos.
7. Add appropriate error handling in your production app.
*
*
*
*
*
* */