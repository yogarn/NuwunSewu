import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:nuwunsewu/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleSignIn;
  SignIn({required this.toggleSignIn});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // textfield state
  String email = "";
  String pass = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : MaterialApp(
      theme: ThemeData(
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          // ···
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Login Page"),
          backgroundColor: Colors.purple[100],
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
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: ListView(children: [
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'example@hackfest.id',
                  label: Text('Email Address'),
                ),
                validator: (val) => val!.isEmpty ? 'Masukkan email!' : null,
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Minimal 8 karakter',
                  label: Text('Password'),
                ),
                validator: (val) =>
                    val!.length < 8 ? 'Minimal password 8 karakter!' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    pass = val;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState != null) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        dynamic result =
                            await _auth.SignInWithEmailAndPassword(email, pass);
                        if (result == null) {
                          setState(() {
                            error = "Mohon maaf, periksa lagi kredensial anda!";
                            loading = false;
                          });
                        }
                      }
                    }
                  },
                  child: Text('Sign In')),
              SizedBox(
                height: 20,
              ),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
