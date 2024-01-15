import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/screens/home/other_profile.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/post/post.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/services/utils.dart';

class Home extends StatelessWidget {
  const Home({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'For You'),
                Tab(text: 'Following'),
                Tab(text: 'Your Page'),
              ],
            ),
            title: const Text('NuwunSewu'),
            backgroundColor: Color(0xFF2e2b2b),
          ),
          body: const TabBarView(
            children: [
              FirstTabHome(),
              SecondTabHome(),
              ThirdTabHome(),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstTabHome extends StatefulWidget {
  const FirstTabHome({Key? key}) : super(key: key);

  @override
  _FirstTabHomeState createState() => _FirstTabHomeState();
}

class _FirstTabHomeState extends State<FirstTabHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('postingan').snapshots(),
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
              var title = post['title'];
              var body = post['body'];
              List<String>? imagePaths =
                  (post['imagePaths'] as List<dynamic>).cast<String>();
              var uidSender = post['uidSender'];
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
            },
          );
        },
      ),
    );
  }
}

Future<Uint8List> compressImage(String imageUrl) async {
  // Download the image
  final response = await http.get(Uri.parse(imageUrl));

  if (response.statusCode == 200) {
    final bytes = Uint8List.fromList(response.bodyBytes);
    // Compress the image
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 640,
      minWidth: 360,
      quality: 6,
    );
    return result;
  } else {
    throw Exception('Failed to load image');
  }
}

class PostWidget extends StatefulWidget {
  PostWidget({
    required this.title,
    required this.body,
    required this.imagePaths,
    required this.uidSender,
    required this.dateTime,
    required this.namaLengkap,
    required this.profilePicture,
    required this.postID,
  });

  final String title;
  final String body;
  final List<String>? imagePaths;
  final String uidSender;
  final DateTime dateTime;
  final String namaLengkap;
  final String profilePicture;
  final postID;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  StoreData db = StoreData();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpandPost(postID: widget.postID),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFF3f3c3c),
        ),
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: widget.imagePaths != null &&
                        widget.imagePaths!.isNotEmpty
                    ? FutureBuilder<Uint8List>(
                        future: compressImage(widget.imagePaths![0]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            } else {
                              return Text('No data');
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      )
                    : Container(),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => widget.uidSender ==
                                    FirebaseAuth.instance.currentUser?.uid
                                ? Profile(
                                    isRedirected: true,
                                  )
                                : OtherProfile(uidSender: widget.uidSender),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 21,
                        backgroundImage: NetworkImage(widget.profilePicture),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            widget.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.namaLengkap,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300,
                                  // color: Colors.black,
                                ),
                              ),
                              Text(
                                _formatTimeDifference(widget.dateTime),
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300,
                                  // color: Colors.black,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeDifference(DateTime postDateTime) {
    Duration difference = DateTime.now().difference(postDateTime);
    int daysDifference = difference.inDays;
    int hoursDifference = difference.inHours;
    int minuteDifference = difference.inMinutes;

    if (daysDifference > 0) {
      return '${daysDifference} hari yang lalu';
    } else if (hoursDifference > 0) {
      return '${hoursDifference} jam yang lalu';
    } else {
      return '${minuteDifference} menit yang lalu';
    }
  }
}

class SecondTabHome extends StatefulWidget {
  const SecondTabHome({Key? key}) : super(key: key);

  @override
  _SecondTabHomeState createState() => _SecondTabHomeState();
}

