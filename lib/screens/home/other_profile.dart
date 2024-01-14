import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/screens/chats/view_chat.dart';
import 'package:nuwunsewu/screens/home/home.dart';
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
        followerCount = count;
      });
    });

    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    db.hasUserFollowAccount(widget.uidSender, currentUserID).then((following) {
      setState(() {
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

      // print(widget.uidSender);
      // print(followerCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text('Detail Profile'),
              backgroundColor: Colors.purple[100],
              elevation: 0.0,
            ),
            body: StreamBuilder<DocumentSnapshot>(
              stream: userCollection.doc(widget.uidSender).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    Map<String, dynamic> userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return ListView(
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
                                                Text(followingCount.toString()),
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: ElevatedButton(
                                              child: Text('Kirim Pesan'),
                                              onPressed: () async {
                                                String currentUserID =
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid;
                                                String otherUserID =
                                                    widget.uidSender;
                                                await startNewChat(
                                                    currentUserID, otherUserID);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewChat(
                                                            chatID: generateChatID(
                                                                currentUserID,
                                                                otherUserID),
                                                            senderID:
                                                                currentUserID,
                                                            targetUserID:
                                                                otherUserID,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Flexible(
                                            child: ElevatedButton(
                                                onPressed: _toggleFollowAccount,
                                                child: Text(isFollowing
                                                    ? 'Following'
                                                    : 'Follow')),
                                          ),
                                        ],
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
                              Text(userData['aboutMe'] == null
                                  ? ''
                                  : userData['aboutMe']),
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
                              Works(context, widget.uidSender),
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
          );
  }
}

Widget Works(BuildContext context, String uidTarget) {
  return DefaultTabController(
    length: 2,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: TabBar(tabs: [
            Tab(text: "All Posts"),
            Tab(text: "Categorized"),
          ]),
        ),
        Container(
          //Add this to give height
          height: MediaQuery.of(context).size.height,
          child: TabBarView(children: [AllWorks(uidTarget: uidTarget,), CategorizedWorks()]),
        ),
      ],
    ),
  );
}

class AllWorks extends StatefulWidget {
  final String uidTarget;
  AllWorks({required this.uidTarget});

  @override
  _AllWorksState createState() => _AllWorksState();
}

class _AllWorksState extends State<AllWorks> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('postingan')
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var post = snapshot.data!.docs[index];
            var uidSender = post['uidSender'];

            // cek uid pengirim sama dgn uid user
            if (uidSender == widget.uidTarget) {
              var title = post['title'];
              var body = post['body'];
              List<String>? imagePaths =
                  (post['imagePaths'] as List<dynamic>).cast<String>();
              var dateTime = post['dateTime'];
              DateTime parsedDateTime =
                  dateTime != null ? dateTime.toDate() : DateTime.now();
              var postID = (snapshot.data!.docs[index].id);

              return FutureBuilder<String>(
                future: getNamaLengkap(uidSender),
                builder: (context, namaLengkapSnapshot) {
                  if (namaLengkapSnapshot.hasError) {
                    return Text(
                        'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                  }

                  var namaLengkap = namaLengkapSnapshot.data ?? 'null';

                  return FutureBuilder<String>(
                    future: getProfilePicture(uidSender),
                    builder: (context, profilePictureSnapshot) {
                      if (profilePictureSnapshot.hasError) {
                        return Text(
                            'Error fetching profilePicture: ${profilePictureSnapshot.error}');
                      }

                      var profilePicture = (profilePictureSnapshot.data ==
                                  'defaultProfilePict'
                              ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                              : profilePictureSnapshot.data) ??
                          'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

                      return PostWidget(
                        title: title,
                        body: body,
                        imagePaths: imagePaths,
                        uidSender: uidSender,
                        dateTime: parsedDateTime,
                        namaLengkap: namaLengkap,
                        profilePicture: profilePicture,
                        postID: postID,
                      );
                    },
                  );
                },
              );
            } else {
              // If postingan is a repost, check if the current user (your UID) reposted it
              var repostsCollection = post.reference.collection('reposts');
              var currentUserUid = widget.uidTarget;

              return FutureBuilder<QuerySnapshot>(
                future: repostsCollection.get(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> repostsSnapshot) {
                  if (repostsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container();
                  }

                  if (repostsSnapshot.hasError) {
                    return Text('Error: ${repostsSnapshot.error}');
                  }

                  // Check if the current user's UID has a corresponding document in the reposts subcollection
                  var currentUserRepost = repostsSnapshot.data!.docs
                      .any((repostDoc) => repostDoc.id == currentUserUid);

                  // If the current user reposted this post, fetch the reposted post details and display
                  if (currentUserRepost) {
                    // Get the ID of the reposted post
                    // var repostedPostId = repostsSnapshot.data!.docs.first
                    //     .id; // ini mengembalikan uid, bukan post id
                    print('kerefresh');

                    var title = post['title'];
                    var body = post['body'];
                    List<String>? imagePaths =
                        (post['imagePaths'] as List<dynamic>).cast<String>();
                    var dateTime = post['dateTime'];
                    DateTime parsedDateTime =
                        dateTime != null ? dateTime.toDate() : DateTime.now();
                    var postID = (snapshot.data!.docs[index].id);

                    return FutureBuilder<String>(
                      future: getNamaLengkap(uidSender),
                      builder: (context, namaLengkapSnapshot) {
                        if (namaLengkapSnapshot.hasError) {
                          return Text(
                              'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                        }

                        var namaLengkap = namaLengkapSnapshot.data ?? 'null';

                        return FutureBuilder<String>(
                          future: getProfilePicture(uidSender),
                          builder: (context, profilePictureSnapshot) {
                            if (profilePictureSnapshot.hasError) {
                              return Text(
                                  'Error fetching profilePicture: ${profilePictureSnapshot.error}');
                            }

                            var profilePicture = (profilePictureSnapshot.data ==
                                        'defaultProfilePict'
                                    ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                                    : profilePictureSnapshot.data) ??
                                'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

                            return Column(
                              children: [
                                Text('You Reposted'),
                                PostWidget(
                                  title: title,
                                  body: body,
                                  imagePaths: imagePaths,
                                  uidSender: uidSender,
                                  dateTime: parsedDateTime,
                                  namaLengkap: namaLengkap,
                                  profilePicture: profilePicture,
                                  postID: postID,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  } else {
                    // If the current user did not repost this post, return an empty container
                    return Container();
                  }
                },
              );
            }
          },
        );
      },
    );
  }
}

class CategorizedWorks extends StatefulWidget {
  const CategorizedWorks({Key? key}) : super(key: key);

  @override
  _CategorizedWorksState createState() => _CategorizedWorksState();
}

class _CategorizedWorksState extends State<CategorizedWorks> {
  @override
  Widget build(BuildContext context) {
    return Text('test');
  }
}
