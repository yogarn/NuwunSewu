// navigation.dart

import 'package:flutter/material.dart';
import 'package:nuwunsewu/screens/chats/chats.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/search/search.dart';
import '../post/upload.dart';

class Navigasi extends StatefulWidget {
  static final GlobalKey<_NavigasiState> navigatorKey =
  GlobalKey<_NavigasiState>();

  const Navigasi({Key? key}) : super(key: key);

  @override
  _NavigasiState createState() => _NavigasiState();
}

class _NavigasiState extends State<Navigasi> {
  int _selectedPageIndex = 0;

  void navigateHomePage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  final List _pages = [
    const Home(),
    Search(),
    Upload(),
    Chats(),
    Profile(isRedirected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: navigateHomePage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        unselectedItemColor: Colors.purple[100],
        selectedItemColor: Colors.purple,
      ),
    );
  }
}
