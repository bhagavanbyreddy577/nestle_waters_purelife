import 'package:bloc/bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/bloc/signup_event.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/bloc/signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupState()) {
    on<InputChanged>((event, emit) {
      final input = event.value;
      final isPhone = RegExp(r'^\d{7,15}$').hasMatch(input);
      final isAlphabet = RegExp(r'^[a-zA-Z]').hasMatch(event.value);
      // final firstname = event.value;

      emit(state.copyWith(
        input: event.value,
        showClear: event.value.isNotEmpty && !isAlphabet,
        showCountryDropdown: !isAlphabet,
        // firstname :event.value,
      ));

      //  if (true) {
      //   emit(
      //     state.copyWith(
      //       input: input,
      //       isValid: true,
      //       errorMessage: null,
      //     ),
      //   );
      // }

      if (isPhone) {
        emit(
          state.copyWith(
            input: input,
            isValid: true,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            input: input,
            isValid: false,
            errorMessage: 'Enter your Valid mobile Number',
          ),
        );
      }
    });

    on<CountryCodeChanged>((event, emit) {
      emit(state.copyWith(selectedCountryCode: event.code));
    });

    on<ToggleReceiveOffers>((event, emit) {
      emit(state.copyWith(receiveOffers: !state.receiveOffers));
    });

    on<ToggleTermsandcondition>((event, emit) {
      emit(state.copyWith(termsandcondition: !state.termsandcondition));
    });

    on<FullNameChanged>((event, emit) {
      emit(state.copyWith(input: state.fullName));
      final isfullnameValid = event.fullName.trim().split('').length >= 2;

      emit(
        state.copyWith(
          fullName: event.fullName,
          isFullNameValid: isfullnameValid,
          fullNameErrorMesaage: 'Invalid full Name',
        ),
      );
    });

    on<EmailChanged>((event, emit) {
      emit(state.copyWith(input: state.email));
      final isemailvalid = _isValidEmail(event.email);
      emit(
        state.copyWith(
          email: event.email,
          isEmailValid: isemailvalid,
          //errorMessage: 'Enter your full Name',
        ),
      );
    });
  }
}

// //set the validation Email
bool _isValidEmail(String input) {
  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegExp.hasMatch(input);
}
