import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nuwunsewu/screens/chats/messsage_another.dart';
import 'package:nuwunsewu/screens/chats/view_chat.dart';
import 'package:nuwunsewu/services/utils.dart';

class Chats extends StatefulWidget {
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          Container(
            margin: EdgeInsets.all(20),
            child: ElevatedButton(
              child: Text('Message Another Person'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageAnother()),
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
            tileColor: Colors.purple[100],
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
              backgroundImage: NetworkImage(
                chatInfo.profilePict == "defaultProfilePict" ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain' : chatInfo.profilePict,
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
