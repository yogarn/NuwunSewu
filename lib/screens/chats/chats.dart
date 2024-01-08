import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuwunsewu/screens/chats/messsage_another.dart';
import 'package:nuwunsewu/screens/chats/view_chat.dart';
import 'package:nuwunsewu/services/utils.dart';

class Chats extends StatefulWidget {
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Chats'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _getRecentChats(),
              builder: (context, AsyncSnapshot<List<ChatInfo>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
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
                  return Center(
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
          Container(
              margin: EdgeInsets.all(20),
              child: ElevatedButton(
                child: Text('Message Another Person'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageAnother()),
                  );
                },
              ))
        ],
      ),
    );
  }

  Future<List<ChatInfo>> _getRecentChats() async {
    List<ChatInfo> recentChats = [];

    // Query Firestore to get recent chats, ordered by timestamp in descending order
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: widget.currentUserID)
        .orderBy('lastTimestamp',
            descending: true) // Assuming you have a field named 'lastTimestamp'
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Check if there are messages in the subcollection
      QuerySnapshot messagesSnapshot =
          await doc.reference.collection('messages').get();

      if (messagesSnapshot.docs.isNotEmpty) {
        // Extract information for each chat
        List<String> users = List.castFrom(doc['participants']);
        users.remove(widget.currentUserID);

        String otherUserID = users.first;
        String chatID = doc.id;

        recentChats.add(ChatInfo(
          chatID: chatID,
          otherUserID: otherUserID,
          // Add the correct timestamp based on your data structure
        ));
      }
    }

    return recentChats;
  }

  Widget _buildChatBox(ChatInfo chatInfo) {
    return FutureBuilder(
      future: getNamaLengkap(chatInfo.otherUserID),
      builder: (context, AsyncSnapshot<String> nameSnapshot) {
        if (nameSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Loading...'),
          );
        }

        if (nameSnapshot.hasError) {
          return ListTile(
            title: Text('Error loading name'),
          );
        }

        String otherUserName = nameSnapshot.data ?? 'Unknown User';

        return FutureBuilder(
          future: getProfilePicture(chatInfo.otherUserID),
          builder: (context, AsyncSnapshot<String> pictureSnapshot) {
            if (pictureSnapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                title: Text('Loading...'),
              );
            }

            if (pictureSnapshot.hasError) {
              return ListTile(
                title: Text('Error loading profile picture'),
              );
            }

            var profilePicture = (pictureSnapshot.data == 'defaultProfilePict'
                    ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                    : pictureSnapshot.data) ??
                'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'; // Use the fetched profile picture

            return Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Column(
                children: [
                  ListTile(
                    title: Text(otherUserName),
                    tileColor: Colors.purple[100], // Set the background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Set the border radius
                    ),
                    contentPadding:
                        const EdgeInsets.all(15), // Set the content padding
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
                      backgroundImage: NetworkImage(profilePicture),
                    ),
                  ),
                  SizedBox(height: 8), // Add this line for the margin
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ChatInfo {
  final String chatID;
  final String otherUserID;

  ChatInfo({required this.chatID, required this.otherUserID});
}
