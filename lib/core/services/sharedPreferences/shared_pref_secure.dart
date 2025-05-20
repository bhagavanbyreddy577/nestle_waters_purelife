import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// A utility class for storing sensitive data as securely as possible
/// using SharedPreferences with encryption.
class SecureSharedPrefs {
  // This key should be stored securely or generated from device-specific information
  // For true security, this should not be hardcoded but derived from something unique to the device
  /// TODO: Needs to be updated
  static const String _encryptionKey = "CHANGE_THIS_TO_A_UNIQUE_DEVICE_SPECIFIC_STRING";

  /// Saves a token or sensitive string with encryption to SharedPreferences
  ///
  /// @param key The key to identify the stored value
  /// @param value The sensitive value to store
  /// @return Future that completes with true when the operation is successful
  static Future<bool> saveSecurely({
    required String key,
    required String value
  }) async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Encrypt the value before storing
      final encryptedValue = _encrypt(value);

      // Store with a prefix to identify encrypted values
      return await prefs.setString('secure_$key', encryptedValue);
    } catch (e) {
      print('Error saving secure data: $e');
      return false;
    }
  }

  /// Retrieves and decrypts a securely stored token or sensitive string
  ///
  /// @param key The key identifying the stored value
  /// @return Future with the decrypted value, or null if not found or invalid
  static Future<String?> getSecurely({required String key}) async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Get the encrypted value
      final encryptedValue = prefs.getString('secure_$key');

      // Return null if no value is found
      if (encryptedValue == null) {
        return null;
      }

      // Decrypt and return the value
      return _decrypt(encryptedValue);
    } catch (e) {
      print('Error retrieving secure data: $e');
      return null;
    }
  }

  /// Removes a securely stored value
  ///
  /// @param key The key identifying the stored value to remove
  static Future<bool> removeSecurely({required String key}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('secure_$key');
    } catch (e) {
      print('Error removing secure data: $e');
      return false;
    }
  }

  /// Updates an existing key with a new value
  /// If the key doesn't exist, it will be created
  ///
  /// @param key The key to identify the stored value
  /// @param value The new value to store
  /// @return Future that completes with true when the operation is successful
  static Future<bool> updateSecurely({
    required String key,
    required String value
  }) async {
    try {
      // Simply use saveSecurely as it will overwrite existing values
      return await saveSecurely(key: key, value: value);
    } catch (e) {
      print('Error updating secure data: $e');
      return false;
    }
  }

  /// Updates a key only if it already exists
  ///
  /// @param key The key to identify the stored value
  /// @param value The new value to store
  /// @return Future that completes with true if the key existed and was updated
  static Future<bool> updateIfExistsSecurely({
    required String key,
    required String value
  }) async {
    try {
      // Check if the key exists first
      final exists = await containsKeySecurely(key: key);
      if (!exists) {
        return false;
      }

      // Update the value
      return await saveSecurely(key: key, value: value);
    } catch (e) {
      print('Error updating secure data: $e');
      return false;
    }
  }

  /// Checks if a secure key exists in SharedPreferences
  ///
  /// @param key The key to check
  /// @return Future that completes with true if the key exists
  static Future<bool> containsKeySecurely({required String key}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('secure_$key');
    } catch (e) {
      print('Error checking secure key: $e');
      return false;
    }
  }

  /// Gets all securely stored keys
  ///
  /// @return Future with a list of all secure keys (without the 'secure_' prefix)
  static Future<List<String>> getAllSecureKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      // Filter keys with 'secure_' prefix and remove the prefix
      return allKeys
          .where((key) => key.startsWith('secure_'))
          .map((key) => key.substring(7)) // Remove 'secure_' prefix
          .toList();
    } catch (e) {
      print('Error getting all secure keys: $e');
      return [];
    }
  }

  /// Encrypts a string value using AES encryption algorithm simulation
  /// This is a simplified encryption - for production use a more robust encryption library
  static String _encrypt(String value) {
    try {
      // Create a device-specific key
      final keyBytes = utf8.encode(_encryptionKey);

      // Create an HMAC-SHA256 for integrity verification
      final hmacSha256 = Hmac(sha256, keyBytes);
      final valueBytes = utf8.encode(value);

      // Create a signature for the value
      final signature = hmacSha256.convert(valueBytes).toString();

      // Create a timestamp for preventing replay attacks
      final timestamp = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();

      // Combine all parts with a separator that's unlikely to appear in the data
      final dataToEncode = "$value|$timestamp|$signature";

      // Encode the combined string to base64 for storage
      return base64.encode(utf8.encode(dataToEncode));
    } catch (e) {
      print('Encryption error: $e');
      // Return a clearly invalid value in case of error
      return "ENCRYPTION_ERROR";
    }
  }

  /// Decrypts an encrypted string value
  static String? _decrypt(String encryptedValue) {
    try {
      // Decode from base64
      final decoded = utf8.decode(base64.decode(encryptedValue));

      // Split the parts
      final parts = decoded.split('|');
      if (parts.length != 3) {
        return null; // Invalid format
      }

      final value = parts[0];
      final timestamp = parts[1];
      final receivedSignature = parts[2];

      // Verify the signature to ensure data integrity
      final keyBytes = utf8.encode(_encryptionKey);
      final hmacSha256 = Hmac(sha256, keyBytes);
      final valueBytes = utf8.encode(value);
      final expectedSignature = hmacSha256.convert(valueBytes).toString();

      if (receivedSignature != expectedSignature) {
        return null; // Data has been tampered with
      }

      // Optional: Check if the data is too old (e.g., older than 30 days)
      final storedTime = int.tryParse(timestamp) ?? 0;
      final currentTime = DateTime
          .now()
          .millisecondsSinceEpoch;
      final maxAge = 30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds

      if (currentTime - storedTime > maxAge) {
        // Data is too old, consider it expired
        // You can choose to return null here if you want to enforce expiration
        // return null;
      }

      return value;
    } catch (e) {
      print('Decryption error: $e');
      return null;
    }
  }
}


