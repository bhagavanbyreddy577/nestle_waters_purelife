class RegistrationState {
  final String firstName;
  final String lastName;
  final String mobile;
  final String email;
  final bool consent;
  final bool isOver18;

  bool get isValid => firstName.isNotEmpty &&
                      lastName.isNotEmpty &&
                      mobile.length >= 9 &&
                      email.contains('@') &&
                      isOver18;

  RegistrationState({
    this.firstName = '',
    this.lastName = '',
    this.mobile = '',
    this.email = '',
    this.consent = false,
    this.isOver18 = false,
  });

  get receiveOffers => null;

  RegistrationState copyWith({
    String? firstName,
    String? lastName,
    String? mobile,
    String? email,
    bool? consent,
    bool? isOver18,
  }) {
    return RegistrationState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      consent: consent ?? this.consent,
      isOver18: isOver18 ?? this.isOver18,
    );
  }
}