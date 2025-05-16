// Feature Flags model class
class FeatureFlags {
  // We can update this based on our needs
  final bool cybersourceEnabled;
  final bool payfortEnabled;
  final bool loyaltyProgramEnabled;
  final bool expressDeliveryEnabled;

  FeatureFlags({
    this.cybersourceEnabled = false,
    this.payfortEnabled = false,
    this.loyaltyProgramEnabled = false,
    this.expressDeliveryEnabled = false,
  });

  // Create a copy with modified values
  FeatureFlags copyWith({
    bool? cybersourceEnabled,
    bool? payfortEnabled,
    bool? loyaltyProgramEnabled,
    bool? expressDeliveryEnabled,
  }) {
    return FeatureFlags(
      cybersourceEnabled: cybersourceEnabled ?? this.cybersourceEnabled,
      payfortEnabled: payfortEnabled ?? this.payfortEnabled,
      loyaltyProgramEnabled: loyaltyProgramEnabled ?? this.loyaltyProgramEnabled,
      expressDeliveryEnabled: expressDeliveryEnabled ?? this.expressDeliveryEnabled,
    );
  }
}


// Enum for countries
enum Country {
  // We can update this based on our needs
  Bahrain,
  UnitedArabEmirates,
  Qatar,
  Lebanon,
  Jordan,
  Egypt,
  KSA,
}

// Enum for regions
enum Region {
  // We can update this based on our needs
  North,
  South,
  East,
  West,
  Central,
}

