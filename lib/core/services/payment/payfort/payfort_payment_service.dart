import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:crypto/crypto.dart';

/// PayFort Configuration Model
/// Holds all required configuration parameters for PayFort integration
class PayFortConfig {
  final String merchantIdentifier;
  final String accessCode;
  final String shaRequestPhrase; // SHA request passphrase
  final String shaResponsePhrase; // SHA response passphrase
  final bool isLive; // Toggle between sandbox and production environments

  PayFortConfig({
    required this.merchantIdentifier,
    required this.accessCode,
    required this.shaRequestPhrase,
    required this.shaResponsePhrase,
    this.isLive = false,
  });

  /// Get the appropriate PayFort API URL based on environment
  String get payfortUrl => isLive
      ? 'https://checkout.payfort.com/FortAPI/paymentPage'
      : 'https://sbcheckout.payfort.com/FortAPI/paymentPage';
}

/// PayFort Payment Data Model
/// Represents the payment request data structure
class PayFortPaymentData {
  final String merchantReference; // Unique reference for this transaction
  final String customerEmail;
  final String customerName;
  final String currency; // e.g., "USD", "AED", etc.
  final double amount; // Amount to be charged
  final String language; // "en" or "ar"

  PayFortPaymentData({
    required this.merchantReference,
    required this.customerEmail,
    required this.customerName,
    required this.currency,
    required this.amount,
    this.language = "en",
  });
}

/// Enum for payment response status
enum PaymentStatus {
  success,
  failure,
  canceled,
  processing,
  unknown,
}

/// Payment response model
class PaymentResponse {
  final PaymentStatus status;
  final String? responseCode;
  final String? responseMessage;
  final String? transactionId;
  final Map<String, dynamic> rawResponse;

  PaymentResponse({
    required this.status,
    this.responseCode,
    this.responseMessage,
    this.transactionId,
    required this.rawResponse,
  });

  @override
  String toString() {
    return 'PaymentResponse{status: $status, responseCode: $responseCode, responseMessage: $responseMessage, transactionId: $transactionId}';
  }
}

/// PayFort Payment Service
/// Handles integration with PayFort payment gateway using WebView
class PayFortPaymentService {
  final PayFortConfig config;

  PayFortPaymentService({required this.config});

