import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricAuthHelper {
  final LocalAuthentication _localAuth;

  /// Singleton instance
  static final BiometricAuthHelper _instance = BiometricAuthHelper._internal();

  /// Factory constructor
  factory BiometricAuthHelper() {
    return _instance;
  }

  /// Private constructor
  BiometricAuthHelper._internal() : _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error checking biometric availability: ${e.message}');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: ${e.message}');
      return [];
    }
  }

  /// Check if device has fingerprint
  Future<bool> hasFingerprint() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.fingerprint);
  }

  /// Check if device has face ID
  Future<bool> hasFaceId() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.face);
  }

  /// Check if device has iris scan
  Future<bool> hasIris() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.iris);
  }

  /// Check if any biometric type is available
  Future<bool> hasAnyBiometric() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  /// Authenticate with biometrics
  ///
  /// [localizedReason] is the message displayed to user on the auth dialog
  /// [useErrorDialogs] shows system error dialogs if true
  /// [stickyAuth] prevents the auth dialog from being dismissed when app is inactive
  /// [sensitiveTransaction] will require biometric authentication even if device has no secure lock screen setup
  /// (only works on Android)
  Future<AuthResult> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: false,
        ),
      );

      return AuthResult(
        isSuccess: isAuthenticated,
        errorType: isAuthenticated ? null : AuthErrorType.unknown,
        errorMessage: isAuthenticated ? null : 'Authentication failed',
      );
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorType: AuthErrorType.unknown,
        errorMessage: 'Unknown error: ${e.toString()}',
      );
    }
  }

  /// Authenticate with biometrics only (no PIN/password fallback)
  Future<AuthResult> authenticateWithBiometricsOnly({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      return AuthResult(
        isSuccess: isAuthenticated,
        errorType: isAuthenticated ? null : AuthErrorType.unknown,
        errorMessage: isAuthenticated ? null : 'Biometric authentication failed',
      );
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorType: AuthErrorType.unknown,
        errorMessage: 'Unknown error: ${e.toString()}',
      );
    }
  }

  /// Handle platform exceptions and convert them to AuthResult
  AuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        return AuthResult(
          isSuccess: false,
          errorType: AuthErrorType.notAvailable,
          errorMessage: 'Biometric authentication not available',
        );
      case auth_error.notEnrolled:
        return AuthResult(
          isSuccess: false,
          errorType: AuthErrorType.notEnrolled,
          errorMessage: 'No biometrics enrolled on this device',
        );
      case auth_error.lockedOut:
        return AuthResult(
          isSuccess: false,
          errorType: AuthErrorType.lockedOut,
          errorMessage: 'Biometric authentication is locked out due to too many attempts',
        );
      case auth_error.permanentlyLockedOut:
        return AuthResult(
          isSuccess: false,
          errorType: AuthErrorType.permanentlyLockedOut,
          errorMessage: 'Biometric authentication is permanently locked on this device',
        );
      case auth_error.passcodeNotSet:
        return AuthResult(
          isSuccess: false,
          errorType: AuthErrorType.passcodeNotSet,
          errorMessage: 'Device does not have a secure lock screen setup',
        );
      case auth_error.otherOperatingSystem:
        return AuthResult(
          isSuccess: false,
          errorType: AuthErrorType.incompatibleOS,
          errorMessage: 'Biometric authentication not supported on this OS version',
        );
      default:
        return AuthResult(
          isSuccess: false,
          errorType: AuthErrorType.unknown,
          errorMessage: e.message ?? 'Unknown platform error',
        );
    }
  }

  /// Stop authentication if it's in progress
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  /// Check if device is secured with PIN, pattern, or password
  Future<bool> isDeviceSecured() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      print('Error checking if device is secured: ${e.message}');
      return false;
    }
  }
}

/// Custom error types for easier handling
enum AuthErrorType {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  passcodeNotSet,
  incompatibleOS,
  unknown,
}

/// Result class for authentication attempts
class AuthResult {
  final bool isSuccess;
  final AuthErrorType? errorType;
  final String? errorMessage;

  AuthResult({
    required this.isSuccess,
    this.errorType,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, errorType: $errorType, errorMessage: $errorMessage)';
  }
}

// TODO: Usage example (Need to remove in production
/*
Future<void> _authenticateWithBiometrics() async {
  setState(() {
    _isBusy = true;
    _status = 'Authenticating...';
  });

  final AuthResult result = await _authHelper.authenticate(
    localizedReason: 'Authenticate to access the app',
    useErrorDialogs: true,
    stickyAuth: true,
  );

  if (mounted) {
    setState(() {
      _status = result.isSuccess
          ? 'Authentication successful!'
          : 'Authentication failed: ${result.errorMessage}';
      _isBusy = false;
    });
  }
}

Future<void> _authenticateWithBiometricsOnly() async {
  setState(() {
    _isBusy = true;
    _status = 'Authenticating with biometrics only...';
  });

  final AuthResult result = await _authHelper.authenticateWithBiometricsOnly(
    localizedReason: 'Authenticate with biometrics only',
  );

  if (mounted) {
    setState(() {
      _status = result.isSuccess
          ? 'Biometric authentication successful!'
          : 'Biometric authentication failed: ${result.errorMessage}';
      _isBusy = false;
    });
  }
}*/
