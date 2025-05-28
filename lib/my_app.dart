import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/core/router/router.dart' as router;
import 'package:nestle_waters_purelife/l10n/generated/app_localizations.dart';
import 'package:nestle_waters_purelife/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.env});
  final String env;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: NHelperFunctions.getAllProviders(),
      child: MaterialApp.router(
        title: 'Nestle Waters App',
        routerConfig: router.Router.createRouter(),
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
