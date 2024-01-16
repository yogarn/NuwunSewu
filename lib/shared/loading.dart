import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF1c1b1f),
      child: Center(
          child: SpinKitCircle(
        color: Colors.purple,
        size: 30.0,
      )),
    );
  }
}
