import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuwunsewu/services/add_data.dart';
import 'package:nuwunsewu/shared/loading.dart';

class Upload extends StatefulWidget {
  const Upload({Key? key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  List<File>? _file = [];

  TextEditingController nameController = TextEditingController();

  String title = "";
  String body = "";

  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : MaterialApp(
            // Your existing theme and home widget
            home: Scaffold(
              appBar: AppBar(
                title: const Text("Upload postingan"),
                backgroundColor: Colors.purple[100],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
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
                      const SizedBox(height: 20),
                      _file?.length != 0
                          ? Center(
                              child: Column(
                                children: [
                                  Container(
                                    height: 200,
                                    child: PageView.builder(
                                      itemCount: _file!.length,
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.file(_file![index]),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
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
                      ElevatedButton(
                        onPressed: () async {
                          List<XFile> pickedFiles =
                              await ImagePicker().pickMultipleMedia();

                          if (pickedFiles != null) {
                            pickedFiles.forEach((e) {
                              _file?.add(File(e.path));
                            });

                            setState(() {});
                          }
                        },
                        child: Text('Upload Image'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate()) {
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
                                  Navigator.pop(context);
                                  loading = false;
                                });
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
