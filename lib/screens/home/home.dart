import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/screens/home/other_profile.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/post/post.dart';
import 'package:nuwunsewu/screens/post/upload.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/services/utils.dart';

class Home extends StatelessWidget {
  const Home({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Upload()),
              );
            },
            tooltip: "Post",
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'For You'),
                Tab(text: 'Following'),
                Tab(text: 'Trending'),
              ],
            ),
            title: const Text('NuwunSewu'),
            backgroundColor: Colors.purple[100],
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
    return StreamBuilder<QuerySnapshot>(
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
    );
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
          color: Colors.purple[100],
        ),
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: widget.imagePaths != null &&
                        widget.imagePaths!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.imagePaths![0], // Display the first image
                            fit: BoxFit.fill,
                          ),
                        ),
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
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.body,
                            maxLines: 2,
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
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                _formatTimeDifference(widget.dateTime),
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
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
  String uidSender = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future:
                  getFollowingList(uidSender).then((uids) => searchPosts(uids)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<DocumentSnapshot> results = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> resultData =
                          results[index].data() as Map<String, dynamic>;

                      // Periksa apakah ini hasil pencarian dari postingan atau user
                      if (resultData.containsKey('title') &&
                          resultData.containsKey('body')) {
                        // Ini hasil pencarian postingan
                        return InkWell(
                          onTap: () {
                            // Navigasi ke halaman profil berdasarkan nama dokumen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExpandPost(postID: results[index].id),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(resultData['title']),
                            subtitle: Text(resultData['body']),
                            // Tambahkan widget lain sesuai kebutuhan
                          ),
                        );
                      } else {
                        // Handle jenis data lain jika diperlukan
                        return SizedBox.shrink();
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> getFollowingList(String uidSender) async {
    try {
      // Get a reference to the 'following' subcollection in the document with uidSender
      CollectionReference followingCollection = FirebaseFirestore.instance
          .collection('userData')
          .doc(uidSender)
          .collection('following');

      // Get documents from the 'following' subcollection
      QuerySnapshot followingSnapshot = await followingCollection.get();

      // Get the list of uidTarget from the documents in the 'following' subcollection
      List<String> followingList =
          followingSnapshot.docs.map((doc) => doc.id).toList();

      return followingList;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<List<DocumentSnapshot>> searchPosts(List<String> uids) async {
    try {
      QuerySnapshot<Map<String, dynamic>> postResults =
          await FirebaseFirestore.instance.collection('postingan').get();

      List<DocumentSnapshot> filteredPostsResults =
          postResults.docs.where((doc) {
        String uid = (doc['uidSender'] as String);

        // Menggunakan contains untuk memeriksa apakah uid ada dalam list uids
        return uids.contains(uid);
      }).toList();

      // Gabungkan kedua list
      return filteredPostsResults;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}

class ThirdTabHome extends StatelessWidget {
  const ThirdTabHome({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.directions_bike);
  }
}

void main() {
  runApp(Home());
}
