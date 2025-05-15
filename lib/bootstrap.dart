import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nestle_waters_purelife/my_app.dart';
import 'package:nestle_waters_purelife/utils/helpers/helper_functions.dart';

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

  await NHelperFunctions.setupHive();
  await NHelperFunctions.setupAllDependencies();

  runApp(MyApp(env: env));
}