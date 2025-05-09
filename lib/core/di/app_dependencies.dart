import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import 'package:nestle_waters_purelife/core/services/network/network_info.dart';
import 'package:nestle_waters_purelife/core/services/graphql/graphql_service.dart';
import 'package:nestle_waters_purelife/core/services/graphql/graphql_service_impl.dart';
import 'package:nestle_waters_purelife/core/services/hive/hive_service.dart';
import 'package:nestle_waters_purelife/core/services/hive/hive_service_impl.dart';
import 'package:nestle_waters_purelife/core/services/http/http_client_service.dart';
import 'package:nestle_waters_purelife/core/services/http/http_client_service_impl.dart';
import 'package:nestle_waters_purelife/core/services/sharedPreferences/shared_pref_service.dart';
import 'package:nestle_waters_purelife/core/services/sharedPreferences/shared_pref_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> appDependencies() async {

  // External packages
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);

  // Local Storage Service
  sl.registerLazySingleton<SharedPrefService>(
        () => SharedPrefServiceImpl(sl()),
  );

  // Logger
  sl.registerLazySingleton(() => Logger());

  // GraphQL Client
  final HttpLink httpLink = HttpLink('https://countries.trevorblades.com/');
  sl.registerLazySingleton(() => GraphQLClient(
        cache: GraphQLCache(store: HiveStore()),
        link: httpLink,
      ));

  // Register NetworkInfo
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Register GraphQL Service
  sl.registerLazySingleton<GraphQLService>(() => GraphQLServiceImpl(sl()));

  // Register http client
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Register http client service
  sl.registerLazySingleton<HttpClientService>(
      () => HttpClientServiceImpl(sl()));

  // Register Hive service
  sl.registerLazySingletonAsync<HiveService>(
      () async => HiveServiceImpl(await getHiveBox()));
}

Future<Box> getHiveBox() async {
  return await Hive.openBox('countries');
}
