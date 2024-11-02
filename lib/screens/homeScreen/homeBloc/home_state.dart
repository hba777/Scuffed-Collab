part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

abstract class HomeActionState extends HomeState {}

class HomeInitial extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeSuccessState extends HomeState {
  final List<Projects> projects;
  final UserModel user;

  HomeSuccessState({required this.projects, required this.user});
}

class HomeErrorState extends HomeActionState {
  final String error;

  HomeErrorState({required this.error});
}

//For Project Clicked Navigation
class HomeProjectClickedNavigationState extends HomeActionState {
  final Projects clickedProject;

  HomeProjectClickedNavigationState({required this.clickedProject});
}

//For Profile Navigation
class HomeProfileNavigationState extends HomeActionState {
  final UserModel user;

  HomeProfileNavigationState({required this.user});
}

//For Project Navigation
class HomeProjectNavigationState extends HomeActionState {}

//For LifecycleStates
class HomeLifecyclePauseState extends HomeActionState{}

class HomeLifecycleStartState extends HomeActionState{}