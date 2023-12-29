import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';
import 'package:nuwunsewu/services/add_data.dart';

class ExpandPost extends StatefulWidget {
  final String postID;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('postingan');

  final TextEditingController commentController = new TextEditingController();

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
                    // handle the press
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
                          return Loading(); // or some loading indicator
                        } else {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            Map<String, dynamic> postingan =
                                snapshot.data!.data() as Map<String, dynamic>;

                            // Check if the 'profilePicture' field is not empty
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
                                    postingan['imagePath'] != null
                                        ? Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 0, 0, 20),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  postingan['imagePath'],
                                                  fit: BoxFit.fill,
                                                )),
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
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Komentar',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: "Times New Roman",
                                        )),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller:
                                                widget.commentController,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Masukkan komentar anda',
                                              label: Text('Tambah Komentar'),
                                            ),
                                            validator: (val) => val!.isEmpty
                                                ? 'Komentar tidak boleh kosong!'
                                                : null,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (_formKey.currentState !=
                                                  null) {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  try {
                                                    // print(widget.commentController.text);
                                                    await db.tambahKomentar(
                                                        widget.postID,
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        widget.commentController
                                                            .text);
                                                    widget.commentController
                                                        .text = '';
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    // Navigator.pop(context);
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
                                            child: Text('Kirim'),
                                          ),
                                          Text(
                                            error,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14.0),
                                          ),

                                          // Display comments using StreamBuilder
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

// CommentWidget class

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
          return Text('No comments available.');
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

                                var profilePicture = profilePictureSnapshot
                                        .data ??
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
}