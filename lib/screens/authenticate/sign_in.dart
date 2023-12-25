import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/auth.dart';

class SignIn extends StatefulWidget {
  final Function toggleSignIn;
  SignIn({required this.toggleSignIn});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Login Page"),
          backgroundColor: Colors.amber,
          actions: [
            TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                onPressed: () => widget.toggleSignIn(),
                icon: Icon(Icons.person),
                label: Text('Register'))
          ],
        ),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "example@email.com",
                        labelText: "Email Address:",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "min 8 karakter/digit lur",
                        labelText: "Password:",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () async {
                        dynamic result = await _auth.signInAnon();
                        if (result == null) {
                          print('error sign in');
                        } else {
                          print('signed in');
                          print(result.uid);
                        }
                      },
                      child: Text('Sign In Anonymously'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
