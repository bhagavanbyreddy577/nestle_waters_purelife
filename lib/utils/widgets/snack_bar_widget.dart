import 'package:flutter/material.dart';

class NSnackbarWidget {
  final String displayMessage;
  final String? actionBtnText;
  final Function? callbackFunction;
  const NSnackbarWidget(
      {required this.displayMessage,
      this.actionBtnText,
      this.callbackFunction});

  void showSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(displayMessage),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 10000),
      action: SnackBarAction(
        label: actionBtnText ?? '',
        onPressed: () {
          hideSnackbar(context);
          if (callbackFunction != null) {
            callbackFunction!();
          }
        },
      ),
    );
    hideSnackbar(context);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void hideSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
