import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/services/utils.dart';

class ViewChat extends StatefulWidget {
  final String chatID;
  final String senderID;
  final String targetUserID;

  const ViewChat({
    Key? key,
    required this.chatID,
    required this.senderID,
    required this.targetUserID,
  }) : super(key: key);

  @override
  State<ViewChat> createState() => _ViewChatState();
}

class _ViewChatState extends State<ViewChat> {
  TextEditingController messageController = TextEditingController();
  String targetUserName = "";
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchTargetUserName();
  }

  void _fetchTargetUserName() async {
    String name = await getNamaLengkap(widget.targetUserID);
    setState(() {
      targetUserName = name;
    });
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      String messageContent = messageController.text.trim();
      StoreData().sendMessage(widget.chatID, widget.senderID, messageContent);
      messageController.clear();
    }
  }

  Widget _buildMessageWidget(Map<String, dynamic> message, bool showDate) {
    bool isUserSender = message['sender'] == widget.senderID;
    Intl.defaultLocale = 'en_US';
    DateTime? parsedDateTime;

    try {
      var dateTime = message['timestamp'];
      if (dateTime != null) {
        parsedDateTime = dateTime.toDate();
        print(parsedDateTime);
      } else {
        print('Timestamp is null in Firebase for this message.');
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }

    return Column(
      children: [
        if (showDate && parsedDateTime != null)
          Center(
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                DateFormat('yy/MM/dd').format(parsedDateTime!),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            right: isUserSender ? 0.0 : 50.0,
            left: isUserSender ? 50.0 : 0.0,
          ),
          child: Align(
            alignment:
                isUserSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isUserSender ? Colors.purple[200] : Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: isUserSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                  if (parsedDateTime != null)
                    Text(
                      DateFormat('HH:mm').format(parsedDateTime),
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(targetUserName),
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
                    .orderBy('timestamp')
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
                            'timestamp': doc['timestamp'],
                          })
                      .toList();

                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool showDate = index == 0 ||
                          (messages[index]['timestamp']?.toDate().day !=
                              messages[index - 1]['timestamp']?.toDate().day);

                      return _buildMessageWidget(messages[index], showDate);
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
}
