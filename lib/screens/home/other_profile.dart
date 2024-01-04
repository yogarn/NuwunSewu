import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/screens/home/profile_picture.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:nuwunsewu/shared/loading.dart';

class OtherProfile extends StatefulWidget {
  final uidSender;
  OtherProfile({required this.uidSender});
  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
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
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
                    // handle the press
                    Navigator.pop(context);
                  },
                ),
                title: Text('Detail Profile'),
                backgroundColor: Colors.purple[100],
                elevation: 0.0,
              ),
              body: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Center(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream:
                            userCollection.doc(widget.uidSender).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // or some loading indicator
                          } else {
                            if (snapshot.hasData && snapshot.data!.exists) {
                              Map<String, dynamic> userData =
                                  snapshot.data!.data() as Map<String, dynamic>;

                              // Check if the 'profilePicture' field is not empty
                              if (userData['profilePicture'] !=
                                  "defaultProfilePict") {
                                return CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                    userData['profilePicture'],
                                  ),
                                );
                              } else {
                                // Use a default image if 'profilePicture' is empty
                                return CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                    'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain', // Default image
                                  ),
                                );
                              }
                            } else {
                              return Text('Dokumen tidak ditemukan');
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: userCollection.doc(widget.uidSender).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('');
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