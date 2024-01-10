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
    if (user == null) {
      return const Authenticate();
    }
    return const Navigation();
  }
}
