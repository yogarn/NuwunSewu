import 'package:cloud_firestore/cloud_firestore.dart';
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
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userData');
  bool loading = false;

  String gender = "";
  num umur = 0;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
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
                      setState(() {
                        loading = true;
                      });
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
                      // Text('Login Sebagai : '),
                      StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...');
                          } else {
                            User? user = snapshot.data;
                            return Container(
                              margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child:
                                  // Text(user?.uid ?? 'Not logged in'),
                                  Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: Text(
                                      'Alamat Email',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    child: Text(':'),
                                  ),
                                  Container(
                                      child: Text(user?.email ??
                                          'Error: Email tidak ada!')),
                                ],
                              ), //berhasil
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: userCollection
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      } else {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          Map<String, dynamic> userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          if (userData['gender'] == 0) {
                            gender = "Lainnya";
                          } else if (userData['gender'] == 1) {
                            gender = "Pria";
                          } else if (userData['gender'] == 2) {
                            gender = "Wanita";
                          }

                          try {
                            umur = 2023 - userData['tahunLahir'];
                            print('Umur: $umur tahun');
                          } catch (e) {
                            print('Error parsing tahunLahir: $e');
                          }

                          return Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      child: Text(
                                        'Nama',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                      child: Text(':'),
                                    ),
                                    Container(
                                        child: Text(userData['namaLengkap'])),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      child: Text(
                                        'Username',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                      child: Text(':'),
                                    ),
                                    Container(
                                        child: Text(userData['username'])),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      child: Text(
                                        'Jenis Kelamin',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                      child: Text(':'),
                                    ),
                                    Container(child: Text(gender)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      child: Text(
                                        'Umur',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                      child: Text(':'),
                                    ),
                                    Container(child: Text(umur.toString())),
                                  ],
                                ),
                              ],
                            ),
                          );
                          // Gantilah 'nama' dengan nama field yang sesuai di dokumen Anda
                        } else {
                          return Text('Dokumen tidak ditemukan');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
