import 'package:flutter/material.dart';
import 'package:nuwunsewu/models/pengguna.dart';
import 'package:nuwunsewu/screens/authenticate/authenticate.dart';
import 'package:nuwunsewu/screens/home/navigation.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Pengguna?>(context);
    print(user);
    // mengembalikan antara home atau authenticate
    if (user == null) {
      print('go to authenticate');
      return Authenticate();
    } else {
      return Navigation();
    }
  }
}
