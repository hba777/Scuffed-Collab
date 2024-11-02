part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

abstract class LoginActionState extends LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoadingState extends LoginState {
}

final class LoginErrorState extends LoginState {
  final String error;

  LoginErrorState({required this.error});
}

final class LoginSuccessState extends LoginState {}

class LoginUserExistsState extends LoginActionState{}

class LoginCreateUserState extends LoginActionState{}
