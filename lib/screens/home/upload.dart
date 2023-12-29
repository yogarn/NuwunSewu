import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Uint8List? _image;

  // void saveProfile() async {
  //   String resp = await StoreData().savePostImage(file: _image!); // save image
  //   print(resp);
  //   Navigator.pop(context);
  // }

  String title = "";
  String body = "";

  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
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
                title: Text("Upload postingan"), // judul appbar
                backgroundColor: Colors.purple[100],
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () {
                    // handle the press
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: ListView(children: [
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLines: null,
                      decoration: InputDecoration(
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
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLines: null,
                      decoration: InputDecoration(
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
                    SizedBox(
                      height: 20,
                    ),
                    _image != null
                        ? Center(
                            child: Column(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(_image!)),
                                SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                    onPressed: () => setState(() {
                                          _image = null;
                                        }),
                                    child: Text('Hapus Gambar'))
                              ],
                            ),
                          )
                        : Text(''),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          Uint8List? img = await selectImage();
                          setState(() {
                            _image = img;
                          });
                        },
                        child: Text('Upload Image')),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState != null) {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            try {
                              await StoreData().savePostImage(
                                  file: _image,
                                  title: title,
                                  body: body); // Note: _image can be null
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
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ]),
                ),
              ),
            ),
          );
  }
}