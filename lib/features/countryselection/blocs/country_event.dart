import '../model/countrymodel.dart';

abstract class CountryEvent {}

class SelectCountryEvent extends CountryEvent {
  final Country country;

  SelectCountryEvent(this.country);
}
