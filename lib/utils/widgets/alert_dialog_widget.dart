import 'package:flutter/material.dart';

enum AlertType { success, error, information }

class NAlertDialogWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? cancelBtnText;
  final String okayBtnText;
  final AlertType? alertType;

  const NAlertDialogWidget(
      {required this.title,
      required this.description,
      required this.okayBtnText,
      this.alertType,
      this.cancelBtnText,
      super.key});

  @override
  Widget build(BuildContext context) {
    Icon? alertIcon;
    if (alertType != null) {
      if (alertType == AlertType.success) {
      } else if (alertType == AlertType.error) {
      } else if (alertType == AlertType.information) {}
    }

    return AlertDialog(
      icon: alertIcon,
      title: Text(title),
      content: Text(description),
      actions: [
        if (cancelBtnText != null && cancelBtnText != '')
          TextButton(
              onPressed: () {
                Navigator.pop(context, "No");
              },
              child: Text(cancelBtnText!)),
        TextButton(
            onPressed: () {
              Navigator.pop(context, "Yes");
            },
            child: Text(okayBtnText))
      ],
    );
  }
}
