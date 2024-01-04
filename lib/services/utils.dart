import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
    return 0; // Handle the error as needed
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
    return 0; // Handle the error as needed
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
    return 0; // Handle the error as needed
  }
}
