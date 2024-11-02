import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:scuffed_collab/models/UserModel.dart';
import 'package:scuffed_collab/repos/FirebaseApi.dart';
import 'package:scuffed_collab/repos/GoogleApi.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileInitialEvent>(profileInitialEvent);
    on<ProfileEditNameEvent>(profileEditNameEvent);
    on<ProfileEditAboutEvent>(profileEditAboutEvent);
    on<ProfileEditGalleryPfpEvent>(profileEditGalleryPfpEvent);
    on<ProfileLogoutEvent>(profileLogoutEvent);
  }

  FutureOr<void> profileInitialEvent(ProfileInitialEvent event, Emitter<ProfileState> emit) {
    emit(ProfileSuccessState());
  }

  FutureOr<void> profileEditNameEvent(ProfileEditNameEvent event, Emitter<ProfileState> emit) async {
    try {
      FirebaseApi.me.Name = event.newName;
      await FirebaseApi.updateUserInfo();
      log('Profile name updated to: ${event.newName}');
      emit(ProfileSuccessState());
    } catch (e) {
      emit(ProfileErrorState(error: e.toString()));
    }
  }

  FutureOr<void> profileEditAboutEvent(ProfileEditAboutEvent event, Emitter<ProfileState> emit) async {
    try {
      FirebaseApi.me.About = event.newAbout;
      await FirebaseApi.updateUserInfo();
      log('Profile about updated to: ${event.newAbout}');
      emit(ProfileSuccessState());
    } catch (e) {
      emit(ProfileErrorState(error: e.toString()));
    }
  }

  FutureOr<void> profileEditGalleryPfpEvent(ProfileEditGalleryPfpEvent event, Emitter<ProfileState> emit) async {
    // Handle profile picture update
    try {
      await FirebaseApi.updateProfilePicture(File(event.newPfp.path));
      log('PFP Updated');
      emit(ProfileUpdatePfPState());
      emit(ProfileUpdatePfpImageState(image: event.newPfp.path));
    }
    catch (e) {
      emit(ProfileErrorState(error: e.toString()));
    }
  }

  FutureOr<void> profileLogoutEvent(ProfileLogoutEvent event, Emitter<ProfileState> emit) async {
    try {
      // Updating Last Active Status when logged out
      await FirebaseApi.updateActiveStatus(false);

      // SignOut
      await FirebaseApi.auth.signOut().then((value) async {
        log('ProfileLogout: Firebase LoggedOut');
        await GoogleApi().signOutGoogle();

        // Store new data rather than old
        FirebaseApi.auth = FirebaseAuth.instance;

        emit(ProfileLogoutButtonNavigationState());
      });
    } catch (e) {
      emit(ProfileErrorState(error: e.toString()));
    }
  }
}
