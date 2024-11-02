import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'FirebaseApi.dart';

class GoogleApi{

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      //Dialogs.showSnackBar(context, 'Something went wrong Check Internet');
      return null;
    }
  }

  Future<GoogleSignInAccount?> signOutGoogle() async {
    try{
      await GoogleSignIn().signOut();
      log('Logged Out from Google');
    }catch (e) {
      log(e.toString());
    }
    return null;
  }

}