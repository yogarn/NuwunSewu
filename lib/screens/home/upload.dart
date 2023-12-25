import 'package:flutter/material.dart';

class Upload extends StatelessWidget {
  const Upload({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Upload Postingan'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
      ),
    );
  }
}
