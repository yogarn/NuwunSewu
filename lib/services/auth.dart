import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/models/pengguna.dart';
import 'package:nuwunsewu/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //user object
  Pengguna? _userFromFirebaseUser(User? user) {
    return user != null ? Pengguna(uid: user.uid) : null;
  }

  Stream<Pengguna?> get user {
    return _auth
        .authStateChanges()
        .map(_userFromFirebaseUser);
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future SignInWithEmailAndPassword(String email, String pass) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      User? firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(
      String email,
      String pass,
      String namaLengkap,
      String username,
      int gender,
      int tanggalLahir,
      int bulanLahir,
      int tahunLahir,
      String aboutMe) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      User? firebaseUser = result.user;
      await DatabaseService().updateUserData(
          namaLengkap, username, gender, tanggalLahir, bulanLahir, tahunLahir, aboutMe);
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
