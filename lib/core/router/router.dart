import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nestle_waters_purelife/core/router/layout_scaffold.dart';
import 'package:nestle_waters_purelife/core/router/routes.dart';
import 'package:nestle_waters_purelife/features/account/presentation/screens/account_screen.dart';
import 'package:nestle_waters_purelife/features/auth/Signup1/screens/signupScreen1.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/screens/signup_screen.dart';
import 'package:nestle_waters_purelife/features/cart/presentation/screens/cart_screen.dart';
import 'package:nestle_waters_purelife/features/home/presentation/screens/home_screen.dart';
import 'package:nestle_waters_purelife/features/subscription/presentation/screens/subsription_screen.dart';
import 'package:nestle_waters_purelife/intro_screen.dart';
import 'package:nestle_waters_purelife/splash_screen.dart';

class Router {

  const Router._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>(
      debugLabel: 'root');


  // Define router
  static final List<RouteBase> routes = [
    GoRoute(
      name: Routes.splash,
      path: Routes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: Routes.intro,
      path: Routes.introScreen,
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      name: Routes.signup,
      path: Routes.signupScreen,
      builder: (context, state) => const SignupScreen(),
    ),
    //Create the testing Demo
    GoRoute(
      name: Routes.signup1,
      path: Routes.signupScreen1,
      builder: (context, state) =>  SignupScreen1(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          LayoutScaffold(
            navigationShell: navigationShell,
          ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: Routes.home,
              path: Routes.homeScreen,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: Routes.subscription,
              path: Routes.subscriptionScreen,
              builder: (context, state) => const SubscriptionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: Routes.cart,
              path: Routes.cartScreen,
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: Routes.account,
              path: Routes.accountScreen,
              builder: (context, state) => const AccountScreen(),
              /// TODO: Example usage of nested screens (Need to update once start working on it)
              /*routes: [
                GoRoute(
                    path: Routes.profileScreen,
                    builder: (context, state) =>
                        ProfileScreen(
                          user: state.extra as User,
                        )
                ),
              ],*/
            ),
          ],
        ),
      ],
    ),
  ];

  // Create GoRouter instance
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.signupScreen1,
      routes: routes,
      // Add your global redirect logic here if needed
      // redirect: (context, state) { ... },
    );
  }
}
