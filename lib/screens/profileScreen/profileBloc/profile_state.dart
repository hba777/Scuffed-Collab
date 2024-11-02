part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

abstract class ProfileActionState extends ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileSuccessState extends ProfileState {}

class ProfileErrorState extends ProfileState {
  final String error;

  ProfileErrorState({required this.error});
}
class ProfileUpdatePfPState extends ProfileActionState {}

class ProfileUpdatePfpImageState extends ProfileState {
  final String image;

  ProfileUpdatePfpImageState({required this.image});
}
class ProfileEditBtnPressedState extends ProfileState {}

class ProfileEditButtonNavigationState extends ProfileActionState {}

class ProfileLogoutButtonNavigationState extends ProfileActionState {}

class ProfileLogoutButtonPressedState extends ProfileState {}