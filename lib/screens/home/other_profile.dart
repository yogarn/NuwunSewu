import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/screens/chats/view_chat.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/screens/home/view_category.dart';
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

  ScrollController _scrollController = ScrollController();

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

  bool isExpanded = false;

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
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text('Detail Profile'),
                backgroundColor: Color(0xFF131313),
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
                        controller: _scrollController,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
                            child: Center(
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: CircleAvatar(
                                      radius: 72,
                                      backgroundImage: NetworkImage(
                                        userData['profilePicture'],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Column(
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
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Column(
                                                children: [],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 40,
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Column(
                                                children: [
                                                  
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
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
                                                  ElevatedButton(
                                                    child: Text('Chat'),
                                                    onPressed: () async {
                                                      String currentUserID =
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid;
                                                      String otherUserID =
                                                          widget.uidSender;
                                                      await startNewChat(
                                                          currentUserID,
                                                          otherUserID);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
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
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Follower',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(followerCount.toString()),
                                                  ElevatedButton(
                                                      onPressed:
                                                          _toggleFollowAccount,
                                                      child: Text(isFollowing
                                                          ? 'Following'
                                                          : 'Follow')),
                                                ],
                                              ),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isExpanded
                                          ? userData['aboutMe']
                                          : userData['aboutMe']
                                              .substring(0, 100),
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
                                            color: Colors.purple[
                                                100], // Ganti warna sesuai kebutuhan
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
                                            color: Colors.purple[
                                                100], // Ganti warna sesuai kebutuhan
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
            ),
          );
  }
}

Widget Works(BuildContext context, String uidTarget) {
  return DefaultTabController(
    length: 3,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: TabBar(tabs: [
            Tab(text: "All Posts"),
            Tab(text: "Categorized"),
            Tab(text: "Repost"),
          ]),
        ),
        Container(
          //Add this to give height
          height: MediaQuery.of(context).size.height,
          child: TabBarView(children: [
            AllWorks(
              uidTarget: uidTarget,
            ),
            CategorizedWorks(
              uidTarget: uidTarget,
            ),
            RepostWorks(
              uidTarget: uidTarget,
            )
          ]),
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
                        imagePaths: [],
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
              return Container();
            }
          },
        );
      },
    );
  }
}

class CategorizedWorks extends StatefulWidget {
  final String uidTarget;
  CategorizedWorks({required this.uidTarget});

  @override
  _CategorizedWorksState createState() => _CategorizedWorksState();
}

class _CategorizedWorksState extends State<CategorizedWorks> {
  // Fungsi untuk mendapatkan kategori berdasarkan uidSender
  Future<List<String>> getKategoriByUid(String uidSender) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('postingan')
          .where('uidSender', isEqualTo: uidSender)
          .get();

      List<String> kategoriList = [];

      querySnapshot.docs.forEach((doc) {
        var kategori = doc['kategori'];
        if (kategori != null) {
          kategoriList.add(kategori);
        }
      });

      return kategoriList;
    } catch (error) {
      print('Error getting kategori: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getKategoriByUid(widget.uidTarget),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<String> kategoriList = snapshot.data ?? [];

          // Tampilkan kategoriList dalam ListView
          return ListView.builder(
            itemCount: kategoriList.length,
            itemBuilder: (context, index) {
              // Gunakan InkWell untuk menangani ketika pengguna mengetuk kategori
              return InkWell(
                onTap: () {
                  // Navigasi atau lakukan tindakan yang diinginkan ketika kategori ditekan
                  print('Kategori ${kategoriList[index]} ditekan!');
                  // Misalnya, navigasi ke halaman detail kategori
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewCategory(
                        kategori: kategoriList[index],
                        uidTarget: widget.uidTarget,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(kategoriList[index]),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class RepostWorks extends StatefulWidget {
  final String uidTarget;
  RepostWorks({required this.uidTarget});

  @override
  _RepostWorksState createState() => _RepostWorksState();
}

class _RepostWorksState extends State<RepostWorks> {
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

            // If postingan is a repost, check if the current user (your UID) reposted it
            var repostsCollection = post.reference.collection('reposts');
            var currentUserUid = widget.uidTarget;

            return FutureBuilder<QuerySnapshot>(
              future: repostsCollection.get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> repostsSnapshot) {
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
                  var title = post['title'];
                  var body = post['body'];
                  List<String>? imagePaths = [];
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
          },
        );
      },
    );
  }
}