class _SecondTabHomeState extends State<SecondTabHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: StreamBuilder<List<String>>(
        stream: getFollowingListStream(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, followingSnapshot) {
          if (followingSnapshot.connectionState == ConnectionState.waiting) {
            return Container(); // or a loading indicator
          }

          if (followingSnapshot.hasError) {
            return Text('Error: ${followingSnapshot.error}');
          }

          var followingList = followingSnapshot.data;

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

                  // Check if the uidSender is in the following list
                  if (followingList!.contains(uidSender)) {
                    var title = post['title'];
                    var body = post['body'];
                    List<String>? imagePaths =
                        (post['imagePaths'] as List<dynamic>).cast<String>();
                    var dateTime = post['dateTime'];
                    DateTime parsedDateTime =
                        dateTime != null ? dateTime.toDate() : DateTime.now();
                    var postID = snapshot.data!.docs[index].id;

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
                    var repostsCollection =
                        post.reference.collection('reposts');
                    var currentUserUid = FirebaseAuth.instance.currentUser?.uid;

                    return FutureBuilder<QuerySnapshot>(
                      future: repostsCollection.get(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> repostsSnapshot) {
                        if (repostsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }

                        if (repostsSnapshot.hasError) {
                          return Text('Error: ${repostsSnapshot.error}');
                        }

                        // Check if there is any repost by the current user or by people you follow
                        var currentUserRepost = repostsSnapshot.data!.docs
                            .any((repostDoc) => repostDoc.id == currentUserUid);

                        var followingReposts = repostsSnapshot.data!.docs.any(
                            (repostDoc) =>
                                followingList.contains(repostDoc.id));

                        if (currentUserRepost || followingReposts) {
                          var title = post['title'];
                          var body = post['body'];
                          List<String>? imagePaths =
                              (post['imagePaths'] as List<dynamic>)
                                  .cast<String>();
                          var dateTime = post['dateTime'];
                          DateTime parsedDateTime = dateTime != null
                              ? dateTime.toDate()
                              : DateTime.now();
                          var postID = (snapshot.data!.docs[index].id);
                          var uidSender = post['uidSender'];
                          print(uidSender);

                          // Get the UID of the user who reposted
                          var repostedUid = currentUserRepost
                              ? currentUserUid
                              : repostsSnapshot.data!.docs
                                  .firstWhere((repostDoc) =>
                                      followingList.contains(repostDoc.id))
                                  .id;

                          return FutureBuilder<String>(
                            future: getNamaLengkap(uidSender),
                            builder: (context, namaLengkapSnapshot) {
                              if (namaLengkapSnapshot.hasError) {
                                return Text(
                                    'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                              }

                              var namaLengkap =
                                  namaLengkapSnapshot.data ?? 'null';

                              return FutureBuilder<String>(
                                future: getProfilePicture(uidSender),
                                builder: (context, profilePictureSnapshot) {
                                  if (profilePictureSnapshot.hasError) {
                                    return Text(
                                        'Error fetching profilePicture: ${profilePictureSnapshot.error}');
                                  }

                                  var profilePicture = (profilePictureSnapshot
                                                  .data ==
                                              'defaultProfilePict'
                                          ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                                          : profilePictureSnapshot.data) ??
                                      'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

                                  return FutureBuilder<String>(
                                    future: getNamaLengkap(repostedUid),
                                    builder: (context, namaLengkapSnapshot) {
                                      if (namaLengkapSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(); // or a loading indicator
                                      }

                                      if (namaLengkapSnapshot.hasError) {
                                        return Text(
                                            'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                                      }

                                      var namaLengkapRepost =
                                          namaLengkapSnapshot.data ?? 'null';

                                      return Column(
                                        children: [
                                          Text(
                                              'Reposted by $namaLengkapRepost'), // Display name or adjust as needed
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
                            },
                          );
                        } else {
                          // If the post is not reposted by the current user or people you follow, return an empty container
                          return Container();
                        }
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

Stream<List<String>> getFollowingListStream(String uidSender) async* {
  try {
    CollectionReference followingCollection = FirebaseFirestore.instance
        .collection('userData')
        .doc(uidSender)
        .collection('following');

    QuerySnapshot followingSnapshot = await followingCollection.get();

    List<String> followingList =
        followingSnapshot.docs.map((doc) => doc.id).toList();

    yield followingList;
  } catch (e) {
    print("Error: $e");
    yield [];
  }
}

class ThirdTabHome extends StatefulWidget {
  const ThirdTabHome({Key? key}) : super(key: key);

  @override
  _ThirdTabHomeState createState() => _ThirdTabHomeState();
}

class _ThirdTabHomeState extends State<ThirdTabHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: StreamBuilder<QuerySnapshot>(
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
              if (uidSender == FirebaseAuth.instance.currentUser?.uid) {
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
                var currentUserUid = FirebaseAuth.instance.currentUser?.uid;

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
                      print(post);

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

                              var profilePicture = (profilePictureSnapshot
                                              .data ==
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
      ),
    );
  }
}
