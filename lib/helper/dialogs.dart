import 'package:flutter/material.dart';

class Dialogs{

  static  void showSnackBar(BuildContext context, String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.black),),

    backgroundColor: Colors.yellowAccent.withOpacity(.8),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static  void showProgessBar(BuildContext context){
    showDialog(context: context, builder: (_) =>  const Center(child: CircularProgressIndicator()));
  }

}