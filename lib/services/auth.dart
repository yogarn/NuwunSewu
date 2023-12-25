import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuwunsewu/models/pengguna.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //user object
  Pengguna? _userFromFirebaseUser(User? user) {
    return user != null ? Pengguna(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<Pengguna?> get user {
    return _auth
        .authStateChanges()
        // .map((User? user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  // sign in anonymous
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

  // sign in dengan email/password
  // register dengan email/password
  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
