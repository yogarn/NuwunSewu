import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuwunsewu/services/utils.dart';
import 'package:nuwunsewu/shared/loading.dart';

class Home extends StatelessWidget {
  const Home({Key? key});

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
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'For You'),
                Tab(text: 'Following'),
                Tab(text: 'Trending'),
              ],
            ),
            title: const Text('NuwunSewu'),
            backgroundColor: Colors.purple[100],
          ),
          body: const TabBarView(
            children: [
              FirstTabHome(),
              SecondTabHome(),
              ThirdTabHome(),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstTabHome extends StatefulWidget {
  const FirstTabHome({Key? key}) : super(key: key);

  @override
  _FirstTabHomeState createState() => _FirstTabHomeState();
}

class _FirstTabHomeState extends State<FirstTabHome> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('postingan').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var post = snapshot.data!.docs[index];
            var title = post['title'];
            var body = post['body'];
            var imagePath = post['imagePath'];
            var uidSender = post['uidSender'];
            var dateTime = post['dateTime'];
            DateTime parsedDateTime = dateTime.toDate();

            return FutureBuilder<String>(
              future: getNamaLengkap(uidSender),
              builder: (context, namaLengkapSnapshot) {
                if (namaLengkapSnapshot.hasError) {
                  return Text(
                      'Error fetching namaLengkap: ${namaLengkapSnapshot.error}');
                }

                var namaLengkap =
                    namaLengkapSnapshot.data ?? 'null';

                return FutureBuilder<String>(
                  future: getProfilePicture(uidSender),
                  builder: (context, profilePictureSnapshot) {
                    if (profilePictureSnapshot.hasError) {
                      return Text(
                          'Error fetching profilePicture: ${profilePictureSnapshot.error}');
                    }

                    var profilePicture = profilePictureSnapshot.data ??
                        'https://th.bing.com/th/id/OIP.AYNjdJj4wFz8070PQVh1hAHaHw?rs=1&pid=ImgDetMain';

                    return PostWidget(
                      title: title,
                      body: body,
                      imagePath: imagePath,
                      uidSender: uidSender,
                      dateTime: parsedDateTime,
                      namaLengkap: namaLengkap,
                      profilePicture: profilePicture,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    required this.title,
    required this.body,
    required this.imagePath,
    required this.uidSender,
    required this.dateTime,
    required this.namaLengkap,
    required this.profilePicture,
  });

  final String title;
  final String body;
  final String? imagePath;
  final String uidSender;
  final DateTime dateTime;
  final String namaLengkap;
  final String profilePicture;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.purple[100],
      ),
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: imagePath != null
                    ? Image.network(
                        imagePath!,
                        fit: BoxFit.fill,
                      )
                    : Container(),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: CircleAvatar(
                    radius: 21,
                    backgroundImage: NetworkImage(profilePicture),
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaLengkap,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _formatTimeDifference(dateTime),
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                          ],
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
    );
  }

  String _formatTimeDifference(DateTime postDateTime) {
    Duration difference = DateTime.now().difference(postDateTime);
    int daysDifference = difference.inDays;
    int hoursDifference = difference.inHours;
    int minuteDifference = difference.inMinutes;

    if (daysDifference > 0) {
      return '${daysDifference} ${daysDifference == 1 ? 'day' : 'days'} ago';
    } else if (hoursDifference > 0) {
      return '${hoursDifference} ${hoursDifference == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${minuteDifference} ${minuteDifference == 1 ? 'minute' : 'minutes'} ago';
    }
  }
}

class SecondTabHome extends StatelessWidget {
  const SecondTabHome({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.directions_transit);
  }
}

class ThirdTabHome extends StatelessWidget {
  const ThirdTabHome({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.directions_bike);
  }
}
