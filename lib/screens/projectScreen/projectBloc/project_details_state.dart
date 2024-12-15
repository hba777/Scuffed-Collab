part of 'project_details_bloc.dart';

@immutable
sealed class ProjectDetailsState {}

abstract class ProjectDetailsActionState extends ProjectDetailsState{}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsSuccessState extends ProjectDetailsState {
  final List<TeamMember?> teamMembers;
  final List<TaskModel?> tasks;
  ProjectDetailsSuccessState({required this.teamMembers, required this.tasks});
}

class ProjectDetailsDeleteBtnNavState extends ProjectDetailsActionState{}

class ProjectDetailsLoadingState extends ProjectDetailsActionState {}

class ProjectDetailsErrorState extends ProjectDetailsActionState{
  final String error;

  ProjectDetailsErrorState({required this.error});
}

class ProjectDetailsAddTaskBtnNavState extends ProjectDetailsActionState {
  final List<TeamMember?> teamMembers;
  final String projectId;

  ProjectDetailsAddTaskBtnNavState({required this.teamMembers, required this.projectId, });
}

// Member Add Screen
class ProjectDetailsMemberBtnNavState extends ProjectDetailsActionState{}

class ProjectTeamMemberAdded extends ProjectDetailsActionState {
  final String email;

  ProjectTeamMemberAdded({required this.email});
}

class ProjectMemberAlreadyExistsState extends ProjectDetailsActionState {}

class ProjectTeamMemberNotExistState extends ProjectDetailsActionState {}

// Task Screen
class TaskAssignedChangedState extends ProjectDetailsState {
  final String email;

  TaskAssignedChangedState({required this.email});
}

class TaskStatusChangedState extends ProjectDetailsState {
  final String status;

  TaskStatusChangedState({required this.status});

}

class TaskEmptyFieldsState extends ProjectDetailsActionState {}
// Task Details Screen States
class ProjectDetailsCreateTaskNavState extends ProjectDetailsActionState {}

class TaskDeadlineSubmittedState extends ProjectDetailsState {
  final String deadline;

  TaskDeadlineSubmittedState({required this.deadline});

}

class TaskClickedNavState extends ProjectDetailsActionState{
  final TaskModel task;

  TaskClickedNavState({required this.task});
}

class TaskStatusUpdatedNavBackBtnState extends ProjectDetailsActionState{}

class TaskDeleteBtnNavState extends ProjectDetailsActionState{}

