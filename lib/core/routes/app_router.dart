import 'package:go_router/go_router.dart';
import 'package:nestle_waters_purelife/temp_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      name: 'homePage',
      builder: (context, state) => const TempPage(),
    ),
  ],
);
