import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NPermissionHelper {
  /// Requests the specified permissions and returns their status
  ///
  /// [permissions] - List of permissions to request
  /// [context] - BuildContext for showing dialogs
  /// [criticalPermissions] - Map of permissions that are critical for app functionality
  ///   with custom messages explaining why they're needed
  ///
  /// Returns a Map<Permission, bool> where:
  /// - Key is the permission
  /// - Value is whether the permission is granted (true) or denied (false)
  static Future<Map<Permission, bool>> requestPermissions({
    required List<Permission> permissions,
    required BuildContext context,
    Map<Permission, String>? criticalPermissions,
  }) async {
    try {
      // Result map to track which permissions are granted
      final Map<Permission, bool> result = {};

      // Check status of all permissions first
      Map<Permission, PermissionStatus> statuses = {};
      for (var permission in permissions) {
        statuses[permission] = await permission.status;
      }

      // Handle permissions that are already determined
      for (var entry in statuses.entries) {
        if (entry.value.isGranted) {
          // Already granted permissions
          result[entry.key] = true;
        } else if (entry.value.isPermanentlyDenied) {
          // Handle permanently denied permissions (user checked "Don't ask again")
          final isRequired = criticalPermissions?.containsKey(entry.key) ?? false;
          if (isRequired) {
            // For critical permissions, show explanation dialog and redirect to settings
            final userOpenedSettings = await _showSettingsDialog(
              context: context,
              permissionName: _getPermissionName(entry.key),
              explanation: criticalPermissions![entry.key] ??
                  "This permission is required for core app functionality.",
            );

            // Check status again after potential settings change
            result[entry.key] = userOpenedSettings ?
            (await entry.key.status).isGranted : false;
          } else {
            // Non-critical permissions that are permanently denied
            result[entry.key] = false;
          }
        }
      }

      // Filter out the permissions that need to be requested
      final permissionsToRequest = permissions.where(
              (permission) => !result.containsKey(permission)
      ).toList();

      // Request remaining permissions
      if (permissionsToRequest.isNotEmpty) {
        // Request each permission individually for more control
        for (var permission in permissionsToRequest) {
          final status = await permission.request();
          result[permission] = status.isGranted;

          // If permission is denied and it's critical, show explanation
          if (!status.isGranted && criticalPermissions?.containsKey(permission) == true) {
            // Only show settings dialog if permanently denied
            if (status.isPermanentlyDenied) {
              final userOpenedSettings = await _showSettingsDialog(
                context: context,
                permissionName: _getPermissionName(permission),
                explanation: criticalPermissions![permission] ??
                    "This permission is required for core app functionality.",
              );

              // Update status if user returns from settings
              if (userOpenedSettings) {
                result[permission] = (await permission.status).isGranted;
              }
            }
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint('PermissionHelper error: $e');

      // Return all permissions as denied in case of error
      return {for (var permission in permissions) permission: false};
    }
  }

  /// Shows a dialog explaining why a permission is needed and provides
  /// a button to open app settings
  ///
  /// Returns whether the user tapped the "Open Settings" button
  static Future<bool> _showSettingsDialog({
    required BuildContext context,
    required String permissionName,
    required String explanation,
  }) async {
    bool userOpenedSettings = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Permission Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(explanation),
                const SizedBox(height: 12),
                const Text(
                  'Please open Settings and grant the permission.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                userOpenedSettings = true;
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return userOpenedSettings;
  }

  /// Gets a user-friendly name for each permission type
  static String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.photos:
        return 'Photos';
      case Permission.storage:
        return 'Storage';
      case Permission.location:
      case Permission.locationAlways:
      case Permission.locationWhenInUse:
        return 'Location';
      case Permission.microphone:
        return 'Microphone';
      case Permission.contacts:
        return 'Contacts';
      case Permission.phone:
        return 'Phone';
      case Permission.sms:
        return 'SMS';
      case Permission.notification:
        return 'Notification';
      case Permission.calendar:
        return 'Calendar';
      case Permission.bluetooth:
        return 'Bluetooth';
      default:
        return permission.toString().split('.').last;
    }
  }

  /// Checks if all specified permissions are granted
  ///
  /// Returns true only if ALL permissions are granted
  static Future<bool> areAllPermissionsGranted(List<Permission> permissions) async {
    for (var permission in permissions) {
      if (!(await permission.status).isGranted) {
        return false;
      }
    }
    return true;
  }

  /// Checks the status of all specified permissions
  ///
  /// Returns a map with each permission and whether it's granted
  static Future<Map<Permission, bool>> checkPermissionStatus(
      List<Permission> permissions
      ) async {
    final Map<Permission, bool> result = {};

    for (var permission in permissions) {
      result[permission] = (await permission.status).isGranted;
    }

    return result;
  }
}