import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({required Uint8List file}) async {
    String resp = 'some error occured';
    try {
      String imagePath = 'profilePicture/${Uri.encodeComponent(FirebaseAuth.instance.currentUser!.uid)}';
      String imageUrl = await uploadImageToStorage(imagePath, file);
      await _firestore.collection('userData').doc(FirebaseAuth.instance.currentUser!.uid).update({
        'profilePicture': imageUrl,
      });
    } catch (e) {
      resp = e.toString();
    }
    return resp;
  }
}
