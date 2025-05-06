import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.mobile ||
        connectivityResult.first == ConnectivityResult.wifi) {
      return true; // Connected to either mobile or Wi-Fi network
    } else {
      return false; // No internet connection
    }
  }

  @override
  Future<bool> get isConnected => checkInternetConnection();
}
