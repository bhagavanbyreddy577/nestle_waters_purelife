
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/Signup1/bloc/register_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/Signup1/bloc/register_state.dart';

// class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
//   RegistrationBloc() : super(RegistrationState()) {
//     on<FirstNameChanged>((event, emit) {
//       emit(state.copyWith(firstName: event.firstName));
//     });

//     on<LastNameChanged>((event, emit) {
//       emit(state.copyWith(lastName: event.lastName));
//     });

//     on<EmailChanged>((event, emit) {
//       emit(state.copyWith(email: event.email));
//     });

//     on<MobileChanged>((event, emit) {
//       emit(state.copyWith(mobile: event.mobile));
//     });

//     on<ConsentChanged>((event, emit) {
//       emit(state.copyWith(consent: event.value));
//     });

//     on<AgeConfirmed>((event, emit) {
//       emit(state.copyWith(isOver18: event.value));
//     });

//     on<SubmitForm>((event, emit) {
//       // Add submit logic here (e.g., API call)
//     });
//   }
// }