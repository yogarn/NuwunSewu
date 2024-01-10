import 'package:flutter/material.dart';

import 'package:nuwunsewu/screens/chats/chats.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/search/search.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedPageIndex = 0;

  void _navigateHomePage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  final List _pages = [
    const Home(),
    Search(),
    Chats(),
    Profile(isRedirected: false),
  ];

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
        body: _pages[_selectedPageIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPageIndex,
          onTap: _navigateHomePage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          unselectedItemColor: Colors.purple[100],
          selectedItemColor: Colors.purple,
        ),
      ),
    );
  }
}
