
abstract class RegistrationEvent {}

class FirstNameChanged extends RegistrationEvent {
  final String firstName;
  FirstNameChanged(this.firstName);
}

class LastNameChanged extends RegistrationEvent {
  final String lastName;
  LastNameChanged(this.lastName);
}

class MobileChanged extends RegistrationEvent {
  late final String mobile;

  MobileChanged(String value);

  // MobileChanged(String value);
  // RegistrationEvent(this.mobile);
}

class EmailChanged extends RegistrationEvent {
  final String email;
  EmailChanged(this.email);
}

class ConsentChanged extends RegistrationEvent {
  final bool value;
  ConsentChanged(this.value);
}

class AgeConfirmed extends RegistrationEvent {
  final bool value;
  AgeConfirmed(this.value);
}

class SubmitForm extends RegistrationEvent {}
