import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
  int repostCount = 0;

  bool isLiked = false;
  bool isDisliked = false;
  bool isReposted = false;

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

    getRepostCount(widget.postID).then((count) {
      setState(() {
        repostCount = count;
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

    db.hasUserRepost(widget.postID, currentUserID).then((reposted) {
      setState(() {
        isReposted = reposted;
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

  Future<void> _toggleRepost() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      final currentUserID = FirebaseAuth.instance.currentUser!.uid;

      if (isReposted) {
        setState(() {
          repostCount -= 1;
          isReposted = false;
        });
        await db.undoRepost(widget.postID, currentUserID);
        FirebaseFirestore.instance
            .collection('postingan')
            .doc(widget.postID)
            .update({
          'repostsCount': FieldValue.increment(-1),
        });
      } else {
        setState(() {
          repostCount += 1;
          isReposted = true;
        });
        await db.repost(widget.postID, currentUserID);
        FirebaseFirestore.instance
            .collection('postingan')
            .doc(widget.postID)
            .update({
          'repostsCount': FieldValue.increment(1),
        });
      }
    });
  }

  String _formatTimeDifference(DateTime postDateTime) {
    Duration difference = DateTime.now().difference(postDateTime);
    int daysDifference = difference.inDays;
    int hoursDifference = difference.inHours;
    int minuteDifference = difference.inMinutes;

    if (daysDifference > 0) {
      return '${daysDifference} hari yang lalu';
    } else if (hoursDifference > 0) {
      return '${hoursDifference} jam yang lalu';
    } else {
      return '${minuteDifference} menit yang lalu';
    }
  }

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
                backgroundColor: Colors.black,
                surfaceTintColor: Colors.transparent,
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
                                          fontSize: 20.0,
                                          fontFamily: "Times New Roman",
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    Text(
                                      namaLengkap,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: "Times New Roman",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      _formatTimeDifference(
                                          postingan['dateTime'].toDate()),
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: "Times New Roman",
                                          fontWeight: FontWeight.w300),
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    postingan['imagePaths'] != null &&
                                            postingan['imagePaths'].isNotEmpty
                                        ? Column(
                                            children: (postingan['imagePaths']
                                                    as List<dynamic>)
                                                .cast<String>()
                                                .map((imagePath) {
                                              return Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 8),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: CachedNetworkImage(
                                                    imageUrl: imagePath,
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
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                await _toggleLikePost();
                                              },
                                              icon: Container(
                                                height: 25,
                                                child: Icon(
                                                    Icons
                                                        .keyboard_arrow_up_sharp,
                                                    size: 40,
                                                    color: isLiked
                                                        ? Colors.purple
                                                        : Colors.grey),
                                              ),
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
                                              icon: Container(
                                                height: 25,
                                                child: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_sharp,
                                                  size: 40,
                                                  color: isDisliked
                                                      ? Colors.purple
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Text(dislikeCount.toString()),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                await _toggleRepost();
                                              },
                                              icon: SizedBox(
                                                height: 25,
                                                child: Image.asset(
                                                    'lib/icons/refresh.png',
                                                    color: isReposted
                                                        ? Colors.purple
                                                        : Colors.grey),
                                              ),
                                            ),
                                            Text(repostCount.toString()),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Text(commentCount.toString()),
                                            IconButton(
                                              onPressed: () {},
                                              icon: SizedBox(
                                                height: 25,
                                                child: Image.asset(
                                                  'lib/icons/chat.png',
                                                  color: Colors.purple,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text('Comment',
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
                                              hintText: "Add Comment",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              suffixIcon: InkWell(
                                                onTap: () async {
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
                                                            .doc(widget.postID)
                                                            .update({
                                                          'commentsCount':
                                                              FieldValue
                                                                  .increment(1),
                                                        });
                                                        widget.commentController
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
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Icon(
                                                    Icons.send,
                                                    color: Colors.purple,
                                                    size: 30,
                                                  ),
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

            return Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20.0),
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

                                var profilePicture = profilePictureSnapshot
                                        .data ??
                                    '';

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
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    } else if (hoursDifference > 0) {
      return '${hoursDifference} jam yang lalu';
    } else {
      return '${minuteDifference} menit yang lalu';
    }
  }
}