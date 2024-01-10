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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text('Cari Postingan'),
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            color: Colors.purple[100],
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                  hintText: 'Cari...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
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

                                var profilePicture = (profilePictureSnapshot
                                                .data ==
                                            'defaultProfilePict'
                                        ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                                        : profilePictureSnapshot.data) ??
                                    'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

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
                        var profilePicture = (resultData['profilePicture'] ==
                                    'defaultProfilePict'
                                ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                                : resultData['profilePicture']) ??
                            'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';
                        return ListTile(
                          title: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => results[index].id ==
                                          FirebaseAuth.instance.currentUser?.uid
                                      ? Profile(isRedirected: true)
                                      : OtherProfile(
                                          uidSender: results[index].id,
                                        ),
                                ),
                              );
                            },
                            child:
                                Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.purple[100],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: CircleAvatar(
                                            radius: 21,
                                            backgroundImage:
                                                NetworkImage(profilePicture),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 10,
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
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
    );
  }

  void _startSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = searchPostsStream(query);
      });
    } else {
      // Handle the case when the query is empty
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

      // Combine both lists
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
