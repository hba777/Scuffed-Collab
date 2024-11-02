import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scuffed_collab/screens/auth/loginBloc/login_bloc.dart';
import '../../helper/dailogs.dart';
import '../../main.dart';
import '../homeScreen/ui/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  final LoginBloc loginBloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    loginBloc.add(LoginInitialEvent());
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return BlocConsumer<LoginBloc, LoginState>(
      bloc: loginBloc,
      listenWhen: (previous, current) => current is LoginActionState,
      buildWhen: (previous, current) => current is !LoginActionState,
  listener: (context, state) {
    // TODO: implement listener

    if (state is LoginUserExistsState) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)
      => const HomeScreen()));
    } else if (state is LoginCreateUserState) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)
      => const HomeScreen()));
    } else if (state is LoginErrorState) {
      Navigator.pop(context);
      Dialogs.showSnackBar(context, state.error);
    }
  },
  builder: (context, state) {
        switch(state.runtimeType) {
          case LoginSuccessState:
            final successState = state as LoginSuccessState;
            bool isLoading = state is LoginLoadingState;
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: const Text(
                  "Scuffed Collab",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
              body: Stack(
                children: [
                  AnimatedPositioned(
                      duration: const Duration(seconds: 1),
                      top: mq.height * .15,
                      left: _isAnimate ? mq.width * .245 : -mq.width * .5,
                      width: mq.width * .5,
                      child: Image.asset('assets/images/Headphone.png',color: Colors.white,)),
                  Positioned(
                      bottom: mq.height * .07,
                      left: mq.width * .15,
                      width: mq.width * .7,
                      height: mq.height * .06,
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[300],
                              shape: const StadiumBorder(),
                              elevation: 1),
                          onPressed: isLoading ? null : () {
                            loginBloc.add(LoginButtonActionEvent());
                            Dialogs.showProgressBar(context);
                          },
                          icon:
                          Image.asset('assets/images/google.png', height: mq.height * .03),
                          label: RichText(
                              text: const TextSpan(
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                  children: [
                                    TextSpan(text: 'Sign In With'),
                                    TextSpan(
                                        text: ' Google',
                                        style: TextStyle(fontWeight: FontWeight.bold))
                                  ]))))
                ],
              ),
            );
          default:
            return SizedBox();
        }

  },
);
  }
}
