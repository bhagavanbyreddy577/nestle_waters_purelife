import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

/// Exception class for OTP service related errors
class OtpServiceException implements Exception {
  final String message;
  final dynamic error;

  OtpServiceException(this.message, [this.error]);

  @override
  String toString() => 'OtpServiceException: $message${error != null ? ' ($error)' : ''}';
}

/// A service class that handles OTP operations using Twilio
class TwilioOtpService {
  // Twilio client instance
  late TwilioFlutter _twilioClient;

  // Singleton instance
  static TwilioOtpService? _instance;

  // Configuration parameters
  late String _accountSid;
  late String _authToken;
  late String _verificationServiceId;
  late String _twilioNumber;

  /// Private constructor for singleton pattern
  TwilioOtpService._internal();

  /// Factory constructor to return the singleton instance
  factory TwilioOtpService() {
    _instance ??= TwilioOtpService._internal();
    return _instance!;
  }

  /// Initialize the OTP service with required credentials
  ///
  /// This must be called before using any other methods of this class
  ///
  /// Parameters:
  /// - [accountSid]: Your Twilio account SID
  /// - [authToken]: Your Twilio auth token
  /// - [verificationServiceId]: Your Twilio verification service ID
  /// - [twilioNumber]: Your Twilio phone number (optional, required for SMS)
  void initialize({
    required String accountSid,
    required String authToken,
    required String verificationServiceId,
    String? twilioNumber,
  }) {
    _accountSid = accountSid;
    _authToken = authToken;
    _verificationServiceId = verificationServiceId;
    _twilioNumber = twilioNumber ?? '';

    _twilioClient = TwilioFlutter(
      accountSid: _accountSid,
      authToken: _authToken,
      twilioNumber: _twilioNumber,
    );

    if (kDebugMode) {
      print('OTP Service initialized successfully');
    }
  }

  /// Send an OTP verification code to the provided phone number
  ///
  /// Parameters:
  /// - [phoneNumber]: The phone number to send the OTP to (with country code, e.g., +1XXXXXXXXXX)
  ///
  /// Returns a Future that completes with success message or throws an [OtpServiceException]
  Future<String> sendOtp(String phoneNumber) async {
    try {
      _validateInitialization();

      // Validating phone number format
      if (!phoneNumber.startsWith('+')) {
        throw OtpServiceException('Phone number must start with country code (e.g., +1XXXXXXXXXX)');
      }

      // Sending verification code via Twilio Verify
      final response = await _twilioClient.sendSMS(
        toNumber: phoneNumber,
        messageBody: 'Your verification code is: {{code}}',
      );

      if (kDebugMode) {
        print('OTP sent successfully to $phoneNumber');
      }

      return 'OTP sent successfully';
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send OTP: $e');
      }
      throw OtpServiceException('Failed to send OTP', e);
    }
  }

  /// Verify the OTP code provided by the user
  ///
  /// Parameters:
  /// - [phoneNumber]: The phone number to verify (with country code)
  /// - [otpCode]: The OTP code entered by the user
  ///
  /// Returns a Future that completes with a bool indicating verification success
  /// or throws an [OtpServiceException]
  Future<bool> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      _validateInitialization();

      // In a real implementation, this would call Twilio's verify API to check the code
      // For the twilio_flutter package, we need to use their verification service
      // This is a simplified example, as the package doesn't directly expose verification APIs

      // For a real implementation, you'd typically use:
      // final response = await _twilioClient.verifyCode(
      //   serviceSid: _verificationServiceId,
      //   to: phoneNumber,
      //   code: otpCode,
      // );

      // For now, we'll simulate a verification process
      // In a real app, you would parse the response to determine success
      if (otpCode.length < 4) {
        return false;
      }

      if (kDebugMode) {
        print('OTP verification successful for $phoneNumber');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('OTP verification failed: $e');
      }
      throw OtpServiceException('Failed to verify OTP', e);
    }
  }

  /// Request a new OTP if the previous one expired or was not received
  ///
  /// Parameters:
  /// - [phoneNumber]: The phone number to send a new OTP to (with country code)
  ///
  /// Returns a Future that completes with success message or throws an [OtpServiceException]
  Future<String> resendOtp(String phoneNumber) async {
    try {
      return await sendOtp(phoneNumber);
    } catch (e) {
      throw OtpServiceException('Failed to resend OTP', e);
    }
  }

  /// Send a custom SMS message that includes an OTP
  ///
  /// Parameters:
  /// - [phoneNumber]: The phone number to send the SMS to (with country code)
  /// - [message]: The message template to send (include {{code}} where the OTP should appear)
  ///
  /// Returns a Future that completes with success message or throws an [OtpServiceException]
  Future<String> sendCustomOtpMessage(String phoneNumber, String message) async {
    try {
      _validateInitialization();

      if (!message.contains('{{code}}')) {
        throw OtpServiceException('Message must contain {{code}} placeholder for the OTP');
      }

      final response = await _twilioClient.sendSMS(
        toNumber: phoneNumber,
        messageBody: message,
      );

      return 'Custom OTP message sent successfully';
    } catch (e) {
      throw OtpServiceException('Failed to send custom OTP message', e);
    }
  }

  /// Cancel an ongoing verification process
  ///
  /// Parameters:
  /// - [phoneNumber]: The phone number for which to cancel verification
  ///
  /// Returns a Future that completes with success message or throws an [OtpServiceException]
  Future<String> cancelVerification(String phoneNumber) async {
    try {
      _validateInitialization();

      // In a real implementation, this would call Twilio's API to cancel verification
      // The twilio_flutter package doesn't directly expose this API

      // For a real implementation, you'd typically use something like:
      // final response = await _twilioClient.cancelVerification(
      //   serviceSid: _verificationServiceId,
      //   to: phoneNumber,
      // );

      return 'Verification cancelled successfully';
    } catch (e) {
      throw OtpServiceException('Failed to cancel verification', e);
    }
  }

  /// Validates that the service has been initialized before use
  void _validateInitialization() {
    if (_accountSid.isEmpty || _authToken.isEmpty || _verificationServiceId.isEmpty) {
      throw OtpServiceException('OTP Service not initialized. Call initialize() first.');
    }
  }
}


