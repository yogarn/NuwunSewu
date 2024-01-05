import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuwunsewu/screens/home/other_profile.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/post/post.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<DocumentSnapshot>> _searchResults = Future.value([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text('Cari Postingan'),
      ),
      body: Column(
        children: [
          // Area tertutup untuk menampung text field
          Container(
            height: 48,
            color: Colors.purple[100],
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Container(
              // text field
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30)),
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
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _searchResults,
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
                      } else if (resultData.containsKey('namaLengkap')) {
                        // Ini hasil pencarian user
                        return ListTile(
                          title: InkWell(
                              onTap: () {
                                // Navigasi ke halaman profil berdasarkan nama dokumen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => results[index].id ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid
                                        ? Profile(
                                            isRedirected: true,
                                          )
                                        : OtherProfile(
                                            uidSender: results[index].id),
                                  ),
                                );
                              },
                              child: Text(
                                  '${resultData['namaLengkap']} (${resultData['username']})')),
                          // Tambahkan widget lain sesuai kebutuhan
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

  void _startSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = searchPosts(query);
      });
    }
  }

  Future<List<DocumentSnapshot>> searchPosts(String query) async {
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

      // Gabungkan kedua list
      List<DocumentSnapshot> combinedResults = [];
      combinedResults.addAll(filteredPostsResults);
      combinedResults.addAll(filteredUserResults);
      print(combinedResults);
      return combinedResults;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
