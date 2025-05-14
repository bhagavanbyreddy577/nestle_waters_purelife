import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Payment status enum to represent different states of payment
enum PaymentStatus {
  initial,
  processing,
  successful,
  failed,
  canceled
}

/// Payment response model to handle the response from CyberSource
class PaymentResponse {
  final bool success;
  final String? transactionId;
  final String? authorizationCode;
  final String? message;
  final Map<String, dynamic>? rawResponse;

  PaymentResponse({
    required this.success,
    this.transactionId,
    this.authorizationCode,
    this.message,
    this.rawResponse,
  });

  @override
  String toString() {
    return 'PaymentResponse{success: $success, transactionId: $transactionId, authorizationCode: $authorizationCode, message: $message}';
  }
}

/// Configuration for CyberSource payment
class CyberSourceConfig {
  /// Your CyberSource merchant ID
  final String merchantId;

  /// Your CyberSource API key
  final String apiKey;

  /// Your CyberSource shared secret key
  final String secretKey;

  /// Base URL for CyberSource API calls
  final String apiEndpoint;

  /// URL to return to after successful payment
  final String successUrl;

  /// URL to return to after failed payment
  final String failureUrl;

  /// URL to return to after canceled payment
  final String cancelUrl;

  /// Whether to use the test environment
  final bool testMode;

  CyberSourceConfig({
    required this.merchantId,
    required this.apiKey,
    required this.secretKey,
    required this.apiEndpoint,
    required this.successUrl,
    required this.failureUrl,
    required this.cancelUrl,
    this.testMode = true,
  });
}

/// A service class to handle payments through CyberSource payment gateway.
///
/// This service provides methods to initialize payment sessions and process
/// payments through a WebView integration with the CyberSource payment gateway.
class CyberSourcePaymentService {
  /// Singleton instance of CyberSourcePaymentService
  static final CyberSourcePaymentService _instance = CyberSourcePaymentService._internal();

  /// Factory constructor to return the singleton instance
  factory CyberSourcePaymentService() => _instance;

  /// Configuration for CyberSource
  CyberSourceConfig? _config;

  /// WebView controller
  WebViewController? _webViewController;

  /// Payment status stream controller
  final StreamController<PaymentStatus> _paymentStatusController = StreamController<PaymentStatus>.broadcast();

  /// Stream of payment status updates
  Stream<PaymentStatus> get paymentStatusStream => _paymentStatusController.stream;

  /// Current payment status
  PaymentStatus _currentStatus = PaymentStatus.initial;
  PaymentStatus get currentStatus => _currentStatus;

  /// Private constructor for singleton pattern
  CyberSourcePaymentService._internal();

  /// Initialize the payment service with CyberSource configuration.
  ///
  /// Must be called before making any payment requests.
  void initialize(CyberSourceConfig config) {
    _config = config;
    debugPrint('CyberSourcePaymentService initialized with merchantId: ${config.merchantId}');

    // Initialize platform specific WebView settings
    if (Platform.isAndroid) {
      // For Android, we don't need to explicitly set the platform anymore
      // as it's handled by the package internally in newer versions
    } else if (Platform.isIOS) {
      // For iOS, we don't need to explicitly set the platform anymore
      // as it's handled by the package internally in newer versions
    }
  }

  /// Update the payment status and notify listeners
  void _updatePaymentStatus(PaymentStatus status) {
    _currentStatus = status;
    _paymentStatusController.add(status);
  }

