import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/shared/loading.dart';

import 'package:nuwunsewu/screens/chats/chats.dart';
import 'package:nuwunsewu/screens/home/home.dart';
import 'package:nuwunsewu/screens/home/profile.dart';
import 'package:nuwunsewu/screens/search/search.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with TickerProviderStateMixin {
  bool showUploadPage = false;

  void setShowUploadPage(bool kebenaran) {
    setState(() {
      showUploadPage = kebenaran;
    });
  }

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
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _pages[_selectedPageIndex],
            showUploadPage
                ? Upload(setShowUploadPage: setShowUploadPage)
                : const Text(''),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: showUploadPage
            ? Container(
                margin: const EdgeInsets.only(bottom: 45),
                height: 30,
                width: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    setShowUploadPage(!showUploadPage);
                  },
                  backgroundColor: Colors.black,
                  tooltip: "Post",
                  shape: const CircleBorder(),
                  child: Icon(Icons.keyboard_arrow_down_outlined,
                      color: Colors.grey[850], size: 30),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(top: 20),
                height: 90,
                width: 90,
                child: FloatingActionButton(
                  onPressed: () {
                    setShowUploadPage(!showUploadPage);
                  },
                  backgroundColor: Colors.black,
                  tooltip: "Post",
                  shape: const CircleBorder(),
                  child: Icon(Icons.add_rounded,
                      color: Colors.grey[850], size: 80),
                ),
              ),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(color: Colors.black),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: IconButton(
                  onPressed: () {
                    if (!showUploadPage) _navigateHomePage(0);
                  },
                  icon: _selectedPageIndex == 0
                      ? Icon(
                          Icons.home_filled,
                          color: Colors.purple,
                          size: 35,
                        )
                      : Icon(
                          Icons.home_outlined,
                          color: Colors.grey[850],
                          size: 35,
                        ),
                ),
              ),
              Expanded(
                flex: 5,
                child: IconButton(
                  onPressed: () {
                    if (!showUploadPage) _navigateHomePage(1);
                  },
                  icon: _selectedPageIndex == 1
                      ? Icon(
                          Icons.saved_search_rounded,
                          color: Colors.purple,
                          size: 35,
                        )
                      : Icon(
                          Icons.search,
                          color: Colors.grey[850],
                          size: 35,
                        ),
                ),
              ),
              Expanded(flex: 5, child: Container()),
              Expanded(
                flex: 5,
                child: IconButton(
                  onPressed: () {
                    if (!showUploadPage) _navigateHomePage(2);
                  },
                  icon: _selectedPageIndex == 2
                      ? Icon(
                          Icons.chat_bubble,
                          color: Colors.purple,
                          size: 35,
                        )
                      : Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey[850],
                          size: 35,
                        ),
                ),
              ),
              Expanded(
                flex: 5,
                child: IconButton(
                  onPressed: () {
                    if (!showUploadPage) _navigateHomePage(3);
                  },
                  icon: _selectedPageIndex == 3
                      ? Icon(
                          Icons.person,
                          color: Colors.purple,
                          size: 35,
                        )
                      : Icon(
                          Icons.person_outline,
                          color: Colors.grey[850],
                          size: 35,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Upload extends StatefulWidget {
  final Function(bool) setShowUploadPage;

  Upload({required this.setShowUploadPage});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  final List<File> _file = [];

  String title = "";
  String body = "";

  String error = "";

  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : MaterialApp(
            home: Container(
              margin: EdgeInsets.fromLTRB(10.0, 135.0, 10.0, 20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.black),
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 50.0,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        hintText: 'Masukkan judul postingan',
                        label: Text(
                          'Title',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      validator: (val) => val!.isEmpty
                          ? 'Judul postingan tidak boleh kosong!'
                          : null,
                      onChanged: (val) {
                        setState(() {
                          title = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Masukkan isi postingan',
                        label: Text(
                          'Table of Content',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      validator: (val) => val!.isEmpty
                          ? 'Isi postingan tidak boleh kosong!'
                          : null,
                      onChanged: (val) {
                        setState(() {
                          body = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _file.isNotEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: _file.isNotEmpty
                                        ? PageView.builder(
                                            controller: _pageController,
                                            itemCount: _file.length,
                                            itemBuilder: (context, index) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.file(_file[index]),
                                              );
                                            },
                                            onPageChanged: (index) {
                                              _onPageChanged(index);
                                            },
                                          )
                                        : const Text(''),
                                  ),
                                ),
                                _file.length > 1
                                    ? Center(
                                        child: DotsIndicator(
                                          dotsCount: _file.length,
                                          position: _currentIndex,
                                          decorator: DotsDecorator(
                                            size: const Size.square(9.0),
                                            color: Colors.white24,
                                            activeColor: Colors.white,
                                            activeSize: const Size(18.0, 9.0),
                                            activeShape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(''),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () => setState(() {
                                    _file.length = 0;
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.purple,
                                            Color(0xFF212121)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              20,
                                      width: MediaQuery.of(context).size.width /
                                          2.0,
                                      child: Center(
                                        child: const Text(
                                          'Hapus Semua Gambar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(height: 5),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () async {
                          List<XFile> pickedFiles =
                              await ImagePicker().pickMultipleMedia();
                          for (var e in pickedFiles) {
                            _file.add(File(e.path));
                          }
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.purple, Color(0xFF212121)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Center(
                              child: const Text(
                                'Upload Image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate()) {
                              widget.setShowUploadPage(false);
                              setState(() {
                                loading = true;
                              });

                              try {
                                await StoreData().savePostImages(
                                  files: _file,
                                  title: title,
                                  body: body,
                                );
                                setState(() {
                                  loading = false;
                                });
                              } catch (e) {
                                setState(() {
                                  error = "Terjadi kesalahan, coba lagi nanti.";
                                  loading = false;
                                });
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.purple, Color(0xFF212121)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 20,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Center(
                                child: const Text(
                              'Kirim',
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
