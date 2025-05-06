import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/l10n/generated/app_localizations.dart';
import 'core/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.env});
  final String env;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Nestle Waters App',
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates);
  }
}
