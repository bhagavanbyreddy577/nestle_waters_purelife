import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A service class to handle OneTrust CMP (Consent Management Platform) operations
/// for governance, risk, and compliance solutions.
///
/// This service provides methods to initialize the OneTrust SDK, handle user consent,
/// and manage privacy preferences across both Android and iOS platforms.
class OnetrustService {
  // Singleton pattern implementation
  static final OnetrustService _instance = OnetrustService._internal();
  factory OnetrustService() => _instance;
  OnetrustService._internal();

  /// The method channel for communicating with the native plugin
  final MethodChannel _methodChannel = const MethodChannel('onetrust_publishers_native_cmp');

  /// The event channel for receiving consent change events
  final EventChannel _eventChannel = const EventChannel('onetrust_publishers_native_cmp/consent_changed');

  /// Stream controller for consent changes
  final _consentChangeController = StreamController<Map<String, dynamic>>.broadcast();

  /// Stream for listening to consent changes
  Stream<Map<String, dynamic>> get onConsentChanged => _consentChangeController.stream;

  /// Flag to track if OneTrust has been initialized
  bool _isInitialized = false;

  /// Getter to check if OneTrust has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the OneTrust SDK with the specified app ID
  ///
  /// [appId] The OneTrust application ID from your OneTrust dashboard
  /// [domainIdentifier] Optional domain identifier for web applications (can be null for mobile apps)
  /// [languageCode] Optional language code for localization (e.g., 'en', 'es', 'fr')
  ///
  /// Returns a [Future<bool>] indicating whether initialization was successful
  Future<bool> initialize({
    required String appId,
    String? domainIdentifier,
    String? languageCode,
  }) async {
    try {
      // Set up consent change listener
      _setupConsentListener();

      // Initialize the OneTrust SDK
      final result = await _methodChannel.invokeMethod<bool>(
        'initializeCmpSDK',
        {
          'otAppId': appId,
          'domainIdentifier': domainIdentifier,
          'languageCode': languageCode,
        },
      ) ?? false;

      _isInitialized = result;

      if (result) {
        debugPrint('✅ OneTrust SDK initialized successfully');
      } else {
        debugPrint('❌ OneTrust SDK initialization failed');
      }

      return result;
    } on PlatformException catch (e) {
      debugPrint('❌ OneTrust SDK initialization error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ OneTrust SDK initialization error: $e');
      return false;
    }
  }

  /// Set up listener for consent changes
  void _setupConsentListener() {
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        final Map<String, dynamic> consentData = Map<String, dynamic>.from(event);
        // Forward the consent change event to our stream
        _consentChangeController.add(consentData);
        debugPrint('OneTrust consent changed: $consentData');
      }
    }, onError: (dynamic error) {
      debugPrint('Error in consent change listener: $error');
    });
  }

  /// Show the OneTrust consent UI
  ///
  /// [uiType] The type of UI to display:
  /// - 1: Banner
  /// - 2: Preference Center
  /// - 3: Both Banner and Preference Center
  Future<void> showConsentUI({
    int uiType = 2, // Default to Preference Center
  }) async {
    if (!_isInitialized) {
      debugPrint('❌ Cannot show consent UI: OneTrust SDK not initialized');
      return;
    }

    try {
      await _methodChannel.invokeMethod<void>('showConsentUI', {'uiType': uiType});
    } catch (e) {
      debugPrint('❌ Error showing consent UI: $e');
    }
  }

  /// Get the current consent status for a specific category
  ///
  /// [categoryId] The OneTrust category ID to check
  ///
  /// Returns a [Future<bool>] indicating whether consent is granted
  Future<bool> hasConsentForCategory(String categoryId) async {
    if (!_isInitialized) {
      debugPrint('❌ Cannot check consent: OneTrust SDK not initialized');
      return false;
    }

    try {
      return await _methodChannel.invokeMethod<bool>(
        'getConsentStatusForCategory',
        {'categoryId': categoryId},
      ) ?? false;
    } catch (e) {
      debugPrint('❌ Error checking consent for category $categoryId: $e');
      return false;
    }
  }

  /// Get all consent categories and their status
  ///
  /// Returns a [Future<Map<String, dynamic>>] with all consent information
  Future<Map<String, dynamic>> getAllConsents() async {
    if (!_isInitialized) {
      debugPrint('❌ Cannot get consents: OneTrust SDK not initialized');
      return {};
    }

    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getConsentStatus');
      if (result == null) return {};

      // Convert to Map<String, dynamic>
      return result.map((key, value) => MapEntry(key.toString(), value));
    } catch (e) {
      debugPrint('❌ Error getting all consents: $e');
      return {};
    }
  }

  /// Download and update the latest OneTrust data files
  ///
  /// Returns a [Future<bool>] indicating whether the update was successful
  Future<bool> updateOTData() async {
    if (!_isInitialized) {
      debugPrint('❌ Cannot update data: OneTrust SDK not initialized');
      return false;
    }

    try {
      return await _methodChannel.invokeMethod<bool>('downloadOTData') ?? false;
    } catch (e) {
      debugPrint('❌ Error updating OneTrust data: $e');
      return false;
    }
  }

  /// Get the OneTrust SDK version
  ///
  /// Returns a [Future<String>] with the SDK version
  Future<String> getSdkVersion() async {
    try {
      return await _methodChannel.invokeMethod<String>('getOTSDKVersion') ?? 'Unknown';
    } catch (e) {
      debugPrint('❌ Error getting SDK version: $e');
      return 'Unknown';
    }
  }

  /// Check if the device has Do Not Track enabled
  ///
  /// Returns a [Future<bool>] indicating whether DNT is enabled
  Future<bool> isDoNotTrackEnabled() async {
    if (!_isInitialized) {
      debugPrint('❌ Cannot check DNT: OneTrust SDK not initialized');
      return false;
    }

    try {
      if (Platform.isIOS) {
        return await _methodChannel.invokeMethod<bool>('getDNTStatus') ?? false;
      } else {
        // Android doesn't have a built-in DNT feature in the same way
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error checking DNT status: $e');
      return false;
    }
  }

  /// Get the user's jurisdiction (e.g., GDPR, CCPA)
  ///
  /// Returns a [Future<String>] with the jurisdiction code
  Future<String> getUserJurisdiction() async {
    if (!_isInitialized) {
      debugPrint('❌ Cannot get jurisdiction: OneTrust SDK not initialized');
      return 'unknown';
    }

    try {
      final geoData = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getGeolocationData');
      if (geoData == null) return 'unknown';

      // Convert to Map<String, dynamic>
      final typedGeoData = geoData.map((key, value) => MapEntry(key.toString(), value));
      return typedGeoData['countryCode'] as String? ?? 'unknown';
    } catch (e) {
      debugPrint('❌ Error getting user jurisdiction: $e');
      return 'unknown';
    }
  }

  /// Clean up resources when the service is no longer needed
  void dispose() {
    _consentChangeController.close();
  }
}


