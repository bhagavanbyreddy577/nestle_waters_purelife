abstract class SignupEvent {}

class InputChanged extends SignupEvent {
  final String value;
  InputChanged(this.value);
}

class FullNameChanged extends SignupEvent {
  final String fullName;
  FullNameChanged(this.fullName);
}

class EmailChanged extends SignupEvent {
  final String email;
  EmailChanged(this.email);
}

class CountryCodeChanged extends SignupEvent {
  final String code;
  CountryCodeChanged(this.code);
}

class ToggleReceiveOffers extends SignupEvent {}

class ToggleTermsandcondition extends SignupEvent {}
