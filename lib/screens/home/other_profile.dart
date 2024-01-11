import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/screens/chats/view_chat.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';

class OtherProfile extends StatefulWidget {
  final uidSender;
  OtherProfile({required this.uidSender});
  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userData');
  bool loading = false;

  StoreData db = StoreData();

  String gender = "";
  num umur = 0;

  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  final Duration _debounceDuration = Duration(milliseconds: 500);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    getFollowingCount(widget.uidSender).then((count) {
      setState(() {
        followingCount = count;
      });
    });

    getFollowerCount(widget.uidSender).then((count) {
      setState(() {
        // print(count);
        followerCount = count;
      });
    });

    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    db.hasUserFollowAccount(widget.uidSender, currentUserID).then((following) {
      setState(() {
        print(following);
        isFollowing = following;
      });
    });
  }

  Future<void> _toggleFollowAccount() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      final currentUserID = FirebaseAuth.instance.currentUser!.uid;

      if (isFollowing) {
        setState(() {
          followerCount -= 1;
          isFollowing = false;
        });
        await db.unfollowAccount(widget.uidSender, currentUserID);
      } else {
        setState(() {
          followerCount += 1;
          isFollowing = true;
        });
        await db.followAccount(widget.uidSender, currentUserID);
      }

      print(isFollowing);
      print(followerCount);
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
                              } else {
                                return CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                    'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain',
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
                  Container(
                    margin: EdgeInsets.all(10),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 10),
                        child: ElevatedButton(
                          child: Text('Kirim Pesan'),
                          onPressed: () async {
                            String currentUserID = FirebaseAuth
                                .instance
                                .currentUser!
                                .uid;
                            String otherUserID = widget
                                .uidSender;
                            await startNewChat(currentUserID, otherUserID);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewChat(chatID: generateChatID(currentUserID, otherUserID), senderID: currentUserID, targetUserID: otherUserID,)
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                          child: ElevatedButton(
                              onPressed: _toggleFollowAccount,
                              child: isFollowing
                                  ? Text('Following')
                                  : Text('Follow'))),
                    ],
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
