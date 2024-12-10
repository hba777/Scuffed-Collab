import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:scuffed_collab/models/TeamModel.dart';
import 'package:scuffed_collab/repos/FirebaseApi.dart';
part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<ProjectInitialEvent>(projectInitialEvent);
    on<ProjectBackBtnEvent>(projectBackBtnEvent);
    on<ProjectTeamMemberScreenLoadedEvent>(projectTeamMemberScreenLoadedEvent);
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
  FutureOr<void> projectBackBtnEvent(ProjectBackBtnEvent event, Emitter<ProjectState> emit) {
    teamMembers.clear();
    emit(ProjectBackBtnNavState());
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

      if (member != null) {
        // Check if the member is already in the teamMembers list
        if (!teamMembers.any((m) => m.email == member.email)) {
          teamMembers.add(member);
          emit(ProjectTeamMemberAdded(teamMembers));
        } else {
          emit(ProjectMemberAlreadyExistsState());
        }
      } else {
        emit(ProjectTeamMemberNotExistState());
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

  FutureOr<void> projectTeamMemberScreenLoadedEvent(ProjectTeamMemberScreenLoadedEvent event, Emitter<ProjectState> emit) {
    // Add the current user (me) as a team member only if they are not already in the list
    final TeamMember currentUserAsMember = TeamMember(
      id: FirebaseApi.me.id, // Assuming me.id is the user's ID
      name: FirebaseApi.me.Name, // Assuming me.name is the user's name
      email: FirebaseApi.me.Email, // Assuming me.email is the user's email
      profilePicture: FirebaseApi.me.Image, // Assuming me.profilePicture exists
      pushToken: FirebaseApi.me.pushToken ?? '', // Assuming me.pushToken may be null
      isOnline: true, // You can set isOnline to true by default
    );
    teamMembers.add(currentUserAsMember);
    emit(ProjectTeamMemberAdded(teamMembers));
  }
}
