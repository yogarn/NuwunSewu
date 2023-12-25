import 'package:flutter/material.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/home/upload.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  // menyimpan index halaman
  int _selectedPageIndex = 0;

  void _navigateHomePage(int index){
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // list untuk _navigateHomePage
  final List _pages = [
    Home(),
    Upload(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          //
          onTap: _navigateHomePage,
          // Isi yg ad di bar bawah
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }
}