/// TODO: Provided "Integration Guide" and "Usage Example" (Need to remove in production)
/*
*
* # OneTrust Integration Guide for Flutter

This guide explains how to integrate the OneTrust CMP (Consent Management Platform) into your Flutter application using the `OnetrustService` class.

## Setup Guide

### 1. Add Dependencies

Add the OneTrust package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  onetrust_publishers_native_cmp: ^6.43.0  # Check for the latest version
```

Run `flutter pub get` to install the package.

### 2. Android Setup

#### Modify your `android/app/build.gradle`:

Add the OneTrust repository to your repositories section:

```gradle
repositories {
    google()
    mavenCentral()
    // Add OneTrust repository
    maven {
        url "https://onetrust.jfrog.io/artifactory/libs-release-local"
        credentials {
            username = "otpub"
            password = "AP9nisJpN4Ge4SYB4tobEpTNxNP"
        }
    }
}
```

#### Modify your `android/app/src/main/AndroidManifest.xml`:

Add the following inside the `<application>` tag:

```xml
<meta-data
    android:name="com.onetrust.app.id"
    android:value="YOUR_ONETRUST_APP_ID" />
```

### 3. iOS Setup

#### Modify your `ios/Runner/Info.plist`:

Add the following inside the `<dict>` tag:

```xml
<key>OneTrustAppID</key>
<string>YOUR_ONETRUST_APP_ID</string>
```

#### Add OneTrust repository to `ios/Podfile`:

At the top of your Podfile, add:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://onetrust.jfrog.io/artifactory/api/pods/cocoapods-release-local'
```

## Usage Guide

### Initialize the Service

Initialize the OneTrust service early in your app's lifecycle:

```dart
import 'package:flutter/material.dart';
import 'path_to_your_file/onetrust_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneTrust
  final onetrustService = OnetrustService();
  await onetrustService.initialize(
    appId: 'YOUR_ONETRUST_APP_ID',
    languageCode: 'en', // Optional
  );

  runApp(MyApp());
}
```

### Show Consent UI

You can display the OneTrust consent UI when needed:

```dart
ElevatedButton(
  child: Text('Privacy Preferences'),
  onPressed: () async {
    await OnetrustService().showConsentUI();
  },
),
```

### Check Consent Status

Check if a user has consented to a specific category:

```dart
bool hasAnalyticsConsent = await OnetrustService().hasConsentForCategory('C0002');
if (hasAnalyticsConsent) {
  // Initialize analytics
} else {
  // Skip analytics initialization
}
```

### Listen for Consent Changes

Set up a listener to be notified when consent changes:

```dart
@override
void initState() {
  super.initState();

  OnetrustService().onConsentChanged.listen((consentData) {
    // Handle consent changes
    print('Consent changed: $consentData');

    // Update your app's data collection practices based on new consent
    if (consentData['C0002'] == true) {
      // User has consented to analytics
    } else {
      // User has withdrawn consent to analytics
    }
  });
}
```

### Get All Consent Information

```dart
Map<String, dynamic> allConsents = await OnetrustService().getAllConsents();
print('All consents: $allConsents');
```

### Cleaning Up

When you're done with the service, dispose of it properly:

```dart
@override
void dispose() {
  OnetrustService().dispose();
  super.dispose();
}
```

## Common OneTrust Category IDs

OneTrust typically uses these standard category IDs, but check your OneTrust dashboard for your specific configuration:

- **C0001**: Strictly Necessary Cookies (always active)
- **C0002**: Performance Cookies
- **C0003**: Functional Cookies
- **C0004**: Targeting Cookies
- **C0005**: Social Media Cookies

## Troubleshooting

1. **Consent UI not showing**: Ensure initialization was successful before showing the UI.
2. **Initialization failure**: Check if you've added all necessary native code configurations.
3. **Android build failures**: Verify the OneTrust repository is correctly added to your build.gradle.
4. **iOS build failures**: Make sure the OneTrust source is added correctly in your Podfile.

## Additional Resources

- [OneTrust Developer Portal](https://developer.onetrust.com/docs/mobile-sdks/)
- [OneTrust Publishers SDK Documentation](https://developer.onetrust.com/docs/onetrust-publishers-native-cmp-sdk-reference/)
*
* ==================================================================================================
*
*
*
* Usage example:
*
* import 'package:flutter/material.dart';
// Import your chosen version of the service
import 'onetrust_service.dart';
// If the first version doesn't work, use this alternative:
// import 'onetrust_service_alternative.dart';

/// Example widget demonstrating the usage of OnetrustService
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final OnetrustService _onetrustService = OnetrustService();
  Map<String, dynamic> _consentData = {};
  bool _isLoading = true;
  String _sdkVersion = "Unknown";

  @override
  void initState() {
    super.initState();
    _initializeOneTrust();
    _listenForConsentChanges();
  }

  // Initialize OneTrust and load initial consent data
  Future<void> _initializeOneTrust() async {
    // Only initialize if not already initialized
    if (!_onetrustService.isInitialized) {
      await _onetrustService.initialize(
        appId: 'YOUR_ONETRUST_APP_ID', // Replace with your actual OneTrust App ID
        languageCode: 'en',
      );
    }

    // Get SDK version
    _sdkVersion = await _onetrustService.getSdkVersion();

    // Load current consent status
    _loadConsentData();
  }

  // Set up listener for consent changes
  void _listenForConsentChanges() {
    _onetrustService.onConsentChanged.listen((consentData) {
      setState(() {
        _consentData = consentData;
      });

      // Example: Update app behavior based on consent
      _updateAppBehaviorBasedOnConsent();
    });
  }

  // Load the current consent data
  Future<void> _loadConsentData() async {
    setState(() {
      _isLoading = true;
    });

    final consents = await _onetrustService.getAllConsents();

    setState(() {
      _consentData = consents;
      _isLoading = false;
    });
  }

  // Example function to update app behavior based on consent
  void _updateAppBehaviorBasedOnConsent() {
    // Get analytics consent status (category ID may vary based on your OneTrust setup)
    bool hasAnalyticsConsent = _consentData['C0002'] == true;
    bool hasMarketingConsent = _consentData['C0004'] == true;

    debugPrint('Analytics consent: $hasAnalyticsConsent');
    debugPrint('Marketing consent: $hasMarketingConsent');

    // Here you would update your analytics, marketing tools, etc.
    // For example:
    // if (hasAnalyticsConsent) {
    //   AnalyticsService.enable();
    // } else {
    //   AnalyticsService.disable();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OneTrust SDK Version: $_sdkVersion',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Your Privacy Choices',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Display current consent status
                  if (_consentData.isNotEmpty) ...[
                    _buildConsentItem(
                      'Strictly Necessary Cookies',
                      _consentData['C0001'] ?? true,
                      true,
                    ),
                    _buildConsentItem(
                      'Performance Cookies',
                      _consentData['C0002'] ?? false,
                      false,
                    ),
                    _buildConsentItem(
                      'Functional Cookies',
                      _consentData['C0003'] ?? false,
                      false,
                    ),
                    _buildConsentItem(
                      'Targeting Cookies',
                      _consentData['C0004'] ?? false,
                      false,
                    ),
                  ] else ...[
                    const Text('No consent data available'),
                  ],

                  const SizedBox(height: 32),

                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _onetrustService.showConsentUI();
                        // Data will be updated via the listener
                      },
                      child: const Text('Manage Cookie Preferences'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: _loadConsentData,
                      child: const Text('Refresh Consent Data'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildConsentItem(String title, bool isEnabled, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isRequired
                      ? 'Required - These cookies are necessary for the website to function'
                      : isEnabled
                          ? 'Enabled'
                          : 'Disabled',
                  style: TextStyle(
                    color: isRequired ? Colors.grey[700] : null,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Good practice to dispose the service when the widget is disposed
    // This will close the stream controller
    _onetrustService.dispose();
    super.dispose();
  }
}
*
* */