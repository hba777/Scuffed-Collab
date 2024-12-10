part of 'project_bloc.dart';

@immutable
abstract class ProjectState {}

abstract class ProjectActionState extends ProjectState {}

class ProjectInitial extends ProjectState {}

class ProjectSuccessState extends ProjectState {}

class ProjectBackBtnNavState extends ProjectActionState{}

class ProjectSubmittingState extends ProjectState {}

class ProjectSubmittedState extends ProjectActionState {
  final String title;
  final String deadline;
  final String description;

  ProjectSubmittedState({required this.title,
    required this.deadline,
    required this.description});
}

class ProjectDeadlineSubmittedState extends ProjectState {
  final String deadline;

  ProjectDeadlineSubmittedState({required this.deadline});

}

class ProjectIncompleteDetailsSubmittedState extends ProjectActionState {
  final String message;

  ProjectIncompleteDetailsSubmittedState({required this.message});

}

class ProjectTeamMemberAdded extends ProjectState {
  final List<TeamMember> members;

  ProjectTeamMemberAdded(this.members);
}

class ProjectErrorState extends ProjectActionState {
  final String message;

  ProjectErrorState(this.message);
}

class ProjectMemberAlreadyExistsState extends ProjectActionState {}

class ProjectTeamMemberNotExistState extends ProjectActionState {}

class ProjectCreateButtonNavigationState extends ProjectActionState {}

class ProjectTeamEmptyState extends ProjectActionState {}