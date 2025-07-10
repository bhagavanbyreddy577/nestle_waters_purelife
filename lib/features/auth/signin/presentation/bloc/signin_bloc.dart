
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signin/presentation/bloc/signin_event.dart';
import 'package:nestle_waters_purelife/features/auth/signin/presentation/bloc/signin_state.dart';


class SigninBloc extends Bloc<SigninEvent, SigninState> {
  SigninBloc() : super(SigninState()) {
    on<InputChanged>((event, emit) {
      final input = event.value;
      final isEmail = _isValidEmail(input);
      final isPhone = RegExp(r'^\d{7,15}$').hasMatch(input);
      final isAlphabet = RegExp(r'^[a-zA-Z]').hasMatch(event.value);

      emit(state.copyWith(
        input: event.value,
        isEmail: isAlphabet,
        showClear: event.value.isNotEmpty && !isAlphabet,
        showCountryDropdown: !isAlphabet,
      ));

      if (isEmail) {
        emit(
          state.copyWith(
            input: input,
            isEmail: true,
            isValid: true,
            errorMessage: null,
          ),
        );
      } else if (isPhone) {
        emit(
          state.copyWith(
            input: input,
            isEmail: false,
            isValid: true,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            input: input,
            isEmail: false,
            isValid: false,
            errorMessage: 'Enter valid email or phone number',
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
  }
}

//set the validation Email
bool _isValidEmail(String input) {
  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegExp.hasMatch(input);
}

