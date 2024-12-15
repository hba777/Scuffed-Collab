part of 'project_details_bloc.dart';

@immutable
sealed class ProjectDetailsEvent {}

class ProjectDetailsInitialEvent extends ProjectDetailsEvent {
  final Projects project;

  ProjectDetailsInitialEvent({required this.project});

}

class ProjectDetailsDeleteBtnEvent extends ProjectDetailsEvent{
  final String projectId;

  ProjectDetailsDeleteBtnEvent({required this.projectId});
}

// Member Events

class ProjectDetailsMemberBtnEvent extends ProjectDetailsEvent{}

class ProjectDetailsMemberAddedEvent extends ProjectDetailsEvent {
  final String email;
  final Projects project;
  ProjectDetailsMemberAddedEvent({required this.email, required this.project});
}

class ProjectDetailsRemoveMemberEvent extends ProjectDetailsEvent{
  final TeamMember member;
  final Projects project;

  ProjectDetailsRemoveMemberEvent({required this.member, required this.project});

}
// Task Events
class ProjectDetailsAddTaskButtonEvent extends ProjectDetailsEvent{
  final String projectId;

  ProjectDetailsAddTaskButtonEvent({required this.projectId});
}

class ProjectDetailsCreateTaskEvent extends ProjectDetailsEvent {
  final String taskId,taskTitle, taskDescription, taskAssigned, taskStatus,taskDeadline;

  ProjectDetailsCreateTaskEvent({required this.taskId,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskAssigned,
    required this.taskStatus,
    required this.taskDeadline});
}

class TaskClickedEvent extends ProjectDetailsEvent {
  final TaskModel task;

  TaskClickedEvent({required this.task});
}

class TaskAssignedChangeEvent extends ProjectDetailsEvent{
  final String email;

  TaskAssignedChangeEvent({required this.email});
}

class TaskStatusChangeEvent extends ProjectDetailsEvent{
  final String status;

  TaskStatusChangeEvent({required this.status});
}

class TaskDeadlineSelectedEvent extends ProjectDetailsEvent {
  final String deadline;

  TaskDeadlineSelectedEvent({required this.deadline});
}

class TaskEmptyFieldsEvent extends ProjectDetailsEvent{}

// Task Details Screen Events
class TaskScreenStatusChangedEvent extends ProjectDetailsEvent{
  final String projectId;
  final String taskId;
  final String status;

  TaskScreenStatusChangedEvent({required this.projectId, required this.taskId, required this.status});
}

class TaskDeleteBtnEvent extends ProjectDetailsEvent{
  final String projectId;
  final String taskId;

  TaskDeleteBtnEvent({required this.projectId, required this.taskId});
}

