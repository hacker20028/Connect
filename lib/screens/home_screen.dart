import 'dart:convert';
import 'dart:developer';

import 'package:connect/screens/profile_screen.dart';
import 'package:connect/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();


    // For updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if(APIs.auth.currentUser != null) {
        if(message.toString().contains('resume')) APIs.updateActiveStatus(true);
        if(message.toString().contains('pause')) APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // For Hiding keyboard when tapped on screen
      onTap: () => Focus.of(context).unfocus(),
      child: WillPopScope(
        // If search is on & back is pressed then close only search
        // or else simply close current screen on back button click
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }

        },
        child: Scaffold(
          //AppBar
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching ? TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Name or Email'
              ),
              autofocus: true,
              style: TextStyle(fontSize: 17,
              letterSpacing: 0.5),
              // When search text changes then update search list
              onChanged: (val){
                // Search Logic
                _searchList.clear();

                for (var i in _list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }

              },
            ) : Text("Connect"),
            actions: [
              //Search Icon Button
              IconButton(onPressed: (){
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search)),
              //More Options Icon Button
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me,)));
              }, icon: const Icon(Icons.more_vert)),
            ],
          ),

          //Floating Button Icon to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: FloatingActionButton(onPressed: () {
              _addChatUserDialog();
            },
              child: const Icon(Icons.add_circle_outline),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getMyUserId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
              //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

              //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                   return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: Row(
            children: const [
              Icon(
                Icons.person_add,
                color: Colors.deepOrange,
                size: 28,
              ),
              Text(' Add User')
            ],
          ),

          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon: const Icon(Icons.email, color: Colors.deepOrange),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.deepOrange, fontSize: 16))),

            //add button
            MaterialButton(
                onPressed: () async {
                  //hide alert dialog
                  Navigator.pop(context);
                  if (email.isNotEmpty) {
                    await APIs.addChatUser(email).then((value) {
                      if (!value) {
                        Dialogs.showSnackBar(
                            context, 'User does not Exists!');
                      }
                    });
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.deepOrange, fontSize: 16),
                ))
          ],
        ));
  }
}