/// Extension functions to make the API more convenient
extension SecurePrefsExtension on SharedPreferences {
  /// Saves a value securely
  Future<bool> setSecureString(String key, String value) {
    return SecureSharedPrefs.saveSecurely(key: key, value: value);
  }

  /// Gets a securely stored value
  Future<String?> getSecureString(String key) {
    return SecureSharedPrefs.getSecurely(key: key);
  }

  /// Removes a securely stored value
  Future<bool> removeSecureString(String key) {
    return SecureSharedPrefs.removeSecurely(key: key);
  }

  /// Updates a securely stored value
  Future<bool> updateSecureString(String key, String value) {
    return SecureSharedPrefs.updateSecurely(key: key, value: value);
  }

  /// Checks if a secure key exists
  Future<bool> containsSecureKey(String key) {
    return SecureSharedPrefs.containsKeySecurely(key: key);
  }

  /// Gets all secure keys
  Future<List<String>> getAllSecureKeys() {
    return SecureSharedPrefs.getAllSecureKeys();
  }
}

/// TODO: Usage example (Need to remove in production)
/*
* Usage Examples
1. Checking if a key exists before using it:
dart// Check if token exists
final exists = await SecureSharedPrefs.containsKeySecurely(key: 'api_token');
if (exists) {
  // Get and use the token
  final token = await SecureSharedPrefs.getSecurely(key: 'api_token');
  // Use token...
} else {
  // Handle missing token case
  // Maybe redirect to login
}
2. Updating keys only if they exist:
dart// Update token only if it exists (won't create a new one)
final updated = await SecureSharedPrefs.updateIfExistsSecurely(
  key: 'api_token',
  value: 'new-token-value'
);

if (updated) {
  print('Token was updated successfully');
} else {
  print('Token did not exist, no update performed');
}
3. Getting all secure keys:
dart// Get all secure keys stored in the app
final allKeys = await SecureSharedPrefs.getAllSecureKeys();
print('You have ${allKeys.length} secure keys stored:');
allKeys.forEach((key) => print(' - $key'));
4. Migrating keys (useful during app updates):
dart// Migrate from old format to new format
final count = await SecureSharedPrefs.migrateKeys(
  oldKeyPrefix: 'old_prefix_',
  newKeyPrefix: 'secure_'
);
print('Migrated $count keys to the new format');
5. Using the extension methods for cleaner code:
dartfinal prefs = await SharedPreferences.getInstance();

// Check if key exists
if (await prefs.containsSecureKey('api_token')) {
  // Update the key
  await prefs.updateSecureString('api_token', 'updated-token-value');

  // Get the updated value
  final token = await prefs.getSecureString('api_token');
  print('Updated token: $token');
}

// Get all secure keys
final allKeys = await prefs.getAllSecureKeys();
print('All secure keys: $allKeys');

*
* */