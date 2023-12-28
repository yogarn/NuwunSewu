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

  Future<String> saveProfilePicture({required Uint8List file}) async {
    //ignore this func
    String resp = 'some error occured';
    try {
      String imagePath =
          'profilePicture/${Uri.encodeComponent(FirebaseAuth.instance.currentUser!.uid)}';
      String imageUrl = await uploadImageToStorage(imagePath, file);
      await _firestore
          .collection('userData')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'profilePicture': imageUrl,
      });
    } catch (e) {
      resp = e.toString();
    }
    return resp;
  }

  Future<String> savePostImage(
      {Uint8List? file, required String title, required String body}) async {
    String resp = 'some error occurred';
    try {
      String docId = _firestore.collection('postingan').doc().id;

      if (file != null) {
        // Upload the image to storage if file is provided
        String imagePath = 'postImage/${Uri.encodeComponent(docId)}';
        String imageUrl = await uploadImageToStorage(imagePath, file);

        // Save post data to Firestore with image
        await _firestore.collection('postingan').doc(docId).set({
          'title': title,
          'body': body,
          'imagePath': imageUrl,
          'uidSender': FirebaseAuth.instance.currentUser?.uid,
          'dateTime': FieldValue.serverTimestamp(),
        });
      } else {
        // Save post data to Firestore without image
        await _firestore.collection('postingan').doc(docId).set({
          'title': title,
          'body': body,
          'imagePath': null,
          'uidSender': FirebaseAuth.instance.currentUser?.uid,
          'dateTime': FieldValue.serverTimestamp(),
        });
      }

      resp = 'success';
    } catch (e) {
      resp = e.toString();
    }
    return resp;
  }
}
