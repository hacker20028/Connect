
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //AppBar
        appBar: AppBar(

          title: const Text("Profile"),

        ),

        //Floating Button Icon to Logout
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: FloatingActionButton.extended(onPressed: () async {
            // For Showing Progress Dialog
            Dialogs.showProgessBar(context);

            await APIs.updateActiveStatus(false);
            // Sign Out from the App
            await APIs.auth.signOut().then((value) async {
              await APIs.auth.signOut().then((value) {

              // For Hiding Progress dialog
              Navigator.pop(context);

              // For moving to Home Screen
              Navigator.pop(context);

              APIs.auth = FirebaseAuth.instance;

              // Replacing Home Screen with Login Screen
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => LoginScreen()));
              });

            });
          },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            backgroundColor: Colors.deepOrange,
          ),
        ),


        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(children: [
                // For Adding some space
                SizedBox(width: mq.width, height: mq.height * .03,),

                //User Profile Picture
                 Stack(
                   children: [
                     _image != null ?

                         // Local Image
                     ClipRRect(
                 borderRadius: BorderRadius.circular(mq.height * .1),
              child: Image.file(
                File(_image!),
                width: mq.height * .2,
                height: mq.height * .2,
                fit: BoxFit.cover,
                
              ),
            ) :
                     // Profile Picture
                     //Image form server
                     ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: CachedNetworkImage(
                        width: mq.height * .2,
                        height: mq.height * .2,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person, ),),
                      ),
                ),

                     // Edit Image Button
                     Positioned(
                       bottom: 0,
                       right: 0,
                       child: MaterialButton(onPressed: (){
                         _showBottomSheet();
                       },
                         elevation: 1,
                         shape: const CircleBorder(),
                         color: Colors.deepOrange,
                         child: const Icon(Icons.edit, color: Colors.white,),),
                     )
                   ],
                 ),

                // For Adding some space
                SizedBox(height: mq.height * .03,),

                // For Showing User Email
                Text(widget.user.email, style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16
                ),),

                // For Adding some space
                SizedBox(height: mq.height * .05,),

                // Name Input Field Section
                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (val) => APIs.me.name = val ?? '',
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.deepOrange,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'eg Aryan Wadher',
                    label: const Text('Name')
                  ),
                ),

                // For Adding some space
                SizedBox(height: mq.height * .02,),

                // About Input Field Section
                TextFormField(
                  initialValue: widget.user.about,
                  onSaved: (val) => APIs.me.about = val ?? '',
                  validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline, color: Colors.deepOrange,),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      hintText: 'eg Aryan Wadher',
                      label: const Text('About')
                  ),
                ),

                // For Adding some space
                SizedBox(height: mq.height * .05,),

                //Update Profile Button
                ElevatedButton.icon(
                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      _formKey.currentState!.save();
                      APIs.updateUserInfo().then((value) {
                        Dialogs.showSnackBar(context, 'Profile Updated Successfully!');
                      });
                      log('inside validator');
                    }
                  },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder(),
                  minimumSize: Size(mq.width * .5, mq.height * .06),
                  backgroundColor: Colors.deepOrange),
                  icon: const Icon(Icons.edit, size: 22,),
                  label: const Text('UPDATE', style: TextStyle(
                    fontSize: 16,
                  ),),
                ),
              ],),
            ),
          ),
        )
      ),
    );
  }

  // Bottom Sheet for picking a profile Picture for the user
  void _showBottomSheet(){
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20))),
        context: context,
        builder: (_){
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
        children: [
         const Text('Pick profile Picture',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),

          SizedBox(height: mq.height * .02,),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pick from Gallery Button
            ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              fixedSize: Size(mq.width * .3, mq.height * .15)
            ),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                // Pick an image.
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if(image != null){
                  log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                  setState(() {
                    _image = image.path;
                  });
                  APIs.updateProfilePicture(File(_image!));
                  // For Hiding Bottom Sheet
                  Navigator.pop(context);
                }

              },
                child: Image.asset('images/add-image.gif')),

            // Take image from camera button
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15)),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image.
                  final XFile? image =
                  await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if(image != null){
                    log('Image Path: ${image.path}');
                    setState(() {
                      _image = image.path;
                    });
                    APIs.updateProfilePicture(File(_image!));
                    // For Hiding Bottom Sheet
                    Navigator.pop(context);
                  }
                },
                child: Image.asset(
                'images/camera.gif'
            )),
          ]),
        ],
      );
    });
  }
}

