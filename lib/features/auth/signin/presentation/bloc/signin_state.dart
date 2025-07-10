
class SigninState {
  final String input;
  final String selectedCountryCode;
  final bool isEmail;
  final bool showClear;
  final bool showCountryDropdown;
  final bool isValid;
  final String? errorMessage;
  final bool receiveOffers;

  SigninState({
    this.input = '',
    this.selectedCountryCode = '+971',
    this.isEmail = false,
    this.isValid = false,
    this.showClear = false,
    this.showCountryDropdown = false,
    this.errorMessage,
    this.receiveOffers = false,
  });

  factory SigninState.initial() => SigninState(
        input: '',
        isEmail: false,
        showClear: false,
        showCountryDropdown: false,
      );

  SigninState copyWith({
    String? input,
    String? selectedCountryCode,
    bool? isEmail,
    bool? isValid,
    bool? showClear,
    bool? showCountryDropdown,
    String? errorMessage,
    bool? receiveOffers,
  }) {
    return SigninState(
      input: input ?? this.input,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      isEmail: isEmail ?? this.isEmail,
      isValid: isValid ?? this.isValid,
      showClear: showClear ?? this.showClear,
      showCountryDropdown: showCountryDropdown ?? this.showCountryDropdown,
      errorMessage: errorMessage,
      receiveOffers: receiveOffers ?? this.receiveOffers,
    );
  }
}