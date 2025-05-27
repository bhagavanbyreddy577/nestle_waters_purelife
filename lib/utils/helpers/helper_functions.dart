import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/core/di/app_dependencies.dart';
import 'package:nestle_waters_purelife/core/providers/location_provider/location_provider.dart';
import 'package:nestle_waters_purelife/utils/widgets/alert_dialog.dart';
import 'package:nestle_waters_purelife/utils/widgets/snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class NHelperFunctions {

  /// To show snack bar
  static void showSnackBar(BuildContext context, String message) {
    context.showInfoSnackBar(message);
  }

  /// To show alert dialog
  static void showAlert(BuildContext context, String title, String message) {
    NAlertDialog.show(
      context: context,
      type: AlertDialogType.basic,
      title: title,
      message: message,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  /// To add dots at the end of text if reaches maxLength
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  /// To remove the duplicated in the list
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  /// To get all providers
  static getAllProviders() {
    return [
      ChangeNotifierProvider(
        create: (_) => LocationProvider(),
      ),
    ];
  }

  static Future<void> setupAllDependencies() async {
    // App level dependencies
    await appDependencies();
    // Module level dependencies
  }

  static Future<void> setupHive() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    // Register adapters
  }

  
}