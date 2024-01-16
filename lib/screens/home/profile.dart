import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/screens/home/other_profile.dart';
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

  ScrollController _scrollController = ScrollController();

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
              brightness: Brightness.dark,
            ),
            home: Scaffold(
              backgroundColor: Color(0xFF2e2b2b),
              appBar: AppBar(
                surfaceTintColor: Colors.transparent,
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
                backgroundColor: Color(0xFF131313),
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
                    icon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              body: StreamBuilder<DocumentSnapshot>(
                stream: userCollection
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      Map<String, dynamic> userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return ListView(
                        controller: _scrollController,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
                            child: Center(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CircleAvatar(
                                      radius: 72,
                                      backgroundImage: NetworkImage(
                                        userData['profilePicture'],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userData['namaLengkap'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0),
                                            ),
                                            Text(
                                              '@' + userData['username'],
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              flex: 1,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Following',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(followingCount
                                                      .toString()),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 40,
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Follower',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(followerCount.toString())
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                          child: const Text(
                                              'Edit Profile Picture'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ProfilePicture(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About Me',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                AboutMeWidget(userData: userData),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'My Works',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Works(context,
                                    FirebaseAuth.instance.currentUser!.uid),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return Text('Dokumen tidak ditemukan');
                  }
                },
              ),
            ),
          );
  }
}

class AboutMeWidget extends StatefulWidget {
  final Map<String, dynamic> userData;

  AboutMeWidget({required this.userData});

  @override
  _AboutMeWidgetState createState() => _AboutMeWidgetState();
}

class _AboutMeWidgetState extends State<AboutMeWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return widget.userData['aboutMe'].length > 100
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpanded
                        ? widget.userData['aboutMe']
                        : widget.userData['aboutMe'].substring(0, 100),
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (!isExpanded)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = true;
                        });
                      },
                      child: Text(
                        'View more...',
                        style: TextStyle(
                          color: Colors
                              .purple[100], // Ganti warna sesuai kebutuhan
                        ),
                      ),
                    ),
                  if (isExpanded)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = false;
                        });
                      },
                      child: Text(
                        'Hide',
                        style: TextStyle(
                          color: Colors
                              .purple[100], // Ganti warna sesuai kebutuhan
                        ),
                      ),
                    ),
                ],
              ),
            ],
          )
        : Text(widget.userData['aboutMe']);
  }
}
