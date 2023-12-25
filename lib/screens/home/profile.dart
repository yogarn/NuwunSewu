import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:nuwunsewu/shared/loading.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();
  bool loading = false;

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
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.purple[100],
          elevation: 0.0,
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                loading = true;
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text('Logout'),
            ),
          ],
        ),
        body: ListView(
          children: [
            Row(
              children: [
                Text('Login Sebagai : '),
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    } else {
                      User? user = snapshot.data;
                      return Text(user?.uid ?? 'Not logged in');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
