import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

/// Exception class for payment service related errors
class PaymentServiceException implements Exception {
  final String message;
  final dynamic error;

  PaymentServiceException(this.message, [this.error]);

  @override
  String toString() => 'PaymentServiceException: $message${error != null ? ' ($error)' : ''}';
}

/// A comprehensive payment service class that handles Google Pay and Apple Pay
/// transactions using the 'pay' package.
class WalletPaymentService {
  // Singleton instance
  static WalletPaymentService? _instance;

  // Payment configuration
  late Map<String, dynamic> _paymentProfile;
  late List<PaymentItem> _paymentItems;

  // Payment controllers
  GooglePayButton? _googlePayButton;
  ApplePayButton? _applePayButton;
  late Pay payClient;

  // Callback handlers
  Function(Map<String, dynamic>)? _onPaymentSuccess;
  Function(Object)? _onPaymentError;

  /// Private constructor for singleton pattern
  WalletPaymentService._internal();

  /// Factory constructor to return the singleton instance
  factory WalletPaymentService() {
    _instance ??= WalletPaymentService._internal();
    return _instance!;
  }

  /// Initialize the payment service with required configuration
  ///
  /// Parameters:
  /// - [paymentProfile]: Configuration map for payment methods
  /// - [paymentItems]: List of items to be purchased
  /// - [onPaymentSuccess]: Callback function when payment succeeds
  /// - [onPaymentError]: Callback function when payment fails
  void initialize({
    required Map<String, dynamic> paymentProfile,
    required List<PaymentItem> paymentItems,
    Function(Map<String, dynamic>)? onPaymentSuccess,
    Function(Object)? onPaymentError,
  }) {
    _paymentProfile = paymentProfile;
    _paymentItems = paymentItems;
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;

    payClient = Pay({
      PayProvider.google_pay: PaymentConfiguration.fromJsonString(
          _getConfigJson(PaymentType.googlePay)),
      PayProvider.apple_pay: PaymentConfiguration.fromJsonString(
          _getConfigJson(PaymentType.applePay)),
    });

    _initializeControllers();

    if (kDebugMode) {
      print('Payment Service initialized successfully');
    }
  }

  /// Internal method to initialize payment controllers based on platform
  void _initializeControllers() {
    try {
      if (Platform.isAndroid) {
        _googlePayButton = GooglePayButton(
          paymentConfiguration: PaymentConfiguration.fromJsonString(
            _getConfigJson(PaymentType.googlePay),
          ),
          paymentItems: _paymentItems,
          type: GooglePayButtonType.pay,
          margin: const EdgeInsets.only(top: 15.0),
          onPaymentResult: _handlePaymentSuccess,
          loadingIndicator: const Center(
            child: CircularProgressIndicator(),
          ),
          onError: _handlePaymentError,
        );
      } else if (Platform.isIOS) {
        _applePayButton = ApplePayButton(
          paymentConfiguration: PaymentConfiguration.fromJsonString(
            _getConfigJson(PaymentType.applePay),
          ),
          paymentItems: _paymentItems,
          style: ApplePayButtonStyle.black,
          type: ApplePayButtonType.buy,
          margin: const EdgeInsets.only(top: 15.0),
          onPaymentResult: _handlePaymentSuccess,
          loadingIndicator: const Center(
            child: CircularProgressIndicator(),
          ),
          onError: _handlePaymentError,
        );
      } else {
        if (kDebugMode) {
          print('Platform not supported: ${Platform.operatingSystem}');
        }
      }
    } catch (e) {
      throw PaymentServiceException('Failed to initialize payment controllers', e);
    }
  }

  /// Get appropriate payment configuration JSON based on payment type
  String _getConfigJson(PaymentType type) {
    try {
      if (!_paymentProfile.containsKey(type.name)) {
        throw PaymentServiceException('Payment profile missing configuration for ${type.name}');
      }
      return _paymentProfile[type.name];
    } catch (e) {
      throw PaymentServiceException('Failed to get configuration JSON', e);
    }
  }

