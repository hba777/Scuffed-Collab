import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../repos/FirebaseApi.dart';
import '../auth/login_screen.dart';
import '../homeScreen/ui/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    //Navigate to homeScreen
    Future.delayed(const Duration(seconds:2),(){

      //Newer Android Issues Fix fullscreen and Nav Bar Color
      //Exit FullScreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF111111),
          statusBarColor: Color(0xFF111111)
      ));

      if(FirebaseApi.auth.currentUser != null){
        log('\nUser: ${FirebaseApi.auth.currentUser}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)
        => const HomeScreen()));
      } else
      {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)
        => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .2,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('assets/images/Headphone.png',color: Colors.white,)),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width * 1,
              child:
              const Text('Scuffed Collab',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ))
        ],
      ),
    );
  }
}
