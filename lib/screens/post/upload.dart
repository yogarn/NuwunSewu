import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nuwunsewu/services/add_data.dart';
// import 'package:nuwunsewu/services/database.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  List<File>? _file = [];

  TextEditingController nameController = TextEditingController();

  // void saveProfile() async {
  //   String resp = await StoreData().savePostImage(file: _file!); // save image
  //   print(resp);
  //   Navigator.pop(context);
  // }

  String title = "";
  String body = "";

  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : MaterialApp(
            theme: ThemeData(
              useMaterial3: true,

              // Define the default brightness and colors.
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                // ···
                brightness: Brightness.light,
              ),
            ),
            home: Scaffold(
              appBar: AppBar(
                title: const Text("Upload postingan"), // judul appbar
                backgroundColor: Colors.purple[100],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
                    // handle the press
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      // J U D U L   P O S T
                      TextFormField(
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan judul postingan',
                          label: Text('Judul'),
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
                      // I S I   P O S T
                      const SizedBox(height: 20),
                      TextFormField(
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan isi postingan',
                          label: Text('Isi'),
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
                      // S H O W   U P L O A D   F I L E
                      const SizedBox(height: 20),
                      _file?.length != 0
                          ? Center(
                              child: Column(
                                children: [
                                  // S H O W   F I L E
                                  Container(
                                    height: 200,
                                    child: PageView.builder(
                                      itemCount: _file!.length,
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(_file![index]));
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // D E L E T E    F I L E
                                  ElevatedButton(
                                      onPressed: () => setState(() {
                                            _file?.length = 0;
                                          }),
                                      child: Text('Hapus Gambar'))
                                ],
                              ),
                            )
                          : Text(''),
                      const SizedBox(height: 20),
                      // U P L O A D   F I L E   B U T T O N
                      ElevatedButton(
                        onPressed: () async {
                          List<XFile> pickedFiles = await ImagePicker().pickMultipleMedia();

                          if (pickedFiles != null) {
                            pickedFiles.forEach((e) {
                              _file?.add(File(e.path));
                            });

                            setState(() {
                            });
                          }
                        },
                        child: Text('Upload Image'),
                      ),
                      // S E N D   P O S T
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              try {
                                // loop save
                                for (var i = 0; i < _file!.length; i++) {
                                  
                                }
                                // await StoreData().savePostImage(
                                //     file: _file[Index],
                                //     title: title,
                                //     body: body); // Note: _file can be null
                                setState(() {
                                  Navigator.pop(context);
                                  loading = false;
                                });
                                // Navigator.pop(context);
                              } catch (e) {
                                setState(() {
                                  error =
                                      "Mohon maaf, periksa detail Anda dan coba lagi nanti.";
                                  loading = false;
                                });
                              }
                            }
                          }
                        },
                        child: Text('Kirim'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
