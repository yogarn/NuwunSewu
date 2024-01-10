import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/screens/home/profile_picture.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';

class Profile extends StatefulWidget {
  final bool isRedirected;
  Profile({required this.isRedirected});

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

  int followingCount = 0;
  int followerCount = 0;

  @override
  void initState() {
    super.initState();

    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    getFollowingCount(currentUserID).then((count) {
      setState(() {
        followingCount = count;
      });
    });

    getFollowerCount(currentUserID).then((count) {
      setState(() {
        followerCount = count;
      });
    });
  }

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
                leading: widget.isRedirected
                    ? IconButton(
                        icon: Icon(Icons.arrow_back),
                        tooltip: 'Back',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    : null,
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
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Center(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: userCollection
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            if (snapshot.hasData && snapshot.data!.exists) {
                              Map<String, dynamic> userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              if (userData['profilePicture'] !=
                                  "defaultProfilePict") {
                                return CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                    userData['profilePicture'],
                                  ),
                                );
                              }
                              return CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage(
                                  'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain',
                                ),
                              );
                            }
                            return Text('Dokumen tidak ditemukan');
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            margin: EdgeInsets.all(10),
                            child: Text('${followerCount} Follower')),
                        Container(
                            margin: EdgeInsets.all(10),
                            child: Text('${followingCount} Following')),
                      ],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      child: const Text('Edit Profile Picture'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePicture()),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('');
                          } else {
                            User? user = snapshot.data;
                            return Container(
                              margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: Text(
                                      'Alamat Email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  Container(child: Text(':   ${user!.email}')),
                                ],
                              ),
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
                        return Text('');
                      }
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
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child:
                                        Text(":   ${userData['namaLengkap']}"),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: Text(
                                      'Username',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Text(":   ${userData['username']}"),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: Text(
                                      'Jenis Kelamin',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  Container(child: Text(':   $gender')),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    child: Text(
                                      'Umur',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                  Container(child: Text(':   $umur')),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return Text('Dokumen tidak ditemukan');
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
