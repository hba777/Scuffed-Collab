part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginInitialEvent extends LoginEvent{

}

class LoginButtonActionEvent extends LoginEvent{}

