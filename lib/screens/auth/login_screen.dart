import 'dart:io';
import 'dart:math';
import 'package:connect/api/apis.dart';
import 'package:connect/helper/dialogs.dart';
import 'package:connect/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  _handleGoogleBtnClick(){
    //For Showing Progress Bar
    Dialogs.showProgessBar(context);

    _signInWithGoogle().then((user)async{
      //For Hiding Progress Bar
      Navigator.pop(context);
      if(user != null) {
        print('\n\nUser: ${user.user}');
        print('\n\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if((await APIs.userExists())) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }


      }

    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
   try{
     await InternetAddress.lookup('google.com');
     // Trigger the authentication flow
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

     // Obtain the auth details from the request
     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

     // Create a new credential
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth?.accessToken,
       idToken: googleAuth?.idToken,
     );

     // Once signed in, return the UserCredential
     return await APIs.auth.signInWithCredential(credential);
   } catch(e){
     print('\n_signInWithGoogle : $e');
     Dialogs.showSnackBar(context, 'Something went '
         'wrong, Check Internet!');
     return null;
   }
  }

  //Sign Out Function
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _isAnimate = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    //Initializing Media Query for getting devise screen size
   // mq = MediaQuery.of(context).size;

    return Scaffold(
      //AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to Connect"),
      ),

      body: Stack(
        children: [
          //Logo Image
          Positioned(
              top: mq.height * .15,
              width: mq.width * .5,
              right: mq.width * .28,
              //right: _isAnimate ? mq.width * .28 : -mq.width * .5,
             // duration: const Duration(seconds: 1),
              child: Image.asset('images/logo-pic.png')),

          //Sign in with Google Button
          Positioned(
              bottom: mq.height * .15,
              width: mq.width * .9,
              left: mq.width * .05,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                onPressed: (){
                  _handleGoogleBtnClick();
                },
                  icon: Image.asset('images/google.png',
                  height: mq.height * .04,
                  ),
                  label: RichText(text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: [
                    TextSpan(text: 'Login with'),
                    TextSpan(text: ' Google',
                    style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ])),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: const StadiumBorder(),
                    elevation: 1,
                  ),


              )
          )],
      ),
    );
  }
}