  /// Handle successful payment result
  void _handlePaymentSuccess(Map<String, dynamic> paymentResult) {
    try {
      if (kDebugMode) {
        print('Payment completed successfully: $paymentResult');
      }

      if (_onPaymentSuccess != null) {
        _onPaymentSuccess!(paymentResult);
      }
    } catch (e) {
      throw PaymentServiceException('Error handling payment success', e);
    }
  }

  /// Handle payment error
  void _handlePaymentError(Object? error) {
    try {
      if (kDebugMode) {
        print('Payment failed: $error');
      }

      if (_onPaymentError != null && error != null) {
        _onPaymentError!(error);
      }
    } catch (e) {
      throw PaymentServiceException('Error handling payment failure', e);
    }
  }

  /// Get the appropriate payment button based on platform
  Widget getPaymentButton() {
    _validateInitialization();

    if (Platform.isAndroid) {
      return _googlePayButton ?? const SizedBox.shrink();
    } else if (Platform.isIOS) {
      return _applePayButton ?? const SizedBox.shrink();
    } else {
      throw PaymentServiceException('Platform not supported: ${Platform.operatingSystem}');
    }
  }

  /// Check if Google Pay is available on the device
  ///
  /// Returns a Future that completes with a boolean indicating availability
  Future<bool> isGooglePayAvailable() async {
    try {
      if (!Platform.isAndroid) {
        return false;
      }

      final googlePayIsAvailable = payClient.userCanPay(PayProvider.google_pay);

      if (kDebugMode) {
        print('Google Pay available: $googlePayIsAvailable');
      }

      return googlePayIsAvailable;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Google Pay availability: $e');
      }
      return false;
    }
  }

  /// Check if Apple Pay is available on the device
  ///
  /// Returns a Future that completes with a boolean indicating availability
  Future<bool> isApplePayAvailable() async {
    try {
      if (!Platform.isIOS) {
        return false;
      }

      final applePayIsAvailable =  payClient.userCanPay(PayProvider.apple_pay);

      if (kDebugMode) {
        print('Apple Pay available: $applePayIsAvailable');
      }

      return applePayIsAvailable;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Apple Pay availability: $e');
      }
      return false;
    }
  }

  /// Update payment items after initialization
  ///
  /// Parameters:
  /// - [newItems]: New list of payment items
  void updatePaymentItems(List<PaymentItem> newItems) {
    try {
      _validateInitialization();
      _paymentItems = newItems;

      // Re-initialize controllers with new items
      _initializeControllers();

      if (kDebugMode) {
        print('Payment items updated successfully');
      }
    } catch (e) {
      throw PaymentServiceException('Failed to update payment items', e);
    }
  }

  /// Validates that the service has been initialized before use
  void _validateInitialization() {
    if (_paymentProfile.isEmpty) {
      throw PaymentServiceException('Payment Service not initialized. Call initialize() first.');
    }
  }
}

/// Enum representing different payment types
enum PaymentType {
  googlePay,
  applePay
}


