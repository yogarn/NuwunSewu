import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nuwunsewu/screens/home/other_profile.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/services/utils.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _searchResults = Stream.value([]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color(0xFF131313),
          title: Text('Cari Postingan'),
        ),
        body: Column(
          children: [
            Container(
              height: 60,
              color: Color(0xFF131313),
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 20.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    hintText: 'Cari...',
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _startSearch();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If there is no data or the data is empty, show Trending
                    return Trending();
                  } else {
                    List<DocumentSnapshot> results = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> resultData =
                            results[index].data() as Map<String, dynamic>;

                        if (resultData.containsKey('title') &&
                            resultData.containsKey('body')) {
                          return FutureBuilder<String>(
                            future: getNamaLengkap(resultData['uidSender']),
                            builder: (context, namaLengkapSnapshot) {
                              if (namaLengkapSnapshot.hasError) {
                                return Text(
                                    'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                              }

                              var namaLengkap =
                                  namaLengkapSnapshot.data ?? 'null';

                              return FutureBuilder<String>(
                                future:
                                    getProfilePicture(resultData['uidSender']),
                                builder: (context, profilePictureSnapshot) {
                                  if (profilePictureSnapshot.hasError) {
                                    return Text(
                                        'Error fetching profilePicture: ${profilePictureSnapshot.error}');
                                  }

                                  var profilePicture =
                                      profilePictureSnapshot.data ?? '';

                                  return PostWidget(
                                    title: resultData['title'],
                                    body: resultData['body'],
                                    uidSender: resultData['uidSender'],
                                    dateTime: resultData['dateTime'].toDate(),
                                    namaLengkap: namaLengkap,
                                    imagePaths: (resultData['imagePaths']
                                            as List<dynamic>)
                                        .cast<String>(),
                                    profilePicture: profilePicture,
                                    postID: results[index].id,
                                  );
                                },
                              );
                            },
                          );
                        } else if (resultData.containsKey('namaLengkap')) {
                          var profilePicture =
                              resultData['profilePicture'] ?? '';

                          return ListTile(
                            title: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => results[index].id ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid
                                        ? Profile(isRedirected: true)
                                        : OtherProfile(
                                            uidSender: results[index].id,
                                          ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xFF403d3d),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: CircleAvatar(
                                              radius: 21,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(profilePicture),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 10,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    resultData['namaLengkap'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
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
                            ),
                          );
                        } else {
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
      ),
    );
  }

  void _startSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = searchPostsStream(query);
      });
    } else {
      setState(() {
        _searchResults = Stream.value([]);
      });
    }
  }

  Stream<List<DocumentSnapshot>> searchPostsStream(String query) async* {
    query = query.toLowerCase();
    List<String> queryWords = query.split(' ');

    try {
      QuerySnapshot<Map<String, dynamic>> postResults =
          await FirebaseFirestore.instance.collection('postingan').get();

      QuerySnapshot<Map<String, dynamic>> userResults =
          await FirebaseFirestore.instance.collection('userData').get();

      List<DocumentSnapshot> filteredUserResults =
          userResults.docs.where((doc) {
        String namaLengkap =
            (doc['namaLengkap'] as String?)?.toLowerCase() ?? '';
        String uid = doc.id;

        return queryWords
            .any((word) => namaLengkap.contains(word) || uid.contains(word));
      }).toList();

      List<DocumentSnapshot> filteredPostsResults =
          postResults.docs.where((doc) {
        String title = (doc['title'] as String?)?.toLowerCase() ?? '';
        String body = (doc['body'] as String?)?.toLowerCase() ?? '';

        return queryWords
            .any((word) => title.contains(word) || body.contains(word));
      }).toList();

      List<DocumentSnapshot> combinedResults = [];
      combinedResults.addAll(filteredPostsResults);
      combinedResults.addAll(filteredUserResults);
      yield combinedResults;
    } catch (e) {
      print("Error: $e");
      yield [];
    }
  }
}

class Trending extends StatefulWidget {
  const Trending({Key? key}) : super(key: key);

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text("On Trending"),
        elevation: 0.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('postingan')
            .orderBy('likesCount', descending: true)
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

                      var profilePicture = profilePictureSnapshot.data ?? '';

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
