import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nuwunsewu/screens/post/expand_comment.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';
import 'package:nuwunsewu/services/add_data.dart';

class ExpandPost extends StatefulWidget {
  final String postID;
  final TextEditingController commentController = TextEditingController();
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('postingan');
  
  ExpandPost({required this.postID});

  @override
  State<ExpandPost> createState() => _ExpandPostState();
}

class _ExpandPostState extends State<ExpandPost> {
  final _formKey = GlobalKey<FormState>();
  String? textKomentar;
  String error = '';
  bool loading = false;

  StoreData db = StoreData();
  int likeCount = 0;
  int dislikeCount = 0;
  int commentCount = 0;
  bool isLiked = false;
  bool isDisliked = false;

  final Duration _debounceDuration = Duration(milliseconds: 500);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    getLikeCount(widget.postID).then((count) {
      setState(() {
        likeCount = count;
      });
    });

    getDislikeCount(widget.postID).then((count) {
      setState(() {
        dislikeCount = count;
      });
    });

    getCommentCount(widget.postID).then((count) {
      setState(() {
        commentCount = count;
      });
    });

    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    db.hasUserLikedPost(widget.postID, currentUserID).then((liked) {
      setState(() {
        isLiked = liked;
      });
    });

    db.hasUserDislikedPost(widget.postID, currentUserID).then((disliked) {
      setState(() {
        isDisliked = disliked;
      });
    });
  }

  Future<void> _toggleLikePost() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      final currentUserID = FirebaseAuth.instance.currentUser!.uid;

      if (isLiked) {
        setState(() {
          likeCount -= 1;
          isLiked = false;
        });
        await db.deleteLikePost(widget.postID, currentUserID);
        FirebaseFirestore.instance
            .collection('postingan')
            .doc(widget.postID)
            .update({
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        setState(() {
          if (isDisliked) {
            _toggleDislikePost();
          }
          likeCount += 1;
          isLiked = true;
        });
        await db.likePost(widget.postID, currentUserID);
        FirebaseFirestore.instance
            .collection('postingan')
            .doc(widget.postID)
            .update({
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> _toggleDislikePost() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      final currentUserID = FirebaseAuth.instance.currentUser!.uid;

      if (isDisliked) {
        setState(() {
          dislikeCount -= 1;
          isDisliked = false;
        });
        await db.deleteDislikePost(widget.postID, currentUserID);
        FirebaseFirestore.instance
            .collection('postingan')
            .doc(widget.postID)
            .update({
          'dislikesCount': FieldValue.increment(-1),
        });
      } else {
        setState(() {
          if (isLiked) {
            _toggleLikePost();
          }
          dislikeCount += 1;
          isDisliked = true;
        });
        await db.dislikePost(widget.postID, currentUserID);
        FirebaseFirestore.instance
            .collection('postingan')
            .doc(widget.postID)
            .update({
          'dislikesCount': FieldValue.increment(1),
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: Text('Expand Post'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Container(
                margin: EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Text(widget.postID),
                    StreamBuilder<DocumentSnapshot>(
                      stream:
                          widget.userCollection.doc(widget.postID).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loading();
                        } else {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            Map<String, dynamic> postingan =
                                snapshot.data!.data() as Map<String, dynamic>;

                            return FutureBuilder<String>(
                              future: getNamaLengkap(postingan['uidSender']),
                              builder: (context, namaLengkapSnapshot) {
                                if (namaLengkapSnapshot.hasError) {
                                  return Text(
                                      'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                                }

                                var namaLengkap =
                                    namaLengkapSnapshot.data ?? 'null';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      postingan['title'],
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: "Times New Roman",
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      namaLengkap,
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: "Times New Roman",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      postingan['dateTime'].toDate().toString(),
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: "Times New Roman",
                                          fontWeight: FontWeight.w300),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    postingan['imagePaths'] != null &&
                                            postingan['imagePaths'].isNotEmpty
                                        ? Column(
                                            children: (postingan['imagePaths']
                                                    as List<dynamic>)
                                                .cast<
                                                    String>()
                                                .map((imagePath) {
                                              return Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 20),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Image.network(
                                                    imagePath,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          )
                                        : Container(),
                                    Text(
                                      postingan['body'],
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontFamily: "Times New Roman",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                await _toggleLikePost();
                                              },
                                              icon: isLiked
                                                  ? const Icon(Icons.thumb_up,
                                                      color: Colors
                                                          .purple)
                                                  : const Icon(Icons
                                                      .thumb_up_outlined),
                                            ),
                                            Text(likeCount.toString()),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                await _toggleDislikePost();
                                              },
                                              icon: isDisliked
                                                  ? const Icon(Icons.thumb_down,
                                                      color: Colors
                                                          .purple)
                                                  : const Icon(Icons
                                                      .thumb_down_outlined),
                                            ),
                                            Text(dislikeCount.toString()),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(Icons.share),
                                            ),
                                            Text('Share'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Text(commentCount.toString()),
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                  Icons.chat_bubble_rounded),
                                            ),
                                          ],
                                        ),
                                        Text('Komentar',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "Times New Roman",
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
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
                                            controller:
                                                widget.commentController,
                                            decoration: InputDecoration(
                                              hintText: "Tulis Komentar",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(21),
                                                borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              suffixIcon: Container(
                                                margin: EdgeInsets.all(8),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: Size(50, 50),
                                                    side: BorderSide.none,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  child: Icon(Icons.send),
                                                  onPressed: () async {
                                                    if (_formKey.currentState !=
                                                        null) {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          loading = true;
                                                          commentCount += 1;
                                                        });
                                                        try {
                                                          await db.tambahKomentar(
                                                              widget.postID,
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              widget
                                                                  .commentController
                                                                  .text);
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'postingan')
                                                              .doc(
                                                                  widget.postID)
                                                              .update({
                                                            'commentsCount':
                                                                FieldValue
                                                                    .increment(
                                                                        1),
                                                          });
                                                          widget
                                                              .commentController
                                                              .text = '';
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
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14.0),
                                          ),
                                          CommentWidget(postId: widget.postID),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            return Text('Dokumen tidak ditemukan');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class CommentWidget extends StatelessWidget {
  final String postId;

  CommentWidget({required this.postId});

  @override
  Widget build(BuildContext context) {
    CollectionReference commentsCollection = FirebaseFirestore.instance
        .collection('postingan')
        .doc(postId)
        .collection('comments');

    return StreamBuilder<QuerySnapshot>(
      stream: commentsCollection.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Text('Belum ada komentar.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> commentData =
                document.data() as Map<String, dynamic>;

            String commentText = commentData['text'] ?? '';
            var commentID = document.id;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpandComment(
                            commentID: commentID,
                            postID: postId,
                          )),
                );
              },
              child: Row(
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
                            future: getNamaLengkap(commentData['user']),
                            builder: (context, namaLengkapSnapshot) {
                              if (namaLengkapSnapshot.hasError) {
                                return Text('Error fetching data');
                              }

                              var namaLengkap =
                                  namaLengkapSnapshot.data ?? 'null';

                              return FutureBuilder<String>(
                                future: getProfilePicture(commentData['user']),
                                builder: (context, profilePictureSnapshot) {
                                  if (profilePictureSnapshot.hasError) {
                                    return Text('Error fetching data');
                                  }

                                  var profilePicture = (profilePictureSnapshot
                                                  .data ==
                                              'defaultProfilePict'
                                          ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                                          : profilePictureSnapshot.data) ??
                                      'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 21,
                                        backgroundImage:
                                            NetworkImage(profilePicture),
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
                            commentText,
                            style: TextStyle(fontSize: 12.0),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            _formatTimeDifference(
                                commentData['timestamp'].toDate()),
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatTimeDifference(DateTime postDateTime) {
    Duration difference = DateTime.now().difference(postDateTime);
    int daysDifference = difference.inDays;
    int hoursDifference = difference.inHours;
    int minuteDifference = difference.inMinutes;

    if (daysDifference > 0) {
      return '${daysDifference} hari yang lalu';
    }
    if (hoursDifference > 0) {
      return '${hoursDifference} jam yang lalu';
    }
    return '${minuteDifference} menit yang lalu';
  }
}