  /// Process payment using PayFort gateway
  /// Returns a Future with PaymentResponse object
  Future<PaymentResponse> processPayment(
      BuildContext context,
      PayFortPaymentData paymentData,
      ) async {
    // Prepare payment request data
    final requestData = _prepareRequestData(paymentData);

    // Generate HTML form for WebView
    final htmlForm = _generatePaymentForm(requestData);

    // Show WebView with the payment form
    final completer = Completer<PaymentResponse>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PayFortWebView(
          htmlContent: htmlForm,
          responseHandler: (response) {
            completer.complete(_handlePaymentResponse(response));
          },
        ),
      ),
    );

    return completer.future;
  }

  /// Prepares the request data with all required parameters
  Map<String, String> _prepareRequestData(PayFortPaymentData data) {
    // Convert amount to required format (e.g., 10.00 becomes 1000)
    final formattedAmount = (data.amount * 100).toInt().toString();

    // Create base request map
    final Map<String, String> requestData = {
      'merchant_identifier': config.merchantIdentifier,
      'access_code': config.accessCode,
      'merchant_reference': data.merchantReference,
      'language': data.language,
      'service_command': 'AUTHORIZATION', // Can be changed to PURCHASE if needed
      'command': 'PURCHASE',
      'currency': data.currency,
      'amount': formattedAmount,
      'customer_email': data.customerEmail,
      'customer_name': data.customerName,
      'return_url': 'http://payfort.return', // Special URL for WebView interception
    };

    // Add signature to request data
    final signature = _calculateSignature(requestData, config.shaRequestPhrase);
    requestData['signature'] = signature;

    return requestData;
  }

  /// Calculates HMAC-SHA256 signature for the request
  String _calculateSignature(Map<String, String> requestData, String phrase) {
    // Sort parameters alphabetically
    final sortedKeys = requestData.keys.toList()..sort();

    // Concatenate parameters
    String concatenatedString = '';
    for (var key in sortedKeys) {
      concatenatedString += '$key=${requestData[key]}';
    }

    // Add SHA phrase
    final signString = '$phrase$concatenatedString$phrase';

    // Calculate SHA-256 hash
    final bytes = utf8.encode(signString);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Generates HTML form with payment data for WebView
  String _generatePaymentForm(Map<String, String> requestData) {
    // Create form fields
    final fields = requestData.entries.map((entry) {
      return '<input type="hidden" name="${entry.key}" value="${entry.value}">';
    }).join('\n');

    // Create HTML with auto-submit form
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>PayFort Payment</title>
        <style>
          body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
          .loader { border: 5px solid #f3f3f3; border-top: 5px solid #3498db; border-radius: 50%; width: 50px; height: 50px; animation: spin 1s linear infinite; margin: 20px auto; }
          @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        </style>
      </head>
      <body onload="document.forms[0].submit();">
        <div class="loader"></div>
        <p>Redirecting to payment gateway...</p>
        <form action="${config.payfortUrl}" method="post">
          $fields
        </form>
      </body>
      </html>
    ''';
  }

  /// Processes and validates payment response
  PaymentResponse _handlePaymentResponse(Map<String, dynamic> response) {
    // Validate response signature if present
    if (response.containsKey('signature')) {
      final Map<String, String> signatureParams = {};
      response.forEach((key, value) {
        if (key != 'signature') {
          signatureParams[key] = value.toString();
        }
      });

      final calculatedSignature = _calculateSignature(
          signatureParams,
          config.shaResponsePhrase
      );

      if (calculatedSignature != response['signature']) {
        return PaymentResponse(
          status: PaymentStatus.failure,
          responseMessage: 'Invalid signature',
          rawResponse: response,
        );
      }
    }

    // Determine payment status based on response code
    final responseCode = response['response_code']?.toString() ?? '';
    final status = _getPaymentStatus(responseCode);

    return PaymentResponse(
      status: status,
      responseCode: responseCode,
      responseMessage: response['response_message']?.toString(),
      transactionId: response['fort_id']?.toString(),
      rawResponse: response,
    );
  }

  /// Maps PayFort response code to PaymentStatus enum
  PaymentStatus _getPaymentStatus(String responseCode) {
    // Success codes
    if (responseCode == '14000' || responseCode == '14' || responseCode == '02000') {
      return PaymentStatus.success;
    }
    // Failure codes
    else if (responseCode.startsWith('2') || responseCode.startsWith('00')) {
      return PaymentStatus.failure;
    }
    // Canceled by user
    else if (responseCode == '00072') {
      return PaymentStatus.canceled;
    }
    // Processing or pending
    else if (responseCode.startsWith('20')) {
      return PaymentStatus.processing;
    }
    // Unknown
    else {
      return PaymentStatus.unknown;
    }
  }
}

/// Internal WebView implementation for PayFort payment page
class _PayFortWebView extends StatefulWidget {
  final String htmlContent;
  final Function(Map<String, dynamic>) responseHandler;

  const _PayFortWebView({
    required this.htmlContent,
    required this.responseHandler,
  });

  @override
  _PayFortWebViewState createState() => _PayFortWebViewState();
}

class _PayFortWebViewState extends State<_PayFortWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onUrlChange: (UrlChange change) {
            _handleUrlChange(change.url ?? '');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_handleUrlChange(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(widget.htmlContent);
  }

  bool _handleUrlChange(String url) {
    // Check if URL is our return URL
    if (url.startsWith('http://payfort.return')) {
      // Extract query parameters from URL
      final uri = Uri.parse(url);
      final responseData = uri.queryParameters;

      // Convert response data to map
      final Map<String, dynamic> response = {};
      responseData.forEach((key, value) {
        response[key] = value;
      });

      // Call response handler with data
      widget.responseHandler(response);

      // Close WebView
      Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Handle user closing the payment page
            final response = <String, dynamic>{
              'response_code': '00072', // User canceled
              'response_message': 'Payment canceled by user',
            };
            widget.responseHandler(response);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}


/// TODO: Integration and Usage example (Need to remove in production)
/*
*
* # PayFort Integration Guide for Flutter

This guide provides instructions for integrating PayFort payment gateway with your Flutter application, including the necessary platform-specific configurations.

## Setup Instructions

### 1. Dependencies Required

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.0.0  # Use the latest version
  crypto: ^3.0.2  # For SHA-256 hash generation
```

Run `flutter pub get` to install the dependencies.

### 2. Android Configuration

#### Update AndroidManifest.xml

Add internet permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.your_app">

    <!-- Add Internet Permission -->
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="YourApp"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">  <!-- Enable cleartext traffic for testing -->

        <!-- Rest of your application configuration -->

    </application>
</manifest>
```

#### Update Network Security Configuration (Android 9+)

For Android 9 (API level 28) and above, create a network security configuration file at `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">payfort.com</domain>
        <domain includeSubdomains="true">sbcheckout.payfort.com</domain>
        <domain includeSubdomains="true">checkout.payfort.com</domain>
    </domain-config>
</network-security-config>
```

Then reference this file in your `AndroidManifest.xml`:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

#### Update build.gradle

Ensure your `android/app/build.gradle` has the correct minSdkVersion:

```gradle
android {
    defaultConfig {
        minSdkVersion 19  // WebView requires API 19 or higher
        // other config
    }
}
```

### 3. iOS Configuration

#### Update Info.plist

Open your `ios/Runner/Info.plist` file and add the following:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>payfort.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
        <key>sbcheckout.payfort.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
        <key>checkout.payfort.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

#### Update Podfile

Make sure your `ios/Podfile` has minimum deployment target of iOS 9.0:

```ruby
platform :ios, '9.0'
```

### 4. PayFort Configuration Requirements

You need to obtain the following details from your PayFort merchant account:

1. Merchant Identifier
2. Access Code
3. SHA Request Phrase (for request signature calculation)
4. SHA Response Phrase (for response signature validation)

These values are required to initialize the `PayFortConfig` object in your code.

## Testing

1. Use sandbox credentials during development
2. Test with small amounts before going live
3. Verify the response signatures to ensure payment security

## Troubleshooting

### Common Issues:

1. **WebView not loading**: Ensure internet permissions are properly set up in both Android and iOS configurations.

2. **Signature validation failing**: Double-check that you're using the correct SHA phrases and that your signature calculation method matches PayFort's requirements.

3. **Redirect not working**: Ensure your return URL matches exactly what's expected in the webview intercept logic.

4. **3D Secure not working**: PayFort handles 3D Secure automatically through the payment page. No additional configuration is needed.

5. **SSL Certificate issues**: Make sure your app trusts PayFort domains in the security configurations.

## Going Live

When ready to switch to production:

1. Change the `isLive` parameter to `true` in your PayFortConfig
2. Replace sandbox credentials with production credentials
3. Perform comprehensive testing with real cards
4. Monitor transactions in your PayFort merchant dashboard
*
*
* *************************************************************************************************
*
*  Usage Example:
*
* import 'package:flutter/material.dart';
import 'package:flutter_payfort_example/payfort_payment_service.dart'; // Import the service

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Payment status message
  String _paymentStatusMessage = '';
  bool _isLoading = false;

  // Create PayFort configuration
  final _payfortConfig = PayFortConfig(
    merchantIdentifier: 'YOUR_MERCHANT_ID',
    accessCode: 'YOUR_ACCESS_CODE',
    shaRequestPhrase: 'YOUR_SHA_REQUEST_PHRASE',
    shaResponsePhrase: 'YOUR_SHA_RESPONSE_PHRASE',
    isLive: false, // Set to true for production
  );

  // Initialize payment service
  late final PayFortPaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PayFortPaymentService(config: _payfortConfig);
  }

  // Process payment
  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
      _paymentStatusMessage = '';
    });

    try {
      // Create payment data
      final paymentData = PayFortPaymentData(
        merchantReference: 'order_${DateTime.now().millisecondsSinceEpoch}', // Generate unique reference
        customerEmail: 'customer@example.com',
        customerName: 'John Doe',
        currency: 'USD', // Change as needed
        amount: 10.00, // Amount to charge
      );

      // Process payment
      final response = await _paymentService.processPayment(context, paymentData);

      // Handle payment response
      setState(() {
        switch (response.status) {
          case PaymentStatus.success:
            _paymentStatusMessage = 'Payment successful! Transaction ID: ${response.transactionId}';
            break;
          case PaymentStatus.failure:
            _paymentStatusMessage = 'Payment failed: ${response.responseMessage}';
            break;
          case PaymentStatus.canceled:
            _paymentStatusMessage = 'Payment was canceled.';
            break;
          case PaymentStatus.processing:
            _paymentStatusMessage = 'Payment is being processed.';
            break;
          case PaymentStatus.unknown:
            _paymentStatusMessage = 'Unknown payment status.';
            break;
        }
      });

      // For debugging - print full response
      print('Payment response: $response');
      print('Raw response: ${response.rawResponse}');
    } catch (e) {
      setState(() {
        _paymentStatusMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayFort Payment Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Payment button
              ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Pay \$10.00'),
              ),
              const SizedBox(height: 20),

              // Payment status message
              if (_paymentStatusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _paymentStatusMessage.contains('successful')
                        ? Colors.green.withOpacity(0.1)
                        : _paymentStatusMessage.contains('failed') || _paymentStatusMessage.contains('Error')
                            ? Colors.red.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _paymentStatusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _paymentStatusMessage.contains('successful')
                          ? Colors.green
                          : _paymentStatusMessage.contains('failed') || _paymentStatusMessage.contains('Error')
                              ? Colors.red
                              : Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
*
*
*
*
*
*
* */