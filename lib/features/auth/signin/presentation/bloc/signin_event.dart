
abstract class SigninEvent {}

class InputChanged extends SigninEvent {
  final String value;
  InputChanged(this.value);
}

class CountryCodeChanged extends SigninEvent {
  final String code;
  CountryCodeChanged(this.code);
}

class ToggleReceiveOffers extends SigninEvent {}

