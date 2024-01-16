import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  DatabaseService();
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userData');

  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('postingan');

  Future updateUserData(String namaLengkap, String username, int gender,
      int tanggalLahir, int bulanLahir, int tahunLahir, String aboutMe) async {
    return await userCollection
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({
      'namaLengkap': namaLengkap,
      'username': username,
      'gender': gender,
      'profilePicture': 'defaultProfilePict',
      'tanggalLahir': tanggalLahir,
      'bulanLahir': bulanLahir,
      'tahunLahir': tahunLahir,
      'aboutMe': aboutMe
    });
  }
}
