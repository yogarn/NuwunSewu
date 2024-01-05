import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuwunsewu/screens/home/other_profile.dart';
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
        title: Text('Cari Postingan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _startSearch();
                  },
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
                                    builder: (context) => OtherProfile(
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
