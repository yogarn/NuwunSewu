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
