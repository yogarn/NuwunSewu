import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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


  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
      isSelected = true;
    });
  }

  void saveProfile() async {
    String resp = await StoreData().saveData(file: _image!);
    print(resp);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.purple[100],
            title: Text('Upload foto profil'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () {
                // handle the press
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
                                return CircularProgressIndicator(); // or some loading indicator
                              } else {
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  Map<String, dynamic> userData = snapshot.data!
                                      .data() as Map<String, dynamic>;

                                  // Check if the 'profilePicture' field is not empty
                                  if (userData['profilePicture'] != null) {
                                    return CircleAvatar(
                                      radius: 64,
                                      backgroundImage: NetworkImage(
                                        userData['profilePicture'],
                                      ),
                                    );
                                  } else {
                                    // Use a default image if 'profilePicture' is empty
                                    return CircleAvatar(
                                      radius: 64,
                                      backgroundImage: NetworkImage(
                                        'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain', // Default image
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
                        onPressed: () {
                          selectImage();
                        },
                        icon: Icon(Icons.add_a_photo),
                      ),
                      bottom: -10,
                      left: 80,
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: (isSelected) ? saveProfile : null, child: Text('Save Profile Picture'))
              ],
            ),
          )),
    );
  }
}
