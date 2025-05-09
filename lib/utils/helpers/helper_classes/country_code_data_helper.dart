
class CountryCodeDataHelper {

  /// list of common countries with their calling codes and validation information
  static const List<CountryCodeData> countryCodeData  =
  [
    const CountryCodeData(
      name: 'United States',
      code: '+1',
      isoCode: 'US',
      flag: '🇺🇸',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[2-9]\d{9}$',
    ),
    const CountryCodeData(
      name: 'India',
      code: '+91',
      isoCode: 'IN',
      flag: '🇮🇳',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[6-9]\d{9}$',
    ),
    const CountryCodeData(
      name: 'United Kingdom',
      code: '+44',
      isoCode: 'GB',
      flag: '🇬🇧',
      maxLength: 10,
      minLength: 9,
      pattern: r'^7\d{9}$',
    ),
    const CountryCodeData(
      name: 'Canada',
      code: '+1',
      isoCode: 'CA',
      flag: '🇨🇦',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[2-9]\d{9}$',
    ),
    const CountryCodeData(
      name: 'Australia',
      code: '+61',
      isoCode: 'AU',
      flag: '🇦🇺',
      maxLength: 9,
      minLength: 9,
      pattern: r'^4\d{8}$',
    ),
    const CountryCodeData(
      name: 'Germany',
      code: '+49',
      isoCode: 'DE',
      flag: '🇩🇪',
      maxLength: 11,
      minLength: 10,
      pattern: r'^1\d{9,10}$',
    ),
    const CountryCodeData(
      name: 'France',
      code: '+33',
      isoCode: 'FR',
      flag: '🇫🇷',
      maxLength: 9,
      minLength: 9,
      pattern: r'^[67]\d{8}$',
    ),
    const CountryCodeData(
      name: 'Japan',
      code: '+81',
      isoCode: 'JP',
      flag: '🇯🇵',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[789]0\d{8}$',
    ),
    const CountryCodeData(
      name: 'China',
      code: '+86',
      isoCode: 'CN',
      flag: '🇨🇳',
      maxLength: 11,
      minLength: 11,
      pattern: r'^1\d{10}$',
    ),
    const CountryCodeData(
      name: 'Brazil',
      code: '+55',
      isoCode: 'BR',
      flag: '🇧🇷',
      maxLength: 11,
      minLength: 10,
      pattern: r'^[1-9]{2}9?\d{8}$',
    ),
    // Add more countries as needed
  ];

}


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
