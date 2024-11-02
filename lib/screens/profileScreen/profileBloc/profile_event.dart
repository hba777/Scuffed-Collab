part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class ProfileInitialEvent extends ProfileEvent {
  final UserModel user;
  ProfileInitialEvent({required this.user});
}

class ProfileEditNameEvent extends ProfileEvent {
  final String newName;
  ProfileEditNameEvent({required this.newName});
}

class ProfileEditAboutEvent extends ProfileEvent {
  final String newAbout;
  ProfileEditAboutEvent({required this.newAbout});
}

class ProfileEditGalleryPfpEvent extends ProfileEvent {
  final XFile newPfp;
  ProfileEditGalleryPfpEvent({required this.newPfp});
}

class ProfileLogoutEvent extends ProfileEvent {}
