import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/services/utils.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  Uint8List? _image;
  bool isSelected = false;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userData');

  void saveProfile() async {
    String resp = await StoreData().saveProfilePicture(file: _image!);
    print(resp);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Color(0xFF2e2b2b),
              title: Text('Upload foto profil'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : StreamBuilder<DocumentSnapshot>(
                              stream: userCollection
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else {
                                  if (snapshot.hasData &&
                                      snapshot.data!.exists) {
                                    Map<String, dynamic> userData =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;

                                    if (userData['profilePicture'] != null) {
                                      return CircleAvatar(
                                        radius: 64,
                                        backgroundImage: NetworkImage(
                                          userData['profilePicture'],
                                        ),
                                      );
                                    } else {
                                      return CircleAvatar(
                                        radius: 64,
                                        backgroundImage: NetworkImage(
                                          '', // Default image
                                        ),
                                      );
                                    }
                                  } else {
                                    return Text('Dokumen tidak ditemukan');
                                  }
                                }
                              },
                            ),
                      Positioned(
                        child: IconButton(
                          onPressed: () async {
                            Uint8List? img = await selectImage();
                            setState(() {
                              _image = img;
                              isSelected = true;
                            });
                          },
                          icon: Icon(Icons.add_a_photo),
                        ),
                        bottom: -10,
                        left: 80,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: (isSelected) ? saveProfile : null,
                      child: Text('Save Profile Picture'))
                ],
              ),
            )),
      ),
    );
  }
}
