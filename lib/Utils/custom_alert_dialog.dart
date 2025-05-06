import 'package:flutter/material.dart';

enum AlertType { success, error, information }

class CustomAlertDialog extends StatelessWidget {
  final String _title;
  final String _description;
  final String? _cancelBtnText;
  final String _okayBtnText;
  final AlertType? _alertType;

  const CustomAlertDialog(
      {required String title,
      required String description,
      required String okayBtnText,
      AlertType? alertType,
      String? cancelBtnText,
      super.key})
      : _title = title,
        _description = description,
        _okayBtnText = okayBtnText,
        _alertType = alertType,
        _cancelBtnText = cancelBtnText;

  @override
  Widget build(BuildContext context) {
    Icon? alertIcon;
    if (_alertType != null) {
      if (_alertType == AlertType.success) {
        alertIcon = const Icon(Icons.delete);
      } else if (_alertType == AlertType.error) {
        alertIcon = const Icon(Icons.error);
      } else if (_alertType == AlertType.information) {
        alertIcon = const Icon(Icons.info);
      }
    }

    return AlertDialog(
      icon: alertIcon,
      title: Text(_title),
      content: Text(_description),
      actions: [
        if (_cancelBtnText != null && _cancelBtnText != '')
          TextButton(
              onPressed: () {
                Navigator.pop(context, "No");
              },
              child: Text(_cancelBtnText)),
        TextButton(
            onPressed: () {
              Navigator.pop(context, "Yes");
            },
            child: Text(_okayBtnText))
      ],
    );
  }
}
