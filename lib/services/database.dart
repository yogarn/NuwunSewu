// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userData');

  Future updateUserData(String namaLengkap, String username, int gender,
      int tanggalLahir, int bulanLahir, int tahunLahir) async {
    return await userCollection.doc(uid).set({
      'namaLengkap': namaLengkap,
      'username': username,
      'gender': gender,
      'tanggalLahir': tanggalLahir,
      'bulanLahir': bulanLahir,
      'tahunLahir': tahunLahir
    });
  }
}
