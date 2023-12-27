import 'package:flutter/material.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/screens/home/navigation.dart';

class Upload extends StatelessWidget {
  const Upload({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          // ···
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          leading: IconButton(onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Navigation()));
          }, icon: const Icon(Icons.arrow_back_ios_rounded)),
          title: const Text('Upload Postingan'),
          backgroundColor: Colors.purple[100],
          elevation: 0.0,
        ),
      ),
    );
  }
}
