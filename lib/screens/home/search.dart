import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[100],
          elevation: 300,
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              onChanged: (context){},
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(15,30,15,10),
                hintStyle: TextStyle(color: Colors.black),
                border: InputBorder.none,
                hintText: 'Search',
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // suggestion bar
            Row(
              children: [
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
