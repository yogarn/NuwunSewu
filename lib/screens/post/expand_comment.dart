import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';

class ExpandComment extends StatefulWidget {
  final String commentID;
  final String postID;
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('postingan');

  final TextEditingController commentController = new TextEditingController();

  ExpandComment({required this.commentID, required this.postID});

  @override
  State<ExpandComment> createState() => _ExpandCommentState();
}

class _ExpandCommentState extends State<ExpandComment> {
  final _formKey = GlobalKey<FormState>();
  String? textKomentar;
  String error = '';
  bool loading = false;

  StoreData db = StoreData();

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            home: Scaffold(
              appBar: AppBar(
                surfaceTintColor: Colors.transparent,
                title: Text('View Comments'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
                    // handle the press
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Container(
                margin: EdgeInsets.all(20),
                child: ListView(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: widget.postCollection
                          .doc(widget.postID)
                          .collection('comments')
                          .doc(widget.commentID)
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        if (commentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loading();
                        } else {
                          if (commentSnapshot.hasData &&
                              commentSnapshot.data!.exists) {
                            Map<String, dynamic> commentData =
                                commentSnapshot.data!.data()
                                    as Map<String, dynamic>;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.all(8.0),
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FutureBuilder<String>(
                                              future: getNamaLengkap(
                                                  commentData['user']),
                                              builder: (context,
                                                  namaLengkapSnapshot) {
                                                if (namaLengkapSnapshot
                                                    .hasError) {
                                                  return Text(
                                                      'Error fetching data');
                                                }

                                                var namaLengkap =
                                                    namaLengkapSnapshot.data ??
                                                        'null';

                                                return FutureBuilder<String>(
                                                  future: getProfilePicture(
                                                      commentData['user']),
                                                  builder: (context,
                                                      profilePictureSnapshot) {
                                                    if (profilePictureSnapshot
                                                        .hasError) {
                                                      return Text(
                                                          'Error fetching data');
                                                    }

                                                    var profilePicture =
                                                        profilePictureSnapshot
                                                                .data ??
                                                            '';

                                                    return Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 21,
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                                  profilePicture),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(namaLengkap),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              commentData['text'],
                                              style: TextStyle(fontSize: 12.0),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              formatTimeDifference(
                                                  commentData['timestamp']
                                                      .toDate()),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return Text('Dokumen komentar tidak ditemukan');
                          }
                        }
                      },
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (val) => val!.isEmpty
                                ? 'Komentar tidak boleh kosong!'
                                : null,
                            maxLines: null,
                            controller: widget.commentController,
                            decoration: InputDecoration(
                              hintText: "Tulis Komentar",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(21),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              suffixIcon: Container(
                                margin: EdgeInsets.all(8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(50, 50),
                                    side: BorderSide.none,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState != null) {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        try {
                                          await db.balasKomentar(
                                              widget.postID,
                                              widget.commentID,
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              widget.commentController.text);
                                          widget.commentController.text = '';
                                          setState(() {
                                            loading = false;
                                          });
                                        } catch (e) {
                                          setState(() {
                                            error =
                                                "Mohon maaf, periksa detail komentar dan coba lagi nanti.";
                                            loading = false;
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: 14.0),
                          ),
                          ExpandCommentWidget(
                              postID: widget.postID,
                              commentID: widget.commentID),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class ExpandCommentWidget extends StatelessWidget {
  final String postID;
  final String commentID;
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('postingan');

  ExpandCommentWidget({required this.postID, required this.commentID});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: postCollection
          .doc(postID)
          .collection('comments')
          .doc(commentID)
          .collection('replyComments')
          .snapshots(),
      builder: (context, replyCommentsSnapshot) {
        if (replyCommentsSnapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else {
          if (replyCommentsSnapshot.hasData) {
            List<DocumentSnapshot> replyComments =
                replyCommentsSnapshot.data!.docs;

            return Column(
              children: replyComments.map((replyComment) {
                Map<String, dynamic> replyCommentData =
                    replyComment.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future:
                                      getNamaLengkap(replyCommentData['user']),
                                  builder: (context, namaLengkapSnapshot) {
                                    if (namaLengkapSnapshot.hasError) {
                                      return Text('Error fetching data');
                                    }

                                    var namaLengkap =
                                        namaLengkapSnapshot.data ?? 'null';

                                    return FutureBuilder<String>(
                                      future: getProfilePicture(
                                          replyCommentData['user']),
                                      builder:
                                          (context, profilePictureSnapshot) {
                                        if (profilePictureSnapshot.hasError) {
                                          return Text('Error fetching data');
                                        }

                                        var profilePicture = profilePictureSnapshot
                                                .data ??
                                            'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

                                        return Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 21,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(profilePicture),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(namaLengkap),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  replyCommentData['text'],
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  formatTimeDifference(
                                      replyCommentData['timestamp'].toDate()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            );
          } else {
            return Text('Tidak ada balasan komentar');
          }
        }
      },
    );
  }
}
