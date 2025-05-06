
class CountryCodeData {

  /// The name of the country
  final String name;

  /// The country calling code (e.g., +1, +44, +91)
  final String code;

  /// The ISO country code (e.g., US, UK, IN)
  final String isoCode;

  /// Flag emoji for the country
  final String flag;

  /// The maximum length of phone numbers in this country
  final int maxLength;

  /// The minimum length of phone numbers in this country
  final int minLength;

  /// Regular expression pattern for validating phone numbers in this country
  final String? pattern;

  const CountryCodeData({
    required this.name,
    required this.code,
    required this.isoCode,
    required this.flag,
    this.maxLength = 15,
    this.minLength = 5,
    this.pattern,
  });
}
