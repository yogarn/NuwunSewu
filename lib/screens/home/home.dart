import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Update with the correct import
import 'package:nuwunsewu/screens/home/other_profile.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/post/post.dart';
import 'package:nuwunsewu/services/add_data.dart'; // Update with the correct import
import 'package:nuwunsewu/services/utils.dart'; // Update with the correct import

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
            var imagePath = post['imagePath'];
            var uidSender = post['uidSender'];
            var dateTime = post['dateTime'];
            DateTime parsedDateTime = dateTime.toDate();

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
                      imagePath: imagePath,
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
    required this.imagePath,
    required this.uidSender,
    required this.dateTime,
    required this.namaLengkap,
    required this.profilePicture,
    required this.postID,
  });

  final String title;
  final String body;
  final String? imagePath;
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
  int likeCount = 0;
  int commentCount = 0;
  bool isLiked = false; // Tambahkan variabel lokal untuk melacak status like

  final Duration _debounceDuration = Duration(milliseconds: 500);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    getLikeCount(widget.postID).then((count) {
      setState(() {
        likeCount = count;
      });
    });

    getCommentCount(widget.postID).then((count) {
      setState(() {
        commentCount = count;
      });
    });

    // Inisialisasi status like berdasarkan hasil dari hasUserLikedPost
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    db.hasUserLikedPost(widget.postID, currentUserID).then((liked) {
      setState(() {
        isLiked = liked;
      });
    });
  }

  Future<void> _toggleLikePost() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      final currentUserID = FirebaseAuth.instance.currentUser!.uid;

      if (isLiked) {
        setState(() {
          likeCount -= 1;
          isLiked = false; // Perbarui status like secara lokal
        });
        await db.deleteLikePost(widget.postID, currentUserID);
      } else {
        setState(() {
          likeCount += 1;
          isLiked = true; // Perbarui status like secara lokal
        });
        await db.likePost(widget.postID, currentUserID);
      }
    });
  }

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
        margin: const EdgeInsets.all(20),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.imagePath != null
                      ? Image.network(
                          widget.imagePath!,
                          fit: BoxFit.fill,
                        )
                      : Container(),
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _toggleLikePost();
                        },
                        icon: isLiked
                            ? const Icon(Icons.favorite,
                                color: Colors.red) // Icon untuk sudah di like
                            : const Icon(Icons
                                .favorite_border), // Icon untuk belum di like
                      ),
                      Text(likeCount.toString()),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_rounded),
                      ),
                      Text(commentCount.toString()),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                  ),
                ],
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
                            builder: (context) =>
                                OtherProfile(uidSender: widget.uidSender),
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

class SecondTabHome extends StatelessWidget {
  const SecondTabHome({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.directions_transit);
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
