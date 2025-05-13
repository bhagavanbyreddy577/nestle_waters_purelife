import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nestle_waters_purelife/my_app.dart';
import 'package:nestle_waters_purelife/core/di/dependencies.dart';
import 'package:nestle_waters_purelife/core/services/hive/hive_setup.dart';

void bootstrap(String env) async{

  WidgetsFlutterBinding.ensureInitialized();

  /// To load environments variables from a .env file securely
  if(env == 'development'){
    await dotenv.load(fileName: "dev.env");
  }else if(env == 'staging'){
    await dotenv.load(fileName: "stage.env");
  }else {
    await dotenv.load(fileName: "prod.env");
  }


  await setupHive();
  await setupDependencies();

  runApp(MyApp(env: env));
}