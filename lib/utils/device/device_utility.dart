import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NDeviceUtils {

 /// Keyboard utility functions
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  static void showKeyboard(FocusNode focusNode) {
    focusNode.requestFocus();
  }
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  static void toggleKeyboard(BuildContext context, FocusNode focusNode) {
    if (isKeyboardVisible(context)) {
      hideKeyboard(context);
    } else {
      showKeyboard(focusNode);
    }
  }

  /// MediaQuery utility functions
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  static bool isTablet(BuildContext context) {
    // Get screen size
    Size size = MediaQuery.of(context).size;
    // Calculate diagonal in dp
    double diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    // Use 600dp as the threshold for tablet
    return diagonal >= 600.0;
  }
  static bool isPhone(BuildContext context) {
    return !isTablet(context);
  }
  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 360.0;
  }
  static bool isMediumScreen(BuildContext context) {
    double width = getScreenWidth(context);
    return width >= 360.0 && width < 600.0;
  }
  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 600.0;
  }

  /// Status bar utility functions
  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  /// Network utility functions
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Platform utility functions
  static bool isIOS() {
    return Platform.isIOS;
  }
  static bool isAndroid() {
    return Platform.isAndroid;
  }

}
