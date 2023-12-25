import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService ({required this.uid});
  // collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('userData');

  Future updateUserData(String namaLengkap, String username, int gender, int tanggalLahir, int bulanLahir, int tahunLahir) async {
    return await userCollection.doc(uid).set({
      'namaLengkap': namaLengkap,
      'username': username,
      'gender': gender,
      'tanggalLahir': tanggalLahir,
      'bulanLahir': bulanLahir,
      'tahunLahir': tahunLahir
    });
  }

  Stream<QuerySnapshot> get userData {
    return userCollection.snapshots();
  }

}