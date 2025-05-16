// Provider for country and region selection with feature flags
import 'package:flutter/foundation.dart';
import 'package:nestle_waters_purelife/core/providers/feature_flag_provider/feature_flag_data.dart';
import 'package:nestle_waters_purelife/core/providers/feature_flag_provider/feature_flag_service.dart';

class FeatureFlagProvider with ChangeNotifier {

  FeatureFlagService? _remoteConfigService;
  Country _selectedCountry = Country.UnitedArabEmirates; // Default country
  Region _selectedRegion = Region.Central; // Default region
  FeatureFlags _currentFeatureFlags = FeatureFlags();
  bool _isLoading = true;

  // Getters
  Country get selectedCountry => _selectedCountry;
  Region get selectedRegion => _selectedRegion;
  FeatureFlags get featureFlags => _currentFeatureFlags;
  bool get isLoading => _isLoading;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _remoteConfigService = await FeatureFlagService.initialize();
      await updateFeatureFlags();
    } catch (e) {
      print('Error initializing RegionConfigProvider: $e');
      // Use default feature flags
      _currentFeatureFlags = FeatureFlags();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update country and region
  Future<void> updateCountryAndRegion(Country country, Region region) async {
    _selectedCountry = country;
    _selectedRegion = region;
    await updateFeatureFlags();
    notifyListeners();
  }

  // Update feature flags based on selected country and region
  Future<void> updateFeatureFlags() async {
    if (_remoteConfigService == null) return;

    // Get flags from remote config
    _currentFeatureFlags = _remoteConfigService!.getFeatureFlagsForCountry(_selectedCountry);

    // You can apply region-specific overrides if needed
    if (_selectedRegion == Region.North && _selectedCountry == Country.Egypt) {
      // Example: Express delivery not available in North Egypt
      _currentFeatureFlags = _currentFeatureFlags.copyWith(expressDeliveryEnabled: false);
    }

    notifyListeners();
  }

  // Force refresh from remote config
  Future<void> refreshConfiguration() async {
    _isLoading = true;
    notifyListeners();

    try {
      _remoteConfigService = await FeatureFlagService.initialize();
      await updateFeatureFlags();
    } catch (e) {
      print('Error refreshing configuration: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

// TODO: Usage Example (Need to remove in production)
/// This [FeatureFlagProvider] and [FeatureFlagService] classes are created on below assumption.
/// Assumption: The idea here is whenever user selects/changes the country and region in the app, We will check the firebase config flags and configure them in locally. The application should able to fetch which fetaure is enabled which disabled based on that flag. whenever user selects country and region provider class has notify to the listeners.
/*
*
*
* // Usage in main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegionConfigProvider()..initialize()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feature Flags Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CountrySelectionScreen(),
    );
  }
}

// Country Selection Screen
class CountrySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final regionProvider = Provider.of<RegionConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Select Country')),
      body: regionProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: Country.values.map((country) {
                return ListTile(
                  title: Text(country.toString().split('.').last),
                  selected: regionProvider.selectedCountry == country,
                  onTap: () {
                    // Navigate to region selection screen passing the selected country
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegionSelectionScreen(country: country),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}

// Region Selection Screen
class RegionSelectionScreen extends StatelessWidget {
  final Country country;

  const RegionSelectionScreen({Key? key, required this.country}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final regionProvider = Provider.of<RegionConfigProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Select Region')),
      body: ListView(
        children: Region.values.map((region) {
          return ListTile(
            title: Text(region.toString().split('.').last),
            onTap: () async {
              // Update country and region, which will trigger feature flag updates
              await regionProvider.updateCountryAndRegion(country, region);

              // Navigate to the home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

// Home Screen with feature-based UI
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the provider
    final regionProvider = Provider.of<RegionConfigProvider>(context);
    final featureFlags = regionProvider.featureFlags;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => regionProvider.refreshConfiguration(),
          ),
        ],
      ),
      body: regionProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Country: ${regionProvider.selectedCountry.toString().split('.').last}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Region: ${regionProvider.selectedRegion.toString().split('.').last}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Available Features:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildFeatureItem('Cybersource Payment', featureFlags.cybersourceEnabled),
                  _buildFeatureItem('Payfort Payment', featureFlags.payfortEnabled),
                  _buildFeatureItem('Loyalty Program', featureFlags.loyaltyProgramEnabled),
                  _buildFeatureItem('Express Delivery', featureFlags.expressDeliveryEnabled),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => CountrySelectionScreen()),
                      );
                    },
                    child: Text('Change Country/Region'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(String title, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.red,
          ),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}

// Feature-specific screens/widgets
// These components would check the feature flags before rendering

// Example: Payment method selection that respects feature flags
class PaymentMethodSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final regionProvider = Provider.of<RegionConfigProvider>(context);
    final featureFlags = regionProvider.featureFlags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        if (featureFlags.cybersourceEnabled)
          _buildPaymentOption('Cybersource', 'Pay with credit card via Cybersource'),
        if (featureFlags.payfortEnabled)
          _buildPaymentOption('Payfort', 'Pay with Payfort payment gateway'),
        if (!featureFlags.cybersourceEnabled && !featureFlags.payfortEnabled)
          Text('No payment methods available for your region'),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle payment selection
        },
      ),
    );
  }
}

// Example Usage of Feature Flags in Business Logic
class CheckoutService {
  final RegionConfigProvider regionProvider;

  CheckoutService(this.regionProvider);

  Future<void> processCheckout() async {
    final featureFlags = regionProvider.featureFlags;

    // Apply express delivery if available
    if (featureFlags.expressDeliveryEnabled) {
      // Process express delivery
    } else {
      // Process standard delivery
    }

    // Apply loyalty points if program is enabled
    if (featureFlags.loyaltyProgramEnabled) {
      // Apply loyalty points
    }
  }
}
*
*
*
* */