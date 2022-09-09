import 'package:flutter/material.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({Key? key}) : super(key: key);


  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginFormScreen> {
  bool currentState = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Widget Basic"),),
        body:  getBody(),
      ),
    );
  }

  Widget getBody(){

    return Checkbox(
      // value control wheather checkbox is selected or not
      value:  currentState,

      // onChange accept a function having prototype
      // fun(bool b){....}
      onChanged:
          (bool){
        // we are toggling the state of widget
        setState(() {
          currentState = !currentState;
        });

      },
    );


  }
}