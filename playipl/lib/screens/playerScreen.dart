import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class playerScreen extends StatefulWidget {
  final String groupId;
  const playerScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<playerScreen> createState() => _playerScreenState();
}

class _playerScreenState extends State<playerScreen> {
  List<String> allPlayers = [];
  List<String> allIds = [];
  var wins = [];
  var losses = [];
  String admin = "";
  String? uid = "";
  String? userEmail = "";

  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Players'),
          backgroundColor: const Color.fromARGB(255, 148, 219, 166),
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {}
            if (snapshot.connectionState == ConnectionState.done) {
              return RefreshIndicator(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text('Current Players',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: ((context, index) {
                          return Center(
                            child: SizedBox(
                              width: 300,
                              child: ListTile(
                                tileColor: Color.fromARGB(255, 188, 213, 195),
                                title: Text(
                                  allPlayers[index],
                                ),
                                subtitle:
                                    Text('Wins: '+wins[index].toString()+'      Points: '+(wins[index] * 100 + losses[index] * 10).toString()),
                                trailing: SizedBox(
                                  height: 40,
                                  width: 90,
                                  child: FutureBuilder(
                                      future: checkAdmin(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (admin == userEmail &&
                                              index != 0) {
                                            return SizedBox(
                                              height: 10,
                                              width: 9,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary:
                                                      Colors.red, // background
                                                  onPrimary: Colors
                                                      .white, // foreground
                                                ),
                                                onPressed: () async {
                                                  await deletePlayer(index);
                                                  allIds.removeAt(index);
                                                  allPlayers.removeAt(index);
                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  'Remove',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                          }
                                          if (index == 0) {
                                            return const Center(
                                              child: Text("ADMIN"),
                                            );
                                          }
                                        }
                                        return const Center(child: Text(""));
                                      }),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          );
                        }),
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: allPlayers.length,
                      ),
                    ),
                  ],
                ),
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 0), () {
                    setState(() {});
                  });
                },
              );
            }
            return Center(child: const Text('Connecting...'));
          },
        ));
  }

  Future getData() async {
    allPlayers = [];
    allIds = [];
    wins = [];
    losses = [];
    User? user = auth.currentUser;
    userEmail = user?.email;
    CollectionReference _playerRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');

    await _playerRef.orderBy('timestamp').get().then((res) {
      for (var element in res.docs) {
        allPlayers.add(element.data()['name']);
        wins.add(element.get('wins'));
        losses.add(element.get('losses'));
        allIds.add(element.id);
      }
    });
  }

  Future deletePlayer(int index) async {
    CollectionReference _playerRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');
    print(allIds[index]);
    CollectionReference _deleteRef = FirebaseFirestore.instance
        .collection('players')
        .doc(allIds[index])
        .collection('groups');
    await _deleteRef.doc(widget.groupId).delete();
    await _playerRef.doc(allIds[index]).delete();
  }

  Future checkAdmin() async {
    User? user = auth.currentUser;
    uid = user?.uid;
    userEmail = user?.email;
    CollectionReference _adminRef =
        FirebaseFirestore.instance.collection('groups');
    await _adminRef.doc(widget.groupId).get().then((value) {
      admin = value.data()!["admin"];
    });
  }
}
