import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuwunsewu/services/add_data.dart';

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
    return 0; // Handle the error as needed
  }
}

Future<int> getFollowerCount(String uidSaya) async {
  int jumlahFollower = 0;

  // Dapatkan referensi ke Firestore
  final firestore = FirebaseFirestore.instance;

  // Dapatkan semua dokumen dari koleksi 'userData'
  final users = await firestore.collection('userData').get();

  // Loop pada setiap dokumen user
  for (final user in users.docs) {
    // Dapatkan subkoleksi 'following' dari user ini
    final following = await user.reference.collection('following').get();

    // Periksa apakah user ini mengikuti Anda
    if (following.docs.any((doc) => doc.id == uidSaya)) {
      // Jika ya, tambahkan counter follower
      jumlahFollower++;
    }
  }

  return jumlahFollower;
}

Future<List<DocumentSnapshot>> searchPosts(String query) async {
  QuerySnapshot<Map<String, dynamic>> searchResults = await FirebaseFirestore
      .instance
      .collection(
          'postingan') // Gantilah 'nama_koleksi' dengan nama koleksi Anda
      .where('title', isGreaterThanOrEqualTo: query)
      .get();

  return searchResults.docs;
}
