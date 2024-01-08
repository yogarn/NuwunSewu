import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuwunsewu/services/utils.dart';

class ViewChat extends StatefulWidget {
  final String chatID;
  final String senderID;
  final String targetUserID;

  ViewChat({required this.chatID, required this.senderID, required this.targetUserID});

  @override
  _ViewChatState createState() => _ViewChatState();
}

class _ViewChatState extends State<ViewChat> {
  TextEditingController messageController = TextEditingController();
  String targetUserName = ""; // Add this line to store the other person's name
  ScrollController _scrollController = ScrollController(); // Add this line
  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add this line

  @override
  void initState() {
    super.initState();
    _fetchTargetUserName();
  }

  void _fetchTargetUserName() async {
    // Call your function to get the name using targetUserID
    String name = await getNamaLengkap(widget.targetUserID);
    setState(() {
      targetUserName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(targetUserName), // Display the other person's name here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatID)
                    .collection('messages')
                    .orderBy('timestamp') // Optional: Order messages by timestamp
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<Map<String, dynamic>> messages = snapshot.data!.docs
                      .map((doc) => {
                            'content': doc['content'].toString(),
                            'sender': doc['sender'].toString(),
                          })
                      .toList();

                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageWidget(messages[index]);
                    },
                  );
                },
              ),
            ),
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _sendMessage();
                    },
                    child: Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      String messageContent = messageController.text.trim();
      StoreData().sendMessage(widget.chatID, widget.senderID, messageContent);
      messageController.clear();
    }
  }

  Widget _buildMessageWidget(Map<String, dynamic> message) {
    // Check if the message is sent by the user
    bool isUserSender = message['sender'] == widget.senderID;

    return Padding(
      padding: EdgeInsets.only(
        right: isUserSender ? 0.0 : 50.0, // Adjust spacing based on sender
        left: isUserSender ? 50.0 : 0.0,
      ),
      child: Align(
        alignment: isUserSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isUserSender ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message['content'],
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
