part of 'project_bloc.dart';

@immutable
abstract class ProjectEvent {}

class ProjectInitialEvent extends ProjectEvent {}

class ProjectBackBtnEvent extends ProjectEvent{}

class ProjectTeamMemberScreenLoadedEvent extends ProjectEvent{}

class ProjectDetailsSubmittedEvent extends ProjectEvent {
  final String title;
  final String description;
  final String deadline;

  ProjectDetailsSubmittedEvent({required this.title, required this.description, required this.deadline});

}

class ProjectIncompleteDetailsSubmittedEvent extends ProjectEvent {}

class ProjectDeadlineSelectedEvent extends ProjectEvent {
  final String deadline;

  ProjectDeadlineSelectedEvent({required this.deadline});
}

class ProjectMemberAddedEvent extends ProjectEvent {
  final String email;

  ProjectMemberAddedEvent(this.email);
}


class ProjectCreateButtonEvent extends ProjectEvent {
  final String title;
  final String description;
  final String deadline;
  ProjectCreateButtonEvent({required this.title,
    required this.description,
    required this.deadline});
}

class ProjectTitleChangedEvent extends ProjectEvent {
  final String title;

  ProjectTitleChangedEvent({required this.title});
}

class ProjectDescriptionChangedEvent extends ProjectEvent {
  final String description;

  ProjectDescriptionChangedEvent({required this.description});
}