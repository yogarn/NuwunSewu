import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:nuwunsewu/shared/loading.dart';

List<String> genderList = [
  "Laki-laki",
  "Perempuan",
  "Tidak Memilih"
]; // initialize list untuk gender

class Register extends StatefulWidget {
  final Function toggleSignIn;
  Register({required this.toggleSignIn});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String genderValue =
      genderList.first; // default value untuk gender => laki-laki

  String email = "";
  String pass = "";
  String error = "";

  void kirimData() {
    // uji coba
  }

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
          title: Text("Sign Up Page"), // judul appbar
          backgroundColor: Colors.purple[100],
          actions: [
            TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                onPressed: () => widget.toggleSignIn(),
                icon: Icon(Icons.person),
                label: Text('Sign In'))
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
                validator: (val) => val!.length < 8 ? 'Minimal password 8 karakter!' : null,
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
              ElevatedButton(onPressed: () async {
                if (_formKey.currentState != null) {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    dynamic result = await _auth.registerWithEmailAndPassword(email, pass);
                    if (result == null) {
                      setState(() {
                        error = "Mohon maaf, periksa email anda dan coba lagi nanti.";
                        loading = false;
                      });
                    }
                  }
                }
              }, child: Text('Register')),
              SizedBox(height: 20,),
              Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0),)
            ]),
          ),
        ),
      ),
    );
  }
}