  /// Create a WebView controller for processing payments
  WebViewController _createWebViewController() {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('WebView page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('WebView page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            _updatePaymentStatus(PaymentStatus.failed);
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('WebView navigation to: ${request.url}');

            if (_config == null) {
              return NavigationDecision.navigate;
            }

            // Handle redirection URLs
            if (request.url.startsWith(_config!.successUrl)) {
              _handleSuccessfulPayment(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.startsWith(_config!.failureUrl)) {
              _handleFailedPayment(request.url);
              return NavigationDecision.prevent;
            } else if (request.url.startsWith(_config!.cancelUrl)) {
              _handleCanceledPayment();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    return controller;
  }

  /// Create a payment session with CyberSource and return a widget to display the payment page.
  ///
  /// [amount] The payment amount
  /// [currency] The currency code (e.g., 'USD')
  /// [orderId] A unique order identifier
  /// [customerDetails] Optional map of customer details
  Future<Widget> createPaymentWidget({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? customerDetails,
  }) async {
    if (_config == null) {
      throw StateError('CyberSourcePaymentService not initialized. Call initialize() first.');
    }

    _updatePaymentStatus(PaymentStatus.processing);

    // Create a payment session with CyberSource
    final String paymentUrl = await _createPaymentSession(
      amount: amount,
      currency: currency,
      orderId: orderId,
      customerDetails: customerDetails,
    );

    // Create and store WebView controller
    _webViewController = _createWebViewController();

    // Load the payment URL
    await _webViewController!.loadRequest(Uri.parse(paymentUrl));

    // Return the WebView widget
    return WebViewWidget(controller: _webViewController!);
  }

  /// Create a payment session with CyberSource and return the payment URL.
  ///
  /// This makes an API call to your backend service that communicates with CyberSource.
  Future<String> _createPaymentSession({
    required double amount,
    required String currency,
    required String orderId,
    Map<String, dynamic>? customerDetails,
  }) async {
    if (_config == null) {
      throw StateError('CyberSourcePaymentService not initialized. Call initialize() first.');
    }

    try {
      // In a real implementation, you would make an API call to your backend
      // service that creates a session with CyberSource using their API.
      // The backend would return a URL or a token to use in the WebView.

      // Simulate API call to your backend service
      // Replace this with your actual API call
      final http.Response response = await http.post(
        Uri.parse('${_config!.apiEndpoint}/create-payment-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_config!.apiKey}',
        },
        body: jsonEncode({
          'merchantId': _config!.merchantId,
          'amount': amount,
          'currency': currency,
          'orderId': orderId,
          'successUrl': _config!.successUrl,
          'failureUrl': _config!.failureUrl,
          'cancelUrl': _config!.cancelUrl,
          'customerDetails': customerDetails ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['paymentUrl'] as String;
      } else {
        throw Exception('Failed to create payment session: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating payment session: $e');
      _updatePaymentStatus(PaymentStatus.failed);
      rethrow;
    }
  }

  /// Handle a successful payment redirection
  void _handleSuccessfulPayment(String url) {
    try {
      // Parse URL parameters to extract transaction details
      final Uri uri = Uri.parse(url);
      final Map<String, String> params = uri.queryParameters;

      // Create payment response
      final PaymentResponse response = PaymentResponse(
        success: true,
        transactionId: params['transaction_id'],
        authorizationCode: params['auth_code'],
        message: 'Payment successful',
        rawResponse: params.map((key, value) => MapEntry(key, value)),
      );

      debugPrint('Payment successful: $response');
      _updatePaymentStatus(PaymentStatus.successful);

      // Notify any listeners about the successful payment
      _notifyPaymentCompletion(response);
    } catch (e) {
      debugPrint('Error handling successful payment: $e');
      _updatePaymentStatus(PaymentStatus.failed);
    }
  }

  /// Handle a failed payment redirection
  void _handleFailedPayment(String url) {
    try {
      // Parse URL parameters to extract error details
      final Uri uri = Uri.parse(url);
      final Map<String, String> params = uri.queryParameters;

      // Create payment response
      final PaymentResponse response = PaymentResponse(
        success: false,
        message: params['error_message'] ?? 'Payment failed',
        rawResponse: params.map((key, value) => MapEntry(key, value)),
      );

      debugPrint('Payment failed: $response');
      _updatePaymentStatus(PaymentStatus.failed);

      // Notify any listeners about the failed payment
      _notifyPaymentCompletion(response);
    } catch (e) {
      debugPrint('Error handling failed payment: $e');
      _updatePaymentStatus(PaymentStatus.failed);
    }
  }

  /// Handle a canceled payment
  void _handleCanceledPayment() {
    // Create payment response
    final PaymentResponse response = PaymentResponse(
      success: false,
      message: 'Payment canceled by user',
    );

    debugPrint('Payment canceled: $response');
    _updatePaymentStatus(PaymentStatus.canceled);

    // Notify any listeners about the canceled payment
    _notifyPaymentCompletion(response);
  }

  /// Payment completion callback
  void Function(PaymentResponse)? onPaymentCompletion;

  /// Notify listeners about payment completion
  void _notifyPaymentCompletion(PaymentResponse response) {
    if (onPaymentCompletion != null) {
      onPaymentCompletion!(response);
    }
  }

  /// Check if the payment service is initialized
  bool get isInitialized => _config != null;

  /// Dispose the payment service and release resources
  void dispose() {
    _paymentStatusController.close();
    _webViewController = null;
  }
}

/// TODO: Implementation and Usage Example (Need to remove in production)
/*
*
*
* # How to Implement CyberSource Payment Gateway in Flutter

This guide will walk you through the process of implementing the CyberSource payment gateway in your Flutter application using the `CyberSourcePaymentService` class.

## Installation

1. Add required dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.4.2  # Use the latest version
  webview_flutter_android: ^3.12.0  # Android implementation
  webview_flutter_wkwebview: ^3.9.2  # iOS implementation
  http: ^1.1.0  # Use the latest version
```

2. Run `flutter pub get` to install the dependencies.

## Native Platform Configuration

### Android Configuration

1. **Update AndroidManifest.xml**:

Open `android/app/src/main/AndroidManifest.xml` and add the following permissions:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

2. **Minimum SDK Version**:

Ensure your `android/app/build.gradle` file has a minimum SDK version of 19 or higher:

```gradle
defaultConfig {
    // Other configurations...
    minSdkVersion 19
    // ...
}
```

3. **WebView setup**:

The `WebView.platform = AndroidWebView()` in the `initialize` method of `CyberSourcePaymentService` will handle the setup for Android.

### iOS Configuration

1. **Update Info.plist**:

Open `ios/Runner/Info.plist` and add the following between the `<dict>` tags to allow loading of WebView content:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
<key>io.flutter.embedded_views_preview</key>
<true/>
```

2. **Minimum iOS Version**:

Make sure your `ios/Podfile` has the following line to set the minimum iOS version:

```ruby
platform :ios, '11.0'
```

## Backend Integration

The `CyberSourcePaymentService` assumes you have a backend service that:

1. Communicates with CyberSource API to create payment sessions
2. Returns a URL to load in the WebView
3. Handles redirects and returns appropriate query parameters

You need to implement the backend service that:
- Creates a payment session with CyberSource using their REST API
- Signs API requests according to CyberSource requirements
- Handles the payment flow and redirects

********************************************************************************
*
## Usage Examples

### Basic Setup

First, create and initialize the payment service early in your app lifecycle:

```dart
import 'package:your_app/services/cybersource_payment_service.dart';

void initializePaymentService() {
  final config = CyberSourceConfig(
    merchantId: 'your_merchant_id',
    apiKey: 'your_api_key',
    secretKey: 'your_secret_key',
    apiEndpoint: 'https://your-backend-api.com/api',
    successUrl: 'https://your-app.com/success',
    failureUrl: 'https://your-app.com/failure',
    cancelUrl: 'https://your-app.com/cancel',
    testMode: true, // Set to false for production
  );

  CyberSourcePaymentService().initialize(config);
}
```

### Create a Payment Page

```dart
import 'package:flutter/material.dart';
import 'package:your_app/services/cybersource_payment_service.dart';

class PaymentPage extends StatefulWidget {
  final double amount;
  final String currency;
  final String orderId;

  const PaymentPage({
    Key? key,
    required this.amount,
    required this.currency,
    required this.orderId,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final CyberSourcePaymentService _paymentService = CyberSourcePaymentService();
  late Stream<PaymentStatus> _paymentStatusStream;
  bool _isLoading = true;
  Widget? _paymentWidget;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _paymentStatusStream = _paymentService.paymentStatusStream;
    _initializePayment();

    // Set up payment completion callback
    _paymentService.onPaymentCompletion = (response) {
      if (response.success) {
        // Handle successful payment
        // e.g., Navigate to order confirmation page
        Navigator.of(context).pushReplacementNamed(
          '/order-confirmation',
          arguments: {
            'transactionId': response.transactionId,
            'amount': widget.amount,
            'orderId': widget.orderId,
          },
        );
      } else {
        // Handle failed payment
        // Show error message or navigate to failure page
        setState(() {
          _errorMessage = response.message ?? 'Payment failed';
        });
      }
    };
  }

  Future<void> _initializePayment() async {
    try {
      // Optional: Add customer details
      final customerDetails = {
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john.doe@example.com',
        'phone': '1234567890',
      };

      final paymentWidget = await _paymentService.createPaymentWidget(
        amount: widget.amount,
        currency: widget.currency,
        orderId: widget.orderId,
        customerDetails: customerDetails,
      );

      setState(() {
        _paymentWidget = paymentWidget;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize payment: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Show confirmation dialog before closing
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text('Are you sure you want to cancel the payment?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('NO'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('YES'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<PaymentStatus>(
        stream: _paymentStatusStream,
        initialData: _paymentService.currentStatus,
        builder: (context, snapshot) {
          final status = snapshot.data ?? PaymentStatus.initial;

          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (_isLoading || status == PaymentStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (status == PaymentStatus.processing && _paymentWidget != null) {
            return _paymentWidget!;
          }

          // Handle other statuses (success/failure will be handled by onPaymentCompletion)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Payment status: ${status.toString().split('.').last}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Optional: Clean up resources
    super.dispose();
  }
}
```

### Navigate to Payment Page

```dart
// From your checkout page
ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          amount: 99.99,
          currency: 'USD',
          orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        ),
      ),
    );
  },
  child: const Text('Pay Now'),
),
```

## Backend Implementation Notes

Your backend needs to implement the following endpoints:

1. **Create Payment Session**:
   - Endpoint: `/create-payment-session`
   - Method: POST
   - Input: Merchant ID, amount, currency, order ID, success/failure/cancel URLs
   - Output: Payment URL to load in WebView

2. **Handle Redirects**:
   - Set up endpoints for success, failure, and cancel URLs
   - These should redirect back to your app with appropriate parameters

### CyberSource REST API Integration

Your backend should use the CyberSource REST API to:

1. Create a payment session
2. Generate a secure checkout URL
3. Handle payment notifications

The implementation will vary based on your backend technology (Node.js, Java, Python, etc.), but CyberSource provides SDKs for most languages.

## Security Considerations

1. **Never store the CyberSource API key or secret key in the mobile app code**. Always communicate with your backend service, which securely stores these credentials.

2. **Verify all payment responses server-side** to prevent tampering with payment success parameters.

3. Consider implementing additional security measures:
   - SSL pinning to prevent man-in-the-middle attacks
   - Transaction signing on your backend
   - IP and device fingerprinting for fraud detection

4. Monitor and log all payment activities for auditing purposes.

## Testing

CyberSource provides a sandbox environment for testing:

1. Create a test account on CyberSource Developer Center
2. Use test card numbers provided by CyberSource
3. Set `testMode: true` in your `CyberSourceConfig`

## Troubleshooting

Common issues include:

1. **WebView not loading**: Check internet permissions in AndroidManifest.xml and Info.plist
2. **Failed to create payment session**: Verify backend API is correctly implemented and accessible
3. **Redirection not working**: Ensure success/failure/cancel URLs are properly configured both in code and CyberSource dashboard

Always check the debug logs for more details on errors.
*
*
*
*
*
* */