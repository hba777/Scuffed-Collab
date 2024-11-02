part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

class HomeProfileButtonEvent extends HomeEvent {
  final UserModel user;

  HomeProfileButtonEvent({required this.user});
}

class HomeFilterProjectsEvent extends HomeEvent {
  final String query;

  HomeFilterProjectsEvent(this.query);
}

class HomeCreateProjectEvent extends HomeEvent {}

class HomeProjectClickedEvent extends HomeEvent {
  final Projects clickedProject;

  HomeProjectClickedEvent({required this.clickedProject});
}


class HomeUpdateActiveStatusEvent extends HomeEvent{
  final bool isOnline;

  HomeUpdateActiveStatusEvent({required this.isOnline});
}

class HomeLifecycleChangeEvent extends HomeEvent{
  final String lifecycleState;

  HomeLifecycleChangeEvent({required this.lifecycleState});
}