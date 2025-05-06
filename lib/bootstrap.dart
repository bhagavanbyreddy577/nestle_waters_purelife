import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/my_app.dart';
import 'package:nestle_waters_purelife/core/di/dependencies.dart';
import 'package:nestle_waters_purelife/core/services/hive/hive_setup.dart';

void bootstrap(String env) async{

  WidgetsFlutterBinding.ensureInitialized();

  await setupHive();
  await setupDependencies();

  runApp(MyApp(env: env));
}