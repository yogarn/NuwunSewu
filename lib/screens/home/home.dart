import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
                Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),
            title: const Text('NuwunSewu'),
            backgroundColor: Colors.purple[100],
          ),
          body: TabBarView(
            children: [
              ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  // ini seharusnya return a widget
                  Container(
                    // start post
                    margin: EdgeInsets.all(20),
                    // height: 350,
                    // width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(20, 20),
                          top: Radius.elliptical(20, 20)),
                      color: Colors.purple[100],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // gambar post
                          Container(
                            padding: const EdgeInsets.all(90),
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green,
                            ),
                          ),
                          // tombol like, share, etc.
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.favorite)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.chat_bubble_rounded)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.share)),
                            ],
                          ),
                          Row(
                            children: [
                              // gambar profile, bisa langusng CircleAvatar(Image)
                              Flexible(flex: 1, child: const CircleAvatar()),
                              // konteks
                              Flexible(
                                flex: 10,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nama Akun",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        // color: Colors.amber,
                                        child: Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Pharetra sit amet aliquam id diam. Pulvinar neque laoreet suspendisse interdum. Nulla porttitor massa id neque aliquam vestibulum morbi. Orci phasellus egestas tellus rutrum tellus pellentesque eu tincidunt.",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          '2 jam yang lalu',
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}
