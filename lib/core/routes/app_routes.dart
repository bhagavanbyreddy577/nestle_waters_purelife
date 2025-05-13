import 'package:go_router/go_router.dart';
import 'package:nestle_waters_purelife/intro_screen.dart';
import 'package:nestle_waters_purelife/splash_screen.dart';
import 'package:nestle_waters_purelife/temp_page.dart';

class AppRoutes {

  const AppRoutes._();

  // Route names
  static const String splash = 'splash';
  static const String intro = 'intro';
  static const String temp = 'temp';

  // Route paths
  static const String splashPath = '/splash';
  static const String introPath = '/intro';
  static const String tempPath = '/temp';

  // Define routes
  static final List<RouteBase> routes = [
    GoRoute(
      path: splashPath,
      name: splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: introPath,
      name: intro,
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: tempPath,
      name: temp,
      builder: (context, state) => const TempScreen(),
    ),
  ];

  // Create GoRouter instance
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: introPath,
      routes: routes,
      // Add your global redirect logic here if needed
      // redirect: (context, state) { ... },
    );
  }
}
