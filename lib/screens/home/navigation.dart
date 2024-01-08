import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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

  // menyimpan index halaman
  int _selectedPageIndex = 0;

  void _navigateHomePage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // list untuk _navigateHomePage
  final List _pages = [
    const Home(),
    Search(),
    Chats(),
    Profile(isRedirected: false,),
  ];

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
      // ilangin debug
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // background
        backgroundColor: Colors.blueGrey[800],
        body: _pages[_selectedPageIndex],
        // Bar bawah
        bottomNavigationBar: BottomNavigationBar(
          // List index ke 0 = HomePage()
          currentIndex: _selectedPageIndex,
          onTap: _navigateHomePage,
          // Isi yg ad di bar bawah
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedItemColor: Colors.purple, // Set the selected item color
          unselectedItemColor: Colors.purple[100],
        ),
      ),
    );
  }
}