/// TODO: Usage example (Need to remove in production
/*
*
* import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'path_to_payment_service.dart'; // Replace with actual path to your payment service

class PaymentExample extends StatefulWidget {
  const PaymentExample({Key? key}) : super(key: key);

  @override
  State<PaymentExample> createState() => _PaymentExampleState();
}

class _PaymentExampleState extends State<PaymentExample> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  String _statusMessage = 'Checking payment methods...';
  bool _googlePayAvailable = false;
  bool _applePayAvailable = false;

  // Product information
  final String _productName = 'Premium Subscription';
  final double _productPrice = 9.99;

  @override
  void initState() {
    super.initState();
    _checkPaymentAvailability();
  }

  // Check which payment methods are available on the device
  Future<void> _checkPaymentAvailability() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking payment methods...';
    });

    try {
      // Check for Google Pay
      _googlePayAvailable = await _paymentService.isGooglePayAvailable();

      // Check for Apple Pay
      _applePayAvailable = await _paymentService.isApplePayAvailable();

      if (!_googlePayAvailable && !_applePayAvailable) {
        setState(() {
          _statusMessage = 'No supported payment methods available on this device';
        });
      } else {
        _initializePaymentService();
        setState(() {
          _statusMessage = 'Ready to process payment';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking payment methods: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Initialize the payment service with required configuration
  void _initializePaymentService() {
    try {
      // Create payment items
      final List<PaymentItem> paymentItems = [
        PaymentItem(
          label: _productName,
          amount: _productPrice.toString(),
          status: PaymentItemStatus.final_price,
        ),
      ];

      // Payment profiles for Google Pay and Apple Pay
      // These are simplified examples - you'll need to replace with actual configurations
      final Map<String, dynamic> paymentProfiles = {
        PaymentType.googlePay.name: _getGooglePayConfig(),
        PaymentType.applePay.name: _getApplePayConfig(),
      };

      // Initialize payment service
      _paymentService.initialize(
        paymentProfile: paymentProfiles,
        paymentItems: paymentItems,
        onPaymentSuccess: _onPaymentSuccess,
        onPaymentError: _onPaymentError,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing payment service: $e';
      });
    }
  }

  // Handle successful payment
  void _onPaymentSuccess(Map<String, dynamic> result) {
    setState(() {
      _statusMessage = 'Payment successful!';
    });

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text('Your payment was processed successfully.'),
              const SizedBox(height: 20),
              Text('Transaction ID: ${result['transactionId'] ?? 'Unknown'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // Handle payment error
  void _onPaymentError(Object error) {
    setState(() {
      _statusMessage = 'Payment failed: ${error.toString()}';
    });

    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text('There was an error processing your payment.\n\n${error.toString()}'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // This is a simplified example Google Pay configuration
  // Replace with your actual configuration
  String _getGooglePayConfig() {
    return '''
    {
      "provider": "google_pay",
      "data": {
        "environment": "TEST",
        "apiVersion": 2,
        "apiVersionMinor": 0,
        "allowedPaymentMethods": [
          {
            "type": "CARD",
            "tokenizationSpecification": {
              "type": "PAYMENT_GATEWAY",
              "parameters": {
                "gateway": "example",
                "gatewayMerchantId": "exampleGatewayMerchantId"
              }
            },
            "parameters": {
              "allowedCardNetworks": ["VISA", "MASTERCARD"],
              "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
              "billingAddressRequired": true,
              "billingAddressParameters": {
                "format": "FULL",
                "phoneNumberRequired": true
              }
            }
          }
        ],
        "merchantInfo": {
          "merchantId": "YOUR_MERCHANT_ID_HERE",
          "merchantName": "Your Company Name"
        },
        "transactionInfo": {
          "currencyCode": "USD",
          "countryCode": "US"
        }
      }
    }
    ''';
  }

  // This is a simplified example Apple Pay configuration
  // Replace with your actual configuration
  String _getApplePayConfig() {
    return '''
    {
      "provider": "apple_pay",
      "data": {
        "merchantIdentifier": "merchant.com.your.app",
        "displayName": "Your Company Name",
        "merchantCapabilities": ["3DS", "debit", "credit"],
        "supportedNetworks": ["visa", "masterCard", "amex", "discover"],
        "countryCode": "US",
        "currencyCode": "USD"
      }
    }
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _productName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Price: \$${_productPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Get access to premium features with our subscription plan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status message
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.contains('Error') || _statusMessage.contains('No supported')
                    ? Colors.red
                    : _statusMessage.contains('successful')
                        ? Colors.green
                        : Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Loading indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_googlePayAvailable || _applePayAvailable)
              // Payment button from service
              SizedBox(
                height: 50,
                child: _paymentService.getPaymentButton(),
              ),

            const SizedBox(height: 20),

            // Refresh button
            TextButton.icon(
              onPressed: _checkPaymentAvailability,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Payment Methods'),
            ),
          ],
        ),
      ),
    );
  }
}
*
*
* */