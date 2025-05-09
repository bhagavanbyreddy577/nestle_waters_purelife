import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Utility class to handle navigation actions
class NavigationHelper {

  const NavigationHelper._();

  /// Navigate to a screen using its name
  static void navigateScreen(
      BuildContext context,
      String routeName, {
        Map<String, String> pathParameters = const <String, String>{},
        Map<String, dynamic> queryParameters = const <String, dynamic>{},
        Object? extra,
      }) {
    context.goNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Push a new screen using its name
  static void pushScreen(
      BuildContext context,
      String routeName, {
        Map<String, String> pathParameters = const <String, String>{},
        Map<String, dynamic> queryParameters = const <String, dynamic>{},
        Object? extra,
      }) {
    context.pushNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Replace current screen with a new one using its name
  static void replaceScreen(
      BuildContext context,
      String routeName, {
        Map<String, String> pathParameters = const <String, String>{},
        Map<String, dynamic> queryParameters = const <String, dynamic>{},
        Object? extra,
      }) {
    context.replaceNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Pop the current screen
  static void popScreen<T extends Object?>(BuildContext context, [T? result]) {
    context.pop(result);
  }

  /// Pop all screens until the root and then navigate to a new screen
  static void popAllAndNavigate(BuildContext context, String routeName, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    final router = GoRouter.of(context);

    // Navigate to the destination
    router.goNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );

    // Clear the navigation stack
    while (router.canPop()) {
      router.pop();
    }
  }
}