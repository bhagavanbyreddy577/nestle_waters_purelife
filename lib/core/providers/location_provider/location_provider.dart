import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/core/providers/location_provider/location_data.dart';

/// A provider class that manages location data throughout the application
class LocationProvider extends ChangeNotifier {

  /// Current location data instance
  LocationData _currentLocation;

  /// Default constructor that initializes with default LocationData
  LocationProvider() : _currentLocation = const LocationData();

  /// Getter for current location data
  LocationData get currentLocation => _currentLocation;

  /// Update the current location with new data
  ///
  /// [newLocation] The new location data to set
  void updateLocation(LocationData newLocation) {

    // Update current location
    _currentLocation = newLocation;

    // Notify listeners about the change
    notifyListeners();
  }

  /// Update just the country and region of the current location
  ///
  /// [country] The new country value
  /// [region] The new region value
  void updateCountryAndRegion(String country, String region) {
    updateLocation(
      _currentLocation.copyWith(
        country: country,
        region: region,
      ),
    );
  }

  /// Update coordinates of the current location
  ///
  /// [latitude] The new latitude value
  /// [longitude] The new longitude value
  void updateCoordinates(double latitude, double longitude) {
    updateLocation(
      _currentLocation.copyWith(
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  /// Dispose method to clean up resources
  @override
  void dispose() {
    // Perform any cleanup operations here
    super.dispose();
  }
}


// TODO: Usage Example (Need to remove in production)
/*
* // To read data from provider
* context.watch<LocationProvider>().currentLocation
*
* // To write data to provider
* context.read<LocationProvider>().updateCountryAndRegion("", "")
*
* */