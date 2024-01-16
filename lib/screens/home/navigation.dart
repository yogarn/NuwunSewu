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
    const Upload(),
    Chats(),
    Profile(isRedirected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        currentIndex: _selectedPageIndex,
        onTap: navigateHomePage,
        items: [
          BottomNavigationBarItem(
              backgroundColor: Colors.black,
              icon: _selectedPageIndex == 0
                  ? const Icon(Icons.home_filled)
                  : SizedBox(
                      height: 25,
                      child: Image.asset(
                        'lib/icons/house.png',
                        color: Colors.purple[100],
                      ),
                    ),
              label: ''),
          BottomNavigationBarItem(
              icon: _selectedPageIndex == 1
                  ? SizedBox(
                      height: 25,
                      child: Image.asset(
                        'lib/icons/magnifying.png',
                        color: Colors.purple,
                      ),
                    )
                  : SizedBox(
                      height: 18,
                      child: Image.asset(
                        'lib/icons/loupe.png',
                        color: Colors.purple[100],
                      ),
                    ),
              label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(
              icon: _selectedPageIndex == 3
                  ? const Icon(Icons.chat_bubble)
                  : const Icon(Icons.chat_bubble_outline),
              label: ''),
          BottomNavigationBarItem(
              icon: _selectedPageIndex == 4
                  ? const Icon(Icons.person)
                  : SizedBox(
                      height: 20,
                      child: Image.asset(
                        'lib/icons/user.png',
                        color: Colors.purple[100],
                      ),
                    ),
              label: ''),
        ],
        unselectedItemColor: Colors.purple[100],
        selectedItemColor: Colors.purple,
      ),
    );
  }
}
