import 'package:flutter/material.dart';
import 'package:nuwunsewu/screens/authenticate/register.dart';
import 'package:nuwunsewu/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  void toggleSignIn() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    print(showSignIn);
    if (showSignIn) {
      return SignIn(toggleSignIn: toggleSignIn);
    } else {
      return Register(toggleSignIn: toggleSignIn);
    }
  }
}