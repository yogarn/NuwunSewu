import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';

class ExpandPost extends StatefulWidget {
  // const ExpandPost({super.key});

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
                              SizedBox(height: 30),
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

                      // if (userData['profilePicture'] != null) {
                      //   return CircleAvatar(
                      //     radius: 64,
                      //     backgroundImage: NetworkImage(
                      //       userData['profilePicture'],
                      //     ),
                      //   );
                      // } else {
                      //   // Use a default image if 'profilePicture' is empty
                      //   return CircleAvatar(
                      //     radius: 64,
                      //     backgroundImage: NetworkImage(
                      //       'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain', // Default image
                      //     ),
                      //   );
                      // }
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
