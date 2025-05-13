import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/core/app_state/app_state_widget.dart';
import 'package:nestle_waters_purelife/l10n/generated/app_localizations.dart';
import 'core/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.env});
  final String env;

  @override
  Widget build(BuildContext context) {
    return AppStateWidget(
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
              title: 'Nestle Waters App',
              routerConfig: AppRoutes.createRouter(),
              debugShowCheckedModeBanner: false,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates);
        }
      ),
    );
  }
}