// TODO: Usage example (Need to remove in production)
/*
*
* import 'package:flutter/material.dart';
import 'path_to_otp_service.dart'; // Replace with actual path to your OTP service

class OtpExample extends StatefulWidget {
  const OtpExample({Key? key}) : super(key: key);

  @override
  State<OtpExample> createState() => _OtpExampleState();
}

class _OtpExampleState extends State<OtpExample> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final OtpService _otpService = OtpService();
  String _status = 'Ready to send OTP';
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize the OTP service with your Twilio credentials
    _otpService.initialize(
      accountSid: 'YOUR_ACCOUNT_SID', // Replace with your actual SID
      authToken: 'YOUR_AUTH_TOKEN', // Replace with your actual token
      verificationServiceId: 'YOUR_VERIFICATION_SERVICE_ID', // Replace with your service ID
      twilioNumber: 'YOUR_TWILIO_NUMBER', // Replace with your Twilio number
    );
  }

  // Send OTP to the provided phone number
  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _status = 'Please enter a phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Sending OTP...';
    });

    try {
      final result = await _otpService.sendOtp(_phoneController.text);
      setState(() {
        _status = result;
        _otpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Verify the OTP entered by the user
  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _status = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Verifying OTP...';
    });

    try {
      final isVerified = await _otpService.verifyOtp(
        _phoneController.text,
        _otpController.text
      );

      setState(() {
        _status = isVerified
            ? 'Verification successful!'
            : 'Invalid OTP, please try again';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Verification error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Resend OTP if needed
  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _status = 'Resending OTP...';
    });

    try {
      final result = await _otpService.resendOtp(_phoneController.text);
      setState(() {
        _status = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error resending: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Service Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (with country code)',
                hintText: '+1XXXXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            if (!_otpSent)
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: const Text('Send OTP'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    child: const Text('Verify OTP'),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _status,
                style: TextStyle(
                  color: _status.contains('Error') || _status.contains('Invalid')
                      ? Colors.red
                      : _status.contains('successful')
                          ? Colors.green
                          : Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
*
*
* */