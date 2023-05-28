import 'package:connect/api/apis.dart';
import 'package:connect/screens/auth/login_screen.dart';
import 'package:connect/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

import '../../main.dart';

//Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override


  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      //Exit Full Screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.amberAccent));

      if(APIs.auth.currentUser != null){
        log('\nUser: ${APIs.auth.currentUser}');
        //Navigate to Home Screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }else{
        //Navigate to Login Screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }


    });

  }

  @override
  Widget build(BuildContext context) {

    //Initializing Media Query for getting devise screen size
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          //Logo Image
          Positioned(
              top: mq.height * .15,
              width: mq.width * .5,
              right: mq.width * .28,
              child: Image.asset('images/logo-pic.png')),

          //Sign in with Google Button
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: const Text('Made with 🖤 by Aryan Wadher',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                letterSpacing: .5,
              ),
              )
          )],
      ),
    );
  }
}

