// Firebase Remote Config service
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:nestle_waters_purelife/core/providers/feature_flag_provider/feature_flag_data.dart';

class FeatureFlagService {

  final FirebaseRemoteConfig _remoteConfig;

  FeatureFlagService(this._remoteConfig);

  static Future<FeatureFlagService> initialize() async {

    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(hours: 1),
    ));

    // Set defaults (fallback values)
    await remoteConfig.setDefaults({
      'bahrain_cybersource_enabled': false,
      'bahrain_payfort_enabled': true,
      'bahrain_loyalty_enabled': true,
      'bahrain_express_delivery_enabled': false,

      // Add similar defaults for all countries
    });

    try {
      // Fetch and activate
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }

    return FeatureFlagService(remoteConfig);
  }

  // Get feature flag from remote config based on country and feature
  bool getFeatureFlag(Country country, String feature) {
    final key = '${country.toString().split('.').last.toLowerCase()}_${feature}_enabled';
    return _remoteConfig.getBool(key);
  }

  // Get feature flags for a specific country
  FeatureFlags getFeatureFlagsForCountry(Country country) {
    final countryName = country.toString().split('.').last.toLowerCase();

    return FeatureFlags(
      cybersourceEnabled: _remoteConfig.getBool('${countryName}_cybersource_enabled'),
      payfortEnabled: _remoteConfig.getBool('${countryName}_payfort_enabled'),
      loyaltyProgramEnabled: _remoteConfig.getBool('${countryName}_loyalty_enabled'),
      expressDeliveryEnabled: _remoteConfig.getBool('${countryName}_express_delivery_enabled'),
    );
  }
}
