import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pushwoosh_flutter/pushwoosh_flutter.dart';

/// A service class that handles push notifications using the Pushwoosh service.
/// This class follows the singleton pattern to ensure only one instance exists throughout the app.
class PushNotificationService {
  // Singleton instance
  static final PushNotificationService _instance = PushNotificationService._internal();

  // Factory constructor to return the singleton instance
  factory PushNotificationService() => _instance;

  // Private constructor
  PushNotificationService._internal();

  // Pushwoosh instance
  final Pushwoosh _pushwoosh = Pushwoosh();

  // Stream controller for push notification events
  final StreamController<Map<String, dynamic>> _notificationStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  /// Stream that broadcasts push notification data
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;

  /// Initialize the push notification service
  ///
  /// This method must be called in your app's initialization phase,
  /// preferably in the main.dart file or in your app's entry widget.
  Future<void> initialize() async {
    try {
      // Register for push notifications
      await _pushwoosh.registerForPushNotifications();

      // Configure notification handlers
      _setupNotificationHandlers();

      // Log successful initialization
      debugPrint('PushNotificationService: Successfully initialized');
    } catch (e) {
      debugPrint('PushNotificationService: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Set up notification handlers to process incoming notifications
  void _setupNotificationHandlers() {
    // Handle notifications when the app is in the foreground
    _pushwoosh.onPushReceived.listen((event) {
      debugPrint('PushNotificationService: Push received - $event');
      if (event is Map<String, dynamic>) {
        _notificationStreamController.add(event as Map<String, dynamic>);
      }
    });

    // Handle when a user taps on a notification
    _pushwoosh.onPushAccepted.listen((event) {
      debugPrint('PushNotificationService: Push accepted - $event');
      if (event is Map<String, dynamic>) {
        _notificationStreamController.add({
          ...event as Map<String, dynamic>,
          'opened': true,
        });
      }
    });
  }

  /// Get the push token that uniquely identifies this device
  ///
  /// This token can be used for targeting specific devices
  Future<String?> getPushToken() async {
    try {
      final token = await _pushwoosh.getPushToken;
      return token;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to get push token - $e');
      return null;
    }
  }

  /// Get the Pushwoosh hardware ID for this device
  Future<String?> getHardwareID() async {
    try {
      final hwid = await _pushwoosh.getHWID;
      return hwid;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to get hardware ID - $e');
      return null;
    }
  }

  /// Subscribe to a specific tag or topic for targeted notifications
  Future<bool> subscribeToTopic(String topic) async {
    try {
      await _pushwoosh.setTags({topic: true});
      debugPrint('PushNotificationService: Subscribed to topic - $topic');
      return true;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to subscribe to topic $topic - $e');
      return false;
    }
  }

  /// Unsubscribe from a specific tag or topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _pushwoosh.setTags({topic: false});
      debugPrint('PushNotificationService: Unsubscribed from topic - $topic');
      return true;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to unsubscribe from topic $topic - $e');
      return false;
    }
  }

  /// Set user ID for better targeting and analytics
  Future<bool> setUserId(String userId) async {
    try {
      _pushwoosh.setUserId(userId);
      debugPrint('PushNotificationService: User ID set - $userId');
      return true;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to set user ID - $e');
      return false;
    }
  }

  /// Set user email for better targeting and analytics
  Future<bool> setUserEmail(String userId, String email) async {
    try {
      await _pushwoosh.setUserEmails(userId, [email]);
      debugPrint('PushNotificationService: User email set - $email');
      return true;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to set user email - $e');
      return false;
    }
  }

  /// Enable or disable push notifications
  Future<bool> setPushNotificationsEnabled(bool enabled) async {
    try {
      if (enabled) {
        await _pushwoosh.registerForPushNotifications();
      } else {
        await _pushwoosh.unregisterForPushNotifications();
      }
      debugPrint('PushNotificationService: Push notifications ${enabled ? 'enabled' : 'disabled'}');
      return true;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to ${enabled ? 'enable' : 'disable'} push notifications - $e');
      return false;
    }
  }

  /// Check if push notifications are enabled
  Future<bool> isPushNotificationsEnabled() async {
    try {
      // Pushwoosh doesn't provide a direct method to check if notifications are enabled
      // You might want to store this state in shared preferences or other local storage
      // For now, we'll return true if we can get a token, which implies registration
      final token = await _pushwoosh.getPushToken;
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to check if push notifications are enabled - $e');
      return false;
    }
  }

  /// This method can be used to show an in-app notification
  Future<bool> showLocalNotification({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (Platform.isAndroid) {
        // For Android
        await _pushwoosh.postEvent("LocalNotification", {"title": title, "message": message, "data": data});
        return true;
      } else if (Platform.isIOS) {
        // For iOS
        await _pushwoosh.postEvent("LocalNotification", {"title": title, "message": message, "data": data});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to show local notification - $e');
      return false;
    }
  }

  /// Dispose method to clean up resources when no longer needed
  void dispose() {
    _notificationStreamController.close();
  }
}


/// TODO: Integration Guide and Usage Example (Need to remoce in production)
/*
*
*
* # Native Setup Instructions for Pushwoosh Flutter Integration

## Android Setup

### 1. Update `android/app/build.gradle`

Add Google Services dependency in the project-level build.gradle file:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

### 2. Update `android/app/build.gradle` (app-level)

Add the following at the end of the file:

```gradle
// Add the Google services plugin at the bottom of the file
apply plugin: 'com.google.gms.google-services'

dependencies {
    // Add Firebase Messaging dependency
    implementation 'com.google.firebase:firebase-messaging:23.3.1'

    // Add Pushwoosh dependency (the Flutter plugin will use this)
    implementation 'com.pushwoosh:pushwoosh:6.6.13'
}
```

### 3. Create `google-services.json`

- Get your `google-services.json` file from Firebase Console
- Place it in the `android/app/` directory

### 4. Update `AndroidManifest.xml`

Add the following permissions to your `android/app/src/main/AndroidManifest.xml` file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        ...>

        <!-- Add Pushwoosh App ID and FCM Sender ID -->
        <meta-data
            android:name="com.pushwoosh.appid"
            android:value="YOUR_PUSHWOOSH_APP_ID" />
        <meta-data
            android:name="com.pushwoosh.senderid"
            android:value="YOUR_FCM_SENDER_ID" />

        <!-- Add this service for handling FCM messages -->
        <service
            android:name="com.pushwoosh.firebase.PushwooshFcmListenerService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Add this for supporting notification channels on Android 8+ -->
        <meta-data
            android:name="com.pushwoosh.notification_channel_name"
            android:value="Push Notifications" />
        <meta-data
            android:name="com.pushwoosh.notification_channel_description"
            android:value="Push notifications from the app" />
    </application>
</manifest>
```

### 5. Update `android/app/src/main/kotlin/YOUR_PACKAGE_PATH/MainActivity.kt`

Add the following code to initialize Pushwoosh in your MainActivity:

```kotlin
package YOUR_PACKAGE_PATH

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import com.pushwoosh.Pushwoosh

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Pushwoosh
        Pushwoosh.getInstance().registerForPushNotifications()
    }
}
```

## iOS Setup

### 1. Update `ios/Runner/AppDelegate.swift`

Add the following code to your AppDelegate:

```swift
import UIKit
import Flutter
import Pushwoosh
import PushwooshInboxUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Pushwoosh
        PushNotificationManager.initialize(
            withAppCode: "YOUR_PUSHWOOSH_APP_ID",
            appName: "YOUR_APP_NAME"
        )

        // Register for push notifications
        PushNotificationManager.push().delegate = self
        PushNotificationManager.push().registerForPushNotifications()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // For handling push notifications when app is in foreground
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        PushNotificationManager.push().handlePushReceived(with: userInfo)
        super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        completionHandler(.newData)
    }

    // For handling push notifications when user taps on them
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any]
    ) {
        PushNotificationManager.push().handlePushReceived(with: userInfo)
        super.application(application, didReceiveRemoteNotification: userInfo)
    }
}

// MARK: - PushNotificationDelegate
extension AppDelegate: PushNotificationDelegate {
    // Handle push notification opened events
    func onPushReceived(_ pushPayload: PWPushNotificationManager.PushNotificationData) {
        // Handle push notification when app is in foreground
        print("Push notification received: \(pushPayload.customData)")
    }

    func onPushAccepted(_ pushPayload: PWPushNotificationManager.PushNotificationData) {
        // Handle push notification when user taps on it
        print("Push notification accepted: \(pushPayload.customData)")
    }
}
```

### 2. Update `Info.plist`

Add the following keys to your `ios/Runner/Info.plist` file:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>

<key>NSUserTrackingUsageDescription</key>
<string>This allows us to send you personalized notifications.</string>
```

### 3. Enable Push Notification Capability

1. In Xcode, open your project
2. Select your target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and check "Remote notifications"

### 4. Create APNs Certificate or Key

1. Go to Apple Developer Account
2. Create a Push Notification certificate or key
3. Download the certificate and convert it to .p12 format
4. Upload the certificate to Pushwoosh Console

## General Configuration

### 1. Add Pushwoosh dependencies in `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  pushwoosh_flutter: ^3.0.0  # Use the latest version
```

### 2. Initialize Pushwoosh in your main.dart

```dart
import 'package:flutter/material.dart';
import 'package:pushwoosh_flutter/pushwoosh_flutter.dart';
import 'push_notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await PushNotificationService().initialize();

  // Run the app
  runApp(MyApp());
}
```

## Common Issues and Solutions

### Android

- **Issue**: Push notifications not showing on Android 13+
  - **Solution**: Ensure you've added the `POST_NOTIFICATIONS` permission and are requesting it at runtime

- **Issue**: Notifications not showing custom icons
  - **Solution**: Add a notification icon to `android/app/src/main/res/drawable` and specify it in `AndroidManifest.xml`

### iOS

- **Issue**: Push notifications not working on iOS
  - **Solution**: Ensure your provisioning profile has Push Notification capability enabled

- **Issue**: App receives notifications but does not respond to taps
  - **Solution**: Ensure you've implemented the `onPushAccepted` method in AppDelegate
*
* **************************************************************************************
*
* Usage Example:
*
* import 'package:flutter/material.dart';
import 'push_notification_service.dart';

/// Example usage of the PushNotificationService
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service
  await PushNotificationService().initialize();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushwoosh Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotificationDemo(),
    );
  }
}

class NotificationDemo extends StatefulWidget {
  const NotificationDemo({Key? key}) : super(key: key);

  @override
  State<NotificationDemo> createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  final PushNotificationService _notificationService = PushNotificationService();
  String _pushToken = 'Not fetched yet';
  String _lastNotification = 'No notifications received';
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchPushToken();
    _checkNotificationStatus();
    _setupNotificationListener();
  }

  Future<void> _fetchPushToken() async {
    final token = await _notificationService.getPushToken();
    setState(() {
      _pushToken = token ?? 'Failed to fetch token';
    });
  }

  Future<void> _checkNotificationStatus() async {
    final enabled = await _notificationService.isPushNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  void _setupNotificationListener() {
    _notificationService.notificationStream.listen((notification) {
      setState(() {
        _lastNotification = notification.toString();
      });

      // Handle the notification based on your app's requirements
      if (notification['opened'] == true) {
        // User tapped on the notification, navigate to specific screen
        _navigateBasedOnNotification(notification);
      }
    });
  }

  void _navigateBasedOnNotification(Map<String, dynamic> notification) {
    // Example navigation logic based on notification payload
    // This is just a placeholder - implement your own navigation logic

    // Example:
    // if (notification['data']?['screen'] == 'profile') {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (context) => ProfileScreen()),
    //   );
    // }

    debugPrint('Should navigate based on: $notification');
  }

  Future<void> _toggleNotifications() async {
    final newStatus = !_notificationsEnabled;
    final success = await _notificationService.setPushNotificationsEnabled(newStatus);

    if (success) {
      setState(() {
        _notificationsEnabled = newStatus;
      });
    }
  }

  Future<void> _subscribeToTopic() async {
    // Example topic subscription
    await _notificationService.subscribeToTopic('news');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscribed to news topic')),
    );
  }

  Future<void> _showLocalNotification() async {
    await _notificationService.showLocalNotification(
      title: 'Local Notification',
      message: 'This is a test notification from the app',
      data: {'screen': 'home'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pushwoosh Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Push Notification Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Push Token: $_pushToken'),
            const SizedBox(height: 10),
            Text(
              'Notifications ${_notificationsEnabled ? 'Enabled' : 'Disabled'}',
              style: TextStyle(
                color: _notificationsEnabled ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Last Notification:'),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(_lastNotification),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleNotifications,
              child: Text(
                _notificationsEnabled ? 'Disable Notifications' : 'Enable Notifications',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _subscribeToTopic,
              child: const Text('Subscribe to News Topic'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showLocalNotification,
              child: const Text('Show Local Notification'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    _notificationService.dispose();
    super.dispose();
  }
}
*
* */