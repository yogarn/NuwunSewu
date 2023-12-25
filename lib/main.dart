import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/firebase_options.dart';
import 'package:nuwunsewu/models/pengguna.dart';
import 'package:nuwunsewu/screens/wrapper.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Pengguna?>.value( //listening authentication
        value: AuthService().user,
        initialData: null,
        child: MaterialApp(home: Wrapper()));
  }
}
