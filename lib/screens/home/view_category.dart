import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/services/utils.dart';

class ViewCategory extends StatefulWidget {
  final String kategori;
  final String uidTarget;
  ViewCategory({required this.kategori, required this.uidTarget});

  @override
  State<ViewCategory> createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color(0xFF131313),
          title: Text('${widget.kategori}'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          color: Color(0xFF2e2b2b),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('postingan')
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var post = snapshot.data!.docs[index];
                  var uidSender = post['uidSender'];
                  var kategoriTarget = post['kategori'];

                  // cek uid pengirim sama dgn uid user
                  if (uidSender == widget.uidTarget &&
                      kategoriTarget == widget.kategori) {
                    var title = post['title'];
                    var body = post['body'];
                    var dateTime = post['dateTime'];
                    DateTime parsedDateTime =
                        dateTime != null ? dateTime.toDate() : DateTime.now();
                    var postID = (snapshot.data!.docs[index].id);

                    return FutureBuilder<String>(
                      future: getNamaLengkap(uidSender),
                      builder: (context, namaLengkapSnapshot) {
                        if (namaLengkapSnapshot.hasError) {
                          return Text(
                              'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                        }

                        var namaLengkap = namaLengkapSnapshot.data ?? 'null';

                        return FutureBuilder<String>(
                          future: getProfilePicture(uidSender),
                          builder: (context, profilePictureSnapshot) {
                            if (profilePictureSnapshot.hasError) {
                              return Text(
                                  'Error fetching profilePicture: ${profilePictureSnapshot.error}');
                            }

                            var profilePicture = (profilePictureSnapshot.data ==
                                        'defaultProfilePict'
                                    ? 'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain'
                                    : profilePictureSnapshot.data) ??
                                'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

                            return PostWidget(
                              title: title,
                              body: body,
                              imagePaths: [],
                              uidSender: uidSender,
                              dateTime: parsedDateTime,
                              namaLengkap: namaLengkap,
                              profilePicture: profilePicture,
                              postID: postID,
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ));
  }
}
