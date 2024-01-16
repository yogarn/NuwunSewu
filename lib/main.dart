import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/firebase_options.dart';
import 'package:nuwunsewu/models/pengguna.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:nuwunsewu/screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Pengguna?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: Wrapper(),
      ),
    );
  }
}
