
class CountryCodeDataHelper {

  /// list of common countries with their calling codes and validation information
  static const List<CountryCodeData> countryCodeData  =
  [

    // UAE
    CountryCodeData(
      name: 'United Arab Emirates',
      code: '+971',
      isoCode: 'AE',
      flag: '🇦🇪',
      maxLength: 9,
      minLength: 8,
      pattern: r'^[2-9]\d{7,8}$',
    ),

// Saudi Arabia
    CountryCodeData(
      name: 'Saudi Arabia',
      code: '+966',
      isoCode: 'SA',
      flag: '🇸🇦',
      maxLength: 9,
      minLength: 8,
      pattern: r'^[15]\d{7,8}$',
    ),

// Jordan
    CountryCodeData(
      name: 'Jordan',
      code: '+962',
      isoCode: 'JO',
      flag: '🇯🇴',
      maxLength: 9,
      minLength: 8,
      pattern: r'^[2-9]\d{7,8}$',
    ),

// Egypt
    CountryCodeData(
      name: 'Egypt',
      code: '+20',
      isoCode: 'EG',
      flag: '🇪🇬',
      maxLength: 10,
      minLength: 8,
      pattern: r'^[1-9]\d{7,9}$',
    ),

// Lebanon
    CountryCodeData(
      name: 'Lebanon',
      code: '+961',
      isoCode: 'LB',
      flag: '🇱🇧',
      maxLength: 8,
      minLength: 7,
      pattern: r'^[1-9]\d{6,7}$',
    ),

// Bahrain
    CountryCodeData(
      name: 'Bahrain',
      code: '+973',
      isoCode: 'BH',
      flag: '🇧🇭',
      maxLength: 8,
      minLength: 8,
      pattern: r'^[13-9]\d{7}$',
    ),

// Qatar
    CountryCodeData(
      name: 'Qatar',
      code: '+974',
      isoCode: 'QA',
      flag: '🇶🇦',
      maxLength: 8,
      minLength: 8,
      pattern: r'^[3-7]\d{7}$',
    ),


    /* CountryCodeData(
      name: 'United States',
      code: '+1',
      isoCode: 'US',
      flag: '🇺🇸',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[2-9]\d{9}$',
    ),
    CountryCodeData(
      name: 'India',
      code: '+91',
      isoCode: 'IN',
      flag: '🇮🇳',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[6-9]\d{9}$',
    ),
    CountryCodeData(
      name: 'United Kingdom',
      code: '+44',
      isoCode: 'GB',
      flag: '🇬🇧',
      maxLength: 10,
      minLength: 9,
      pattern: r'^7\d{9}$',
    ),
    CountryCodeData(
      name: 'Canada',
      code: '+1',
      isoCode: 'CA',
      flag: '🇨🇦',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[2-9]\d{9}$',
    ),
    CountryCodeData(
      name: 'Australia',
      code: '+61',
      isoCode: 'AU',
      flag: '🇦🇺',
      maxLength: 9,
      minLength: 9,
      pattern: r'^4\d{8}$',
    ),
    CountryCodeData(
      name: 'Germany',
      code: '+49',
      isoCode: 'DE',
      flag: '🇩🇪',
      maxLength: 11,
      minLength: 10,
      pattern: r'^1\d{9,10}$',
    ),
    CountryCodeData(
      name: 'France',
      code: '+33',
      isoCode: 'FR',
      flag: '🇫🇷',
      maxLength: 9,
      minLength: 9,
      pattern: r'^[67]\d{8}$',
    ),
    CountryCodeData(
      name: 'Japan',
      code: '+81',
      isoCode: 'JP',
      flag: '🇯🇵',
      maxLength: 10,
      minLength: 10,
      pattern: r'^[789]0\d{8}$',
    ),
    CountryCodeData(
      name: 'China',
      code: '+86',
      isoCode: 'CN',
      flag: '🇨🇳',
      maxLength: 11,
      minLength: 11,
      pattern: r'^1\d{10}$',
    ),
    CountryCodeData(
      name: 'Brazil',
      code: '+55',
      isoCode: 'BR',
      flag: '🇧🇷',
      maxLength: 11,
      minLength: 10,
      pattern: r'^[1-9]{2}9?\d{8}$',
    ),
    // Add more countries as needed*/
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
