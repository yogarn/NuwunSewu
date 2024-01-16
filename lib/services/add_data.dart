import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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

  Future<String> savePostImages(
      {List<File>? files, required String title, required String body, required String kategori}) async {
    String resp = 'some error occurred';
    try {
      String docId = _firestore.collection('postingan').doc().id;

      List<String> imageUrls = [];
      if (files != null && files.isNotEmpty) {
        for (var i = 0; i < files.length; i++) {
          String imagePath = 'postImage/${Uri.encodeComponent(docId)}_$i';

          List<int> bytes = await files[i].readAsBytes();
          Uint8List fileUint8List = Uint8List.fromList(bytes);

          String imageUrl =
              await uploadImageToStorage(imagePath, fileUint8List);
          imageUrls.add(imageUrl);
        }
      }

      await _firestore.collection('postingan').doc(docId).set({
        'title': title,
        'body': body,
        'imagePaths': imageUrls,
        'uidSender': FirebaseAuth.instance.currentUser?.uid,
        'dateTime': FieldValue.serverTimestamp(),
        'kategori': kategori == "" ? "Uncategorized" : kategori,
        'likesCount': 0,
        'dislikesCount': 0,
        'commentsCount': 0,
      });

      resp = 'success';
    } catch (e) {
      resp = e.toString();
    }
    return resp;
  }

  Future<void> tambahKomentar(
      String postID, String uidSender, String teksKomentar) async {
    try {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('postingan').doc(postID);

      await postRef.collection('comments').add({
        'user': uidSender,
        'text': teksKomentar,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Komentar berhasil ditambahkan.');
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> balasKomentar(String postID, String commentID, String uidSender,
      String teksKomentar) async {
    try {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('postingan').doc(postID);

      await postRef
          .collection('comments')
          .doc(commentID)
          .collection('replyComments')
          .add({
        'user': uidSender,
        'text': teksKomentar,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Komentar berhasil ditambahkan.');
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> likePost(String postID, String userID) async {
    await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('likes')
        .doc(userID)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteLikePost(String postID, String userID) async {
    await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('likes')
        .doc(userID)
        .delete();
  }

  Future<bool> hasUserLikedPost(String postID, String userID) async {
    final likeSnapshot = await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('likes')
        .doc(userID)
        .get();
    return likeSnapshot.exists;
  }

  Future<bool> hasUserDislikedPost(String postID, String userID) async {
    final likeSnapshot = await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('dislikes')
        .doc(userID)
        .get();
    return likeSnapshot.exists;
  }

  Future<void> dislikePost(String postID, String userID) async {
    await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('dislikes')
        .doc(userID)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDislikePost(String postID, String userID) async {
    await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('dislikes')
        .doc(userID)
        .delete();
  }

  Future<void> followAccount(String targetUserID, String userID) async {
    await _firestore
        .collection('userData')
        .doc(userID)
        .collection('following')
        .doc(targetUserID)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollowAccount(String targetUserID, String userID) async {
    await _firestore
        .collection('userData')
        .doc(userID)
        .collection('following')
        .doc(targetUserID)
        .delete();
  }

  Future<bool> hasUserFollowAccount(String targetUserID, String userID) async {
    final likeSnapshot = await _firestore
        .collection('userData')
        .doc(userID)
        .collection('following')
        .doc(targetUserID)
        .get();
    return likeSnapshot.exists;
  }

  Future<void> sendMessage(
      String chatID, String senderID, String content) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .add({
      'sender': senderID,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatID)
        .update({'lastTimestamp': FieldValue.serverTimestamp()});
  }

  Future<void> repost(String postID, String userID) async {
    await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('reposts')
        .doc(userID)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> undoRepost(String postID, String userID) async {
    await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('reposts')
        .doc(userID)
        .delete();
  }

  Future<bool> hasUserRepost(String postID, String userID) async {
    final likeSnapshot = await _firestore
        .collection('postingan')
        .doc(postID)
        .collection('reposts')
        .doc(userID)
        .get();
    return likeSnapshot.exists;
  }
}
