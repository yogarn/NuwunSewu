import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuwunsewu/screens/chats/view_chat.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/services/utils.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<DocumentSnapshot>> _searchResults = Stream.value([]);

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
      QuerySnapshot<Map<String, dynamic>> userResults =
          await FirebaseFirestore.instance.collection('userData').get();

      List<DocumentSnapshot> filteredUserResults =
          userResults.docs.where((doc) {
        String namaLengkap =
            (doc['namaLengkap'] as String?)?.toLowerCase() ?? '';
        String uid = doc.id;

        return uid != FirebaseAuth.instance.currentUser!.uid &&
            queryWords.any(
                (word) => namaLengkap.contains(word) || uid.contains(word));
      }).toList();

      yield filteredUserResults;
    } catch (e) {
      print("Error: $e");
      yield [];
    }
  }

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
          backgroundColor: Color(0xFF2e2b2b),
          title: Text('Cari Chat'),
        ),
        body: Column(
          children: [
            Container(
              height: 60,
              color: Color(0xFF2e2b2b),
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
                    contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
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
                    return RecentChats();
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
                          var profilePicture = resultData['profilePicture'];
                          return ListTile(
                            title: InkWell(
                              onTap: () async {
                                var currentUserID =
                                    FirebaseAuth.instance.currentUser!.uid;
                                var otherUserID = results[index].id;
                                await startNewChat(currentUserID, otherUserID);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewChat(
                                      chatID: generateChatID(
                                          currentUserID, otherUserID),
                                      senderID: currentUserID,
                                      targetUserID: otherUserID,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xFF131313),
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
}

// recent chats
class RecentChats extends StatefulWidget {
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  RecentChats({super.key});

  @override
  State<RecentChats> createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Recent Chats'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatInfo>>(
              stream: _getRecentChatsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<ChatInfo> recentChats = snapshot.data ?? [];

                if (recentChats.isEmpty) {
                  return const Center(
                    child: Text('No recent chats'),
                  );
                }

                return ListView.builder(
                  itemCount: recentChats.length,
                  itemBuilder: (context, index) {
                    return _buildChatBox(recentChats[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<ChatInfo>> _getRecentChatsStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: widget.currentUserID)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .asyncMap<List<ChatInfo>>((querySnapshot) async {
      List<ChatInfo> recentChats = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        QuerySnapshot messagesSnapshot = await doc.reference
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          List<String> users = List.castFrom(doc['participants']);
          users.remove(widget.currentUserID);

          String otherUserID = users.first;
          String chatID = doc.id;
          String profilePict = await getProfilePicture(otherUserID);

          Message lastMessage = Message(
            sender: messagesSnapshot.docs.first['sender'],
            content: messagesSnapshot.docs.first['content'],
            timestamp: messagesSnapshot.docs.first['timestamp'],
          );

          recentChats.add(ChatInfo(
            profilePict: profilePict,
            chatID: chatID,
            otherUserID: otherUserID,
            lastMessage: lastMessage,
          ));
        }
      }

      return recentChats;
    });
  }

  Widget _buildChatBox(ChatInfo chatInfo) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Column(
        children: [
          ListTile(
            title: FutureBuilder<String>(
              future: getNamaLengkap(chatInfo.otherUserID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Text(snapshot.data ?? 'Unknown User');
              },
            ),
            subtitle: Text(chatInfo.lastMessage.sender == widget.currentUserID
                ? "You : " + chatInfo.lastMessage.content
                : chatInfo.lastMessage.content),
            tileColor: Color(0xFF3f3c3c),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(15),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewChat(
                    chatID: chatInfo.chatID,
                    senderID: widget.currentUserID,
                    targetUserID: chatInfo.otherUserID,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              radius: 21,
              backgroundImage: CachedNetworkImageProvider(
                chatInfo.profilePict,
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class Message {
  final String content;
  final Timestamp timestamp;
  final String sender;

  Message(
      {required this.content, required this.timestamp, required this.sender});
}

class ChatInfo {
  final String profilePict;
  final String chatID;
  final String otherUserID;
  final Message lastMessage;

  ChatInfo(
      {required this.profilePict,
      required this.chatID,
      required this.otherUserID,
      required this.lastMessage});
}
