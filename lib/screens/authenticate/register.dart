import 'package:flutter/material.dart';

List<String> genderList = [
  "Laki-laki",
  "Perempuan",
  "Tidak Memilih"
]; // initialize list untuk gender

class Register extends StatefulWidget {
  final Function toggleSignIn;
  Register({required this.toggleSignIn});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String genderValue =
      genderList.first; // default value untuk gender => laki-laki

  TextEditingController controllerNama = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerUname = TextEditingController();
  TextEditingController controllerPass = TextEditingController();

  void kirimData() {
    // uji coba
    print(controllerNama.text);
    print(controllerEmail.text);
    print(controllerUname.text);
    print(controllerPass.text);
    print(genderValue);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Register Page"), // judul appbar
          backgroundColor: Colors.amber,
          actions: [
            TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                onPressed: () => widget.toggleSignIn(),
                icon: Icon(Icons.person),
                label: Text('Sign In'))
          ],
        ),
        body: ListView(
          // supaya bisa di scroll
          children: [
            Container(
              padding: EdgeInsets.all(20), // buat jarak dari pinggir
              child: Column(
                // kolom untuk form
                crossAxisAlignment: CrossAxisAlignment.start, // align ke kiri
                children: [
                  Container(
                    // nama lengkap
                    margin: EdgeInsets.all(5), // margin antar textfield
                    child: TextField(
                      controller: controllerNama,
                      decoration: InputDecoration(
                        hintText: "John Doe",
                        labelText: "Nama Lengkap:",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    // email address
                    margin: EdgeInsets.all(5),
                    child: TextField(
                      controller: controllerEmail,
                      decoration: InputDecoration(
                        hintText: "example@email.com",
                        labelText: "Email Address:",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    // username
                    margin: EdgeInsets.all(5),
                    child: TextField(
                      controller: controllerUname,
                      decoration: InputDecoration(
                        hintText: "apapun bg",
                        labelText: "Username:",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    // password
                    margin: EdgeInsets.all(5),
                    child: TextField(
                      controller: controllerPass,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "min 8 karakter/digit lur",
                        labelText: "Password:",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    // gender
                    margin: EdgeInsets.all(5),
                    child: DropdownMenu<String>(
                      initialSelection: genderList.first,
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          genderValue = value!;
                        });
                      },
                      dropdownMenuEntries: genderList
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.all(5),
                      child: ElevatedButton(
                          onPressed: kirimData, child: Text("Register")))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
