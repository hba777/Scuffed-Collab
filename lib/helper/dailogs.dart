import 'package:flutter/material.dart';

class Dialogs{

  static void showSnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: const TextStyle(color: Colors.white), // Keep the text white
      ),
      backgroundColor: const Color(0xFF111111), // Keep the background dark
      behavior: SnackBarBehavior.fixed, // Keep the floating behavior
      duration: const Duration(seconds: 2), // Keep the 2-second duration
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator(
          color: Colors.greenAccent,
        )));
  }
}