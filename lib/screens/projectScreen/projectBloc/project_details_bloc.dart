import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:scuffed_collab/models/TeamModel.dart';
import 'package:scuffed_collab/repos/FirebaseApi.dart';
import 'package:scuffed_collab/screens/projectCreationScreen/projectCreationBloc/project_bloc.dart';

import '../../../models/ProjectsModel.dart';
import '../../../models/TaskModel.dart';

part 'project_details_event.dart';
part 'project_details_state.dart';

class ProjectDetailsBloc extends Bloc<ProjectDetailsEvent, ProjectDetailsState> {
  ProjectDetailsBloc() : super(ProjectDetailsInitial()) {
    on<ProjectDetailsInitialEvent>(projectInitialEvent);
    on<ProjectDetailsAddTaskButtonEvent>(projectDetailsAddTaskButtonEvent);
    on<ProjectDetailsDeleteBtnEvent>(projectDetailsDeleteBtnEvent);
    // Member Add Screen
    on<ProjectDetailsMemberBtnEvent>(projectDetailsMemberBtnEvent);
    on<ProjectDetailsMemberAddedEvent>(projectDetailsMemberAddedEvent);
    on<ProjectDetailsRemoveMemberEvent>(projectDetailsRemoveMemberEvent);

    // Task Screen Events
    on<TaskAssignedChangeEvent>(taskAssignedChangeEvent);
    on<TaskStatusChangeEvent>(taskStatusChangeEvent);
    on<ProjectDetailsCreateTaskEvent>(projectDetailsCreateTaskEvent);
    on<TaskDeadlineSelectedEvent>(taskDeadlineSelectedEvent);
    on<TaskClickedEvent>(taskClickedEvent);
    on<TaskScreenStatusChangedEvent>(taskScreenStatusChangedEvent);
    on<TaskDeleteBtnEvent>(taskDeleteBtnEvent);
    on<TaskEmptyFieldsEvent>(taskEmptyFieldsEvent);
  }

  List<TeamMember?> teamMembers=[];
  List<TaskModel?> tasks=[];

  FutureOr<void> projectInitialEvent(ProjectDetailsInitialEvent event, Emitter<ProjectDetailsState> emit) async {
    emit(ProjectDetailsLoadingState());
    try {
      teamMembers = await FirebaseApi.getTeamMembers(event.project.id);
      tasks = await FirebaseApi.getTasks(event.project.id);
      emit(ProjectDetailsSuccessState(teamMembers: teamMembers,tasks: tasks));

    } catch (e) {
      // TODO
      emit(ProjectDetailsErrorState(error: e.toString()));
    }

    for (var member in teamMembers){
      log(member!.email);
    }
  }

  //Delete Project
  FutureOr<void> projectDetailsDeleteBtnEvent(ProjectDetailsDeleteBtnEvent event, Emitter<ProjectDetailsState> emit) async {
    try {
      await FirebaseApi.deleteProject(event.projectId);

      emit(ProjectDetailsDeleteBtnNavState());
    } catch (e) {
      // TODO
      emit(ProjectDetailsErrorState(error: e.toString()));
    }
  }

  //Add Task
  FutureOr<void> projectDetailsAddTaskButtonEvent(ProjectDetailsAddTaskButtonEvent event, Emitter<ProjectDetailsState> emit) {
    emit(ProjectDetailsAddTaskBtnNavState(teamMembers: teamMembers, projectId: event.projectId));
  }

  //Remove Team Member
  FutureOr<void> projectDetailsRemoveMemberEvent(ProjectDetailsRemoveMemberEvent event, Emitter<ProjectDetailsState> emit) async {
    try {
      await FirebaseApi.removeTeamMember(event.project, event.member);
      teamMembers.remove(event.member);
      log('Removed member ${event.member.name}');
      emit(ProjectDetailsSuccessState(teamMembers: teamMembers,tasks: tasks));
    } catch (e) {
      // TODO
      emit(ProjectDetailsErrorState(error: e.toString()));
    }
  }
  // Member Add Screens
  FutureOr<void> projectDetailsMemberBtnEvent(ProjectDetailsMemberBtnEvent event, Emitter<ProjectDetailsState> emit) {
    emit(ProjectDetailsMemberBtnNavState());
  }

  FutureOr<void> projectDetailsMemberAddedEvent(ProjectDetailsMemberAddedEvent event, Emitter<ProjectDetailsState> emit) async {
    try {
      TeamMember? member = await FirebaseApi.getTeamMemberByEmail(event.email);

      if (member != null && !teamMembers.any((m) => m?.email == member.email)) {
        await FirebaseApi.addTeamMember(event.project, member);

        teamMembers.add(member);
        log(member.email);
        emit(ProjectTeamMemberAdded(email: member.email));
      } else if (member == null) {
        emit(ProjectTeamMemberNotExistState());
      } else {
        emit(ProjectMemberAlreadyExistsState());
      }
    } catch (e) {
      emit(ProjectDetailsErrorState(error: e.toString()));
    }
  }
  // Task Screen Events
  FutureOr<void> taskAssignedChangeEvent(TaskAssignedChangeEvent event, Emitter<ProjectDetailsState> emit) {
    emit(TaskAssignedChangedState(email: event.email));
  }

  FutureOr<void> taskStatusChangeEvent(TaskStatusChangeEvent event, Emitter<ProjectDetailsState> emit) {
    emit(TaskStatusChangedState(status: event.status));
  }

  FutureOr<void> taskDeadlineSelectedEvent(TaskDeadlineSelectedEvent event, Emitter<ProjectDetailsState> emit) {
    emit(TaskDeadlineSubmittedState(deadline: event.deadline));
  }

  FutureOr<void> projectDetailsCreateTaskEvent(ProjectDetailsCreateTaskEvent event, Emitter<ProjectDetailsState> emit) async {
    try {
      await FirebaseApi.addTask(event.taskId,
          event.taskTitle,
          event.taskDescription,
          event.taskDeadline,
          event.taskAssigned,
          event.taskStatus);

      emit(ProjectDetailsCreateTaskNavState());

    } catch (e) {
      // TODO
      emit(ProjectDetailsErrorState(error: e.toString()));
    }
  }

  FutureOr<void> taskClickedEvent(TaskClickedEvent event, Emitter<ProjectDetailsState> emit) {
    emit(TaskClickedNavState(task: event.task));
  }

  FutureOr<void> taskScreenStatusChangedEvent(TaskScreenStatusChangedEvent event, Emitter<ProjectDetailsState> emit) async {
    try{
      await FirebaseApi.updateTaskStatus(event.projectId, event.taskId, event.status);
      emit(TaskStatusUpdatedNavBackBtnState());

    }catch (e){
      emit(ProjectDetailsErrorState(error: e.toString()));
    }
  }

  FutureOr<void> taskDeleteBtnEvent(TaskDeleteBtnEvent event, Emitter<ProjectDetailsState> emit) async {
    try {
      await FirebaseApi.deleteTask(event.projectId, event.taskId);
      emit(TaskDeleteBtnNavState());
    } on Exception catch (e) {
      emit(ProjectDetailsErrorState(error: e.toString()));
    }
  }


  FutureOr<void> taskEmptyFieldsEvent(TaskEmptyFieldsEvent event, Emitter<ProjectDetailsState> emit) {
    emit(TaskEmptyFieldsState());
  }
}
