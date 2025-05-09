import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/utils/widgets/alert_dialog.dart';
import 'package:nestle_waters_purelife/utils/widgets/snack_bar.dart';

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

}