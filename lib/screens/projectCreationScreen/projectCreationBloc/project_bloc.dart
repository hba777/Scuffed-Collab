import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:scuffed_collab/models/TeamModel.dart';
import 'package:scuffed_collab/repos/FirebaseApi.dart';
import 'package:scuffed_collab/screens/profileScreen/profileBloc/profile_bloc.dart';

import '../../../models/ProjectsModel.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<ProjectInitialEvent>(projectInitialEvent);
    on<ProjectDetailsSubmittedEvent>(projectDetailsSubmitted);
    on<ProjectMemberAddedEvent>(projectMemberAdded);
    on<ProjectIncompleteDetailsSubmittedEvent>(projectIncompleteDetailsSubmittedEvent);
    on<ProjectDeadlineSelectedEvent>(projectDeadlineSelectedEvent);
    on<ProjectCreateButtonEvent>(projectCreateButtonEvent);
    on<ProjectTitleChangedEvent>(projectTitleChanged);
    on<ProjectDescriptionChangedEvent>(projectDescriptionChanged);
  }

  List<TeamMember> teamMembers = [];

  // Fields to store title and description
  String title = '';
  String description = '';

  //Project Details Event
  FutureOr<void> projectDetailsSubmitted(ProjectDetailsSubmittedEvent event, Emitter<ProjectState> emit) async {
    emit(ProjectSubmittingState());
    try {
      // Here you would normally save the project to Firebase
      //await FirebaseApi.createProject(event.project);
      log('Project Submitted');
      emit(ProjectSubmittedState(
          title: event.title,
          deadline: event.deadline,
          description: event.description));

    } catch (e) {
      emit(ProjectErrorState(e.toString()));
    }
  }

  FutureOr<void> projectInitialEvent(ProjectInitialEvent event, Emitter<ProjectState> emit) {
    emit(ProjectSuccessState());
  }

  FutureOr<void> projectIncompleteDetailsSubmittedEvent(ProjectIncompleteDetailsSubmittedEvent event, Emitter<ProjectState> emit) {
    emit(ProjectIncompleteDetailsSubmittedState(message: 'Please fill out all fields'));
  }

  FutureOr<void> projectDeadlineSelectedEvent(ProjectDeadlineSelectedEvent event, Emitter<ProjectState> emit) {
    emit(ProjectDeadlineSubmittedState(deadline: event.deadline));
    log('Deadline selected');
  }

  FutureOr<void> projectMemberAdded(ProjectMemberAddedEvent event, Emitter<ProjectState> emit) async {
    try {
      TeamMember? member = await FirebaseApi.getTeamMemberByEmail(event.email);

      if (member != null && !teamMembers.any((m) => m.email == member.email)) {
        teamMembers.add(member);
        emit(ProjectTeamMemberAdded(teamMembers));
      } else if (member == null) {
        emit(ProjectTeamMemberNotExistState());
      } else {
        emit(ProjectMemberAlreadyExistsState());
      }
    } catch (e) {
      emit(ProjectErrorState(e.toString()));
    }
  }


  FutureOr<void> projectCreateButtonEvent(ProjectCreateButtonEvent event, Emitter<ProjectState> emit) async {
    try {
      if(teamMembers.isNotEmpty) {
        await FirebaseApi.createProject(event.title,
            event.description,
            event.deadline,
            teamMembers);
        emit(ProjectCreateButtonNavigationState());
      } else {
        emit(ProjectTeamEmptyState());
      }
    } catch (e) {
      emit(ProjectErrorState(e.toString()));
    }
  }

  FutureOr<void> projectTitleChanged(ProjectTitleChangedEvent event, Emitter<ProjectState> emit) {
    title = event.title;
  }

  FutureOr<void> projectDescriptionChanged(ProjectDescriptionChangedEvent event, Emitter<ProjectState> emit) {
    description = event.description;
  }
}
