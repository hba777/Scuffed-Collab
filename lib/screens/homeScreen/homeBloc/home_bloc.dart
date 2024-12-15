import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:scuffed_collab/models/ProjectsModel.dart';
import 'package:scuffed_collab/repos/FirebaseApi.dart';

import '../../../models/UserModel.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(homeInitialEvent);
    on<HomeUpdateActiveStatusEvent>(homeUpdateActiveStatusEvent);
    on<HomeLifecycleChangeEvent>(homeLifecycleChangeEvent);
    on<HomeCreateProjectEvent>(homeCreateProjectEvent);
    on<HomeProjectClickedEvent>(homeProjectClickedEvent);
    on<HomeProfileButtonEvent>(homeProfileButtonEvent);
    on<HomeFilterProjectsEvent>(homeFilterProjectsEvent);

  }
  List<Projects> projects = [];

  FutureOr<void> homeInitialEvent(HomeInitialEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoadingState());
      await FirebaseApi.getSelfInfo();
      // Fetch the projects from Firestore
      projects = await FirebaseApi.getAllProjects();
      emit(HomeSuccessState(user: FirebaseApi.me, projects: projects));
    } catch (e) {
      // TODO
      emit(HomeErrorState(error: e.toString()));
    }
  }

  FutureOr<void> homeUpdateActiveStatusEvent(HomeUpdateActiveStatusEvent event, Emitter<HomeState> emit) async {
    try{

      await FirebaseApi.updateActiveStatus(event.isOnline);
      log('\nEvent ${event.isOnline}');

    } catch (e){
      emit(HomeErrorState(error: e.toString()));
    }
  }

  FutureOr<void> homeLifecycleChangeEvent(HomeLifecycleChangeEvent event, Emitter<HomeState> emit) {
    if (event.lifecycleState.contains('pause')) {
      emit(HomeLifecyclePauseState());
      log('Paused - Setting online status to false');
    } else if (event.lifecycleState.contains('resume')) {
      emit(HomeLifecycleStartState());
      log('Resumed - Setting online status to true');
    }
  }

  FutureOr<void> homeFilterProjectsEvent(HomeFilterProjectsEvent event, Emitter<HomeState> emit) {
    final filteredProjects = projects.where((project) {
      return project.title.toLowerCase().contains(event.query.toLowerCase());
    }).toList();
    emit(HomeSuccessState(user: FirebaseApi.me, projects: filteredProjects));
  }

  FutureOr<void> homeCreateProjectEvent(HomeCreateProjectEvent event, Emitter<HomeState> emit) {
    emit((HomeProjectNavigationState()));
  }

  FutureOr<void> homeProjectClickedEvent(HomeProjectClickedEvent event, Emitter<HomeState> emit) {
    emit(HomeProjectClickedNavigationState(clickedProject: event.clickedProject));
  }

  FutureOr<void> homeProfileButtonEvent(HomeProfileButtonEvent event, Emitter<HomeState> emit) {
    emit(HomeProfileNavigationState(user: event.user));
  }
}
