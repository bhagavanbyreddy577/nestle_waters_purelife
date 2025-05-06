import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'core/routes/app_router.dart';
import 'l10n/l10n.dart';

class MyApp extends StatelessWidget {

  const MyApp({super.key, required this.env});
  final String env;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Nestle Waters App',
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        supportedLocales: L10n.all,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ]);
  }
}
