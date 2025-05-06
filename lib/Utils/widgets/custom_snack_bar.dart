import 'package:flutter/material.dart';

class CustomSnackbar {
  final String _displayMessage;
  final String? _actionBtnText;
  final Function? _callbackFunction;
  const CustomSnackbar(
      {required String displayMessage,
      String? actionBtnText,
      Function? callbackMethod})
      : _displayMessage = displayMessage,
        _actionBtnText = actionBtnText,
        _callbackFunction = callbackMethod;

  void showSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(_displayMessage),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 10000),
      action: SnackBarAction(
        label: _actionBtnText ?? '',
        onPressed: () {
          hideSnackbar(context);
          if (_callbackFunction != null) {
            _callbackFunction();
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
