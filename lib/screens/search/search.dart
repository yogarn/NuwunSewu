import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuwunsewu/screens/post/upload.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Upload()),
            );
          },
          tooltip: "Post",
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.purple[100],
          // S E A R C H   B U T T O N
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text(
                "Search",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          // T E X T   F I E L D
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              onChanged: (context) {},
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                hintStyle: TextStyle(color: Colors.black),
                border: InputBorder.none,
                hintText: 'Search',
              ),
            ),
          ),
        ),
        // S U G G E S T I O N   S E A R C H
        body: ListView.builder(
          itemCount: 0,
          itemBuilder: (context, index) => ListTile(

          ),
        ),
      ),
    );
  }
}
