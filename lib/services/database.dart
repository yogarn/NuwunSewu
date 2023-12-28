// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart';

class DatabaseService {
  DatabaseService();
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userData');

  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('postingan');

  Future updateUserData(String namaLengkap, String username, int gender,
      int tanggalLahir, int bulanLahir, int tahunLahir) async {
    return await userCollection
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({
      'namaLengkap': namaLengkap,
      'username': username,
      'gender': gender,
      'profilePicture': 'defaultProfilePict',
      'tanggalLahir': tanggalLahir,
      'bulanLahir': bulanLahir,
      'tahunLahir': tahunLahir
    });
  }

  Future uploadPost(String title, String body) async {
    return await postCollection.doc().set({
      'uid': FirebaseAuth.instance.currentUser?.uid,
      'title': title,
      'body': body,
      'tanggalJam': FieldValue.serverTimestamp(),
    });
  }
}
