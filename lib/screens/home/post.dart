import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';

class ExpandPost extends StatefulWidget {
  final String postID;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('postingan');

  ExpandPost({required this.postID});

  @override
  State<ExpandPost> createState() => _ExpandPostState();
}

class _ExpandPostState extends State<ExpandPost> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                stream: widget.userCollection.doc(widget.postID).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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

                          var namaLengkap = namaLengkapSnapshot.data ?? 'null';

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
                                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
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
