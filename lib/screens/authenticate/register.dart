import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuwunsewu/services/auth.dart';
import 'package:nuwunsewu/shared/loading.dart';

List<String> genderList = [
  "Laki-laki",
  "Perempuan",
  "Tidak Memilih"
  ];

class Register extends StatefulWidget {
  final Function toggleSignIn;
  const Register({super.key, required this.toggleSignIn});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String genderValue = genderList[0];

  String namaLengkap = "";
  String username = "";
  String email = "";
  String pass = "";
  int gender = 0;
  int tanggalLahir = 0;
  int bulanLahir = 0;
  int tahunLahir = 0;

  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.light,
              ),
            ),
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Sign Up'),
                backgroundColor: Colors.purple[100],
                actions: [
                  TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => widget.toggleSignIn(),
                      icon: const Icon(Icons.person),
                      label: const Text('Sign In'))
                ],
              ),
              body: Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: ListView(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'John Doe',
                        label: Text('Nama Lengkap'),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Masukkan nama lengkap!' : null,
                      onChanged: (val) {
                        setState(() {
                          namaLengkap = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'johndoe',
                        label: Text('Username'),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Masukkan username!' : null,
                      onChanged: (val) {
                        setState(() {
                          username = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'example@hackfest.id',
                        label: Text('Email Address'),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Masukkan email!' : null,
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Minimal 8 karakter',
                        label: Text('Password'),
                      ),
                      validator: (val) => val!.length < 8
                          ? 'Password minimal 8 karakter!'
                          : null,
                      obscureText: true,
                      onChanged: (val) {
                        setState(() {
                          pass = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Lahir',
                          style: TextStyle(color: Colors.black),
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: '31',
                                    label: Text('Tanggal'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (val) =>
                                      val!.isEmpty || int.parse(val) > 31
                                          ? 'Tidak valid!'
                                          : null,
                                  onChanged: (val) {
                                    setState(() {
                                      tanggalLahir = int.parse(val);
                                    });
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: '12',
                                    label: Text('Bulan'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (val) =>
                                      val!.isEmpty || int.parse(val) > 12
                                          ? 'Tidak valid!'
                                          : null,
                                  onChanged: (val) {
                                    setState(() {
                                      bulanLahir = int.parse(val);
                                    });
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: '2099',
                                    label: Text('Tahun'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ], // Only numbers can be entered
                                  validator: (val) =>
                                      val!.isEmpty || int.parse(val) > 2099
                                          ? 'Tidak valid!'
                                          : null,
                                  onChanged: (val) {
                                    setState(() {
                                      tahunLahir = int.parse(val);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jenis Kelamin',
                          style: TextStyle(color: Colors.black),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                      value: 1,
                                      groupValue: gender,
                                      onChanged: (value) => setState(() {
                                            gender = value!;
                                            print(gender);
                                          })),
                                  Expanded(
                                    child: Text('Pria'),
                                  )
                                ],
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                      value: 2,
                                      groupValue: gender,
                                      onChanged: (value) => setState(() {
                                            gender = value!;
                                            print(gender);
                                          })),
                                  Expanded(child: Text('Wanita'))
                                ],
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                      value: 0,
                                      groupValue: gender,
                                      onChanged: (value) => setState(() {
                                            gender = value!;
                                            print(gender);
                                          })),
                                  Expanded(child: Text('Lainnya'))
                                ],
                              ),
                              flex: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              dynamic result =
                                  await _auth.registerWithEmailAndPassword(
                                      email,
                                      pass,
                                      namaLengkap,
                                      username,
                                      gender,
                                      tanggalLahir,
                                      bulanLahir,
                                      tahunLahir);
                              if (result == null) {
                                setState(() {
                                  error =
                                      "Mohon maaf, periksa email anda dan coba lagi nanti.";
                                  loading = false;
                                });
                              }
                            }
                          }
                        },
                        child: Text('Register')),
                    const SizedBox(
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
