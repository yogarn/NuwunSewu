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

  final List<File> _file = [];

  String title = "";
  String body = "";

  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : MaterialApp(
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
                      _file.isNotEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      controller: ScrollController(),
                                      thickness: 10,
                                      radius: const Radius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: PageView.builder(
                                          itemCount: _file.length,
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.file(_file[index]),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: () => setState(() {
                                      _file.length = 0;
                                    }),
                                    child: const Text('Hapus Semua Gambar'),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(height: 5),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          List<XFile> pickedFiles =
                              await ImagePicker().pickMultipleMedia();

                          for (var e in pickedFiles) {
                            _file.add(File(e.path));
                          }

                          setState(() {});
                        },
                        child: const Text('Upload Image'),
                      ),
                      const SizedBox(height: 10),
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
                                  error = "Terjadi kesalahan, coba lagi nanti.";
                                  loading = false;
                                });
                              }
                            }
                          }
                        },
                        child: const Text('Kirim'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
