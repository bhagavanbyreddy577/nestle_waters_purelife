
class SignupState {
  final String input;
  final String selectedCountryCode;
  final bool showClear;
  final bool showCountryDropdown;
  final bool isValid;
  final String? errorMessage;
  final bool receiveOffers;
  final bool termsandcondition;
  final String fullName;
  final bool isFullNameValid;
  final String fullNameErrorMesaage;
  final String email;
  final bool isEmailValid;


  SignupState({
    this.input = '',
    this.selectedCountryCode = '+971',
    this.isValid = false,
    this.showClear = false,
    this.showCountryDropdown = false,
    this.errorMessage ,
    this.receiveOffers = false,
    this.termsandcondition = false,
    this.fullName = '',
    this.fullNameErrorMesaage = '',
    this.isFullNameValid = false,
    this.email = '', 
    this.isEmailValid = false,
  });

  factory SignupState.initial() => SignupState(
        input: '',
        showClear: false,
        showCountryDropdown: false,
      );

  SignupState copyWith({
    String? input,
    String? selectedCountryCode,
    bool? isValid,
    bool? showClear,
    bool? showCountryDropdown,
    String? errorMessage,
    bool? receiveOffers,
    bool? termsandcondition,
    String? fullName,
    bool? isFullNameValid,
    String? fullNameErrorMesaage,
    String? email, 
    bool? isEmailValid,

  }) {
    return SignupState(
      input: input ?? this.input,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      isValid: isValid ?? this.isValid,
      showClear: showClear ?? this.showClear,
      showCountryDropdown: showCountryDropdown ?? this.showCountryDropdown,
      errorMessage: errorMessage,
      receiveOffers: receiveOffers ?? this.receiveOffers,
      termsandcondition: termsandcondition ?? this.termsandcondition,
      fullName : fullName ?? this.fullName,
      isFullNameValid : isFullNameValid ?? this.isFullNameValid,
      fullNameErrorMesaage : fullNameErrorMesaage ?? this.fullNameErrorMesaage,
      email: email ?? this.email,
      isEmailValid:  isEmailValid ?? this.isEmailValid,
    );
  }
}