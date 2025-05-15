part of 'signin_bloc.dart';

sealed class SigninState extends Equatable {
  const SigninState();
}

final class SigninInitial extends SigninState {
  @override
  List<Object> get props => [];
}
