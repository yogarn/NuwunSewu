import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageHelper {
  final ImagePicker _imagePicker;

  final ImageCropper _imageCropper;

  ImageHelper({
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

    Future<List<File>> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 100,
    bool multiple = false,
  }) async {
    List<XFile>? xFiles;
    if (multiple) {
      xFiles = await _imagePicker.pickMultiImage(imageQuality: imageQuality);
    } else {
      XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );
      xFiles = file != null ? [file] : null;
    }

    if (xFiles != null) {
      return xFiles.map((xFile) => File(xFile.path)).toList();
    } else {
      return [];
    }
  }

  Future<CroppedFile?> crop({
    required XFile file,
    CropStyle cropStyle = CropStyle.rectangle,
  }) async =>
      await _imageCropper.cropImage(
        cropStyle: cropStyle,
        sourcePath: file.path,
      );
}

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('no images selected');
}

Future<Uint8List?> selectImage() async {
  return await pickImage(ImageSource.gallery);
}

Future<String> getNamaLengkap(var uidSender) async {
  var userDataSnapshot = await FirebaseFirestore.instance
      .collection('userData')
      .doc(uidSender)
      .get();
  var namaLengkap = userDataSnapshot['namaLengkap'];
  return namaLengkap;
}

Future<String> getProfilePicture(var uidSender) async {
  var userDataSnapshot = await FirebaseFirestore.instance
      .collection('userData')
      .doc(uidSender)
      .get();
  var namaLengkap = userDataSnapshot['profilePicture'];
  return namaLengkap;
}

String formatTimeDifference(DateTime postDateTime) {
  Duration difference = DateTime.now().difference(postDateTime);
  int daysDifference = difference.inDays;
  int hoursDifference = difference.inHours;
  int minuteDifference = difference.inMinutes;

  if (daysDifference > 0) {
    return '${daysDifference} hari yang lalu';
  } else if (hoursDifference > 0) {
    return '${hoursDifference} jam yang lalu';
  } else {
    return '${minuteDifference} menit yang lalu';
  }
}

Future<int> getLikeCount(String postID) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('postingan')
        .doc(postID)
        .collection('likes')
        .get();

    return querySnapshot.size;
  } catch (error) {
    print('Error getting like count: $error');
    return 0;
  }
}

Future<int> getDislikeCount(String postID) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('postingan')
        .doc(postID)
        .collection('dislikes')
        .get();

    return querySnapshot.size;
  } catch (error) {
    print('Error getting like count: $error');
    return 0;
  }
}

Future<int> getCommentCount(String postID) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('postingan')
        .doc(postID)
        .collection('comments')
        .get();

    return querySnapshot.size;
  } catch (error) {
    print('Error getting like count: $error');
    return 0;
  }
}

Future<int> getFollowingCount(String targetUserID) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userData')
        .doc(targetUserID)
        .collection('following')
        .get();

    return querySnapshot.size;
  } catch (error) {
    print('Error getting like count: $error');
    return 0;
  }
}

Future<int> getFollowerCount(String uidSaya) async {
  int jumlahFollower = 0;

  final firestore = FirebaseFirestore.instance;

  final users = await firestore.collection('userData').get();

  for (final user in users.docs) {
    final following = await user.reference.collection('following').get();

    if (following.docs.any((doc) => doc.id == uidSaya)) {
      jumlahFollower++;
    }
  }

  return jumlahFollower;
}

Future<List<DocumentSnapshot>> searchPosts(String query) async {
  QuerySnapshot<Map<String, dynamic>> searchResults = await FirebaseFirestore
      .instance
      .collection('postingan')
      .where('title', isGreaterThanOrEqualTo: query)
      .get();

  return searchResults.docs;
}

String generateChatID(String userID1, String userID2) {
  List<String> sortedUserIDs = [userID1, userID2]..sort();
  String concatenatedString = sortedUserIDs.join();
  String chatID = sha256.convert(utf8.encode(concatenatedString)).toString();
  return chatID;
}

Future<bool> doesChatExist(String userID1, String userID2) async {
  String chatID = generateChatID(userID1, userID2);
  var chatDoc =
      await FirebaseFirestore.instance.collection('chats').doc(chatID).get();
  return chatDoc.exists;
}

Future<void> startNewChat(String currentUserID, String otherUserID) async {
  String chatID = generateChatID(currentUserID, otherUserID);

  bool chatExists = await doesChatExist(currentUserID, otherUserID);
  if (!chatExists) {
    await FirebaseFirestore.instance.collection('chats').doc(chatID).set({
      'participants': [currentUserID, otherUserID],
    });
  }
}

Future<int> getRepostCount(String postID) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('postingan')
        .doc(postID)
        .collection('reposts')
        .get();

    return querySnapshot.size;
  } catch (error) {
    print('Error getting reposts count: $error');
    return 0;
  }
}
