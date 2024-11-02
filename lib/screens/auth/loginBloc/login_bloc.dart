import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:scuffed_collab/repos/GoogleApi.dart';

import '../../../repos/FirebaseApi.dart';


part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent,LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginInitialEvent>(loginInitialEvent);
    on<LoginButtonActionEvent>(loginButtonActionEvent);
  }

  FutureOr<void> loginButtonActionEvent(LoginEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState()); // Emit loading state

      // Attempt Google Sign-In
      final user = await GoogleApi().signInWithGoogle();

      if (user != null) {
        log('\nUser: ${FirebaseApi.auth.currentUser}');

        // Check if user exists in the Firebase database
        if (await FirebaseApi.userExists()) {
          emit(LoginUserExistsState()); // Emit state for existing user
        } else {
          // Create new user if not exists
          await FirebaseApi.createUser();
          emit(LoginCreateUserState()); // Emit state for newly created user
        }
      } else {
        throw FirebaseAuthException(
            code: "ERROR_ABORTED_BY_USER",
            message: "Sign-in process aborted by the user."
        );
      }
    } catch (error) {
      log('Error during Google Sign-In: $error');

      // Emit error state with error message
      emit(LoginErrorState(error: error.toString()));
    } finally {
      emit(LoginSuccessState()); // Emit success state regardless of the result
    }
  }

  FutureOr<void> loginInitialEvent(LoginInitialEvent event, Emitter<LoginState> emit) {
    emit(LoginSuccessState());
  }
}
