import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playipl/screens/addGameScreen.dart';
import 'package:playipl/screens/auth/LoginScreen.dart';
import 'package:playipl/screens/playerScreen.dart';
import 'package:playipl/screens/voteScreen.dart';
import 'package:intl/intl.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_admin/src/credential.dart';
import 'package:firebase_admin/src/utils/error.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class yourGroup extends StatefulWidget {
  final String groupId;

  yourGroup({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  String groupName = '';

  State<yourGroup> createState() => _yourGroupState();
}

class _yourGroupState extends State<yourGroup> {
  final _groupController = TextEditingController();
  var nameList = <String>[];
  String groupName = "Your Group";
  String player = "asofa";

  Future<String> getName() async {
    CollectionReference _nameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');

    await _nameRef.get().then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        if (!nameList.contains(element.id)) {
          nameList.add(element.id);
        }
      }
    });

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      groupName = value.data()!['groupName'];

      _groupController.text = groupName;
      return groupName;
    });
    return groupName;
  }

  List<String> countries = const [
    ('CSK'),
    ('DC'),
    ('KKR'),
    ('LSG'),
    ('GT'),
    ('MI'),
    ('PK'),
    ('RR'),
    ('BRC'),
    ('HSR'),
  ];
  List<String> images = const [
    "images/CSKroundbig.png",
    "images/DCroundbig.png",
    "images/KKRroundbig.png",
    "images/LSGroundbig.png",
    "images/GTroundbig.png",
    "images/MIroundbig.png",
    "images/PBKSroundbig.png",
    "images/RRroundbig.png",
    "images/RCBroundbig.png",
    "images/SRHroundbig.png",
  ];

  var allTeam1 = <String>[];
  var allTeam2 = <String>[];
  var allDates = <String>[];
  var allIds = <String>[];
  var voidList = <dynamic>[];
  var playerIds = <dynamic>[];
  bool isPlayer = true;

  Future getData() async {
    isPlayer = true;
    allTeam1 = <String>[];
    allTeam2 = <String>[];
    allDates = <String>[];
    allIds = <String>[];
    playerIds = <String>[];

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    // Get docs from collection reference
    await FirebaseFirestore.instance
        .collection('players')
        .get()
        .then((QuerySnapshot querySnapshot) {});
    CollectionReference _gameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games');
    CollectionReference _playerGameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');
    await _playerGameRef.get().then((QuerySnapshot qS) {
      for (var element in qS.docs) {
        playerIds.add(element.id);
      }

      if (!playerIds.contains(user?.uid)) {
        Navigator.of(context).pop();
        setState(() {});
      }
    });

    await _gameRef.get().then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        allTeam1.add(element.get('team1'));
        allTeam2.add(element.get('team2'));
        var dateTime = DateFormat("MM-dd-yyy  hh:mm a")
            .parse(element.get('dateAndTime'), true);
        var dateLocal = dateTime.toLocal();
        String localDate =
            DateFormat("MM-dd-yyy  hh:mm a").format(dateLocal) + " LOCAL";
        allDates.add(localDate);
        allIds.add(element.id);
      }
    });
    var document = await _playerGameRef.doc(user?.uid);
    await document.get().then((res) {
      voidList = res.data()!['voidList'];
      for (var element in voidList) {
        allTeam1.removeAt(allIds.indexOf(element));
        allTeam2.removeAt(allIds.indexOf(element));
        allIds.remove(element);
      }
    });
  }

  Future setName() async {
    await Future.delayed(Duration(milliseconds: 500));

    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
      'groupName': _groupController.text,
    });
    setState(() {});
  }

  Future addVote(String id, String vote, int index) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final uid = user?.uid;
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(widget.groupId)
        .collection("players")
        .doc(user?.uid)
        .update({
      'voidList': FieldValue.arrayUnion([id]),
    });

    int vt = 0;
    if (vote == allTeam1[index]) {
      vt = 0;
    } else {
      vt = 1;
    }
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games')
        .doc(allIds[index])
        .collection('Votes')
        .doc(user?.uid)
        .set(
      {
        'vote': vt,
      },
    );
  }

  String? title = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: _groupController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                      onEditingComplete: () {
                        setName();
                      },
                    ),
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 148, 219, 166),
              ),
            ),
            ListTile(
              title: Text('Join Code: ${widget.groupId}'),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: const Text('Back to all groups'),
              leading: const Icon(Icons.arrow_back_ios_rounded),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                setState(() {});
              },
            ),

            ListTile(
              leading: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text('Games and Votes'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => voteScreen(
                          groupId: widget.groupId,
                        )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text('Players'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => playerScreen(
                          groupId: widget.groupId,
                        )));
              },
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
            // ListTile(
            //   leading: const Icon(Icons.exit_to_app),
            //   title: const Text('Logout'),
            //   onTap: () async {
            //     await FirebaseAuth.instance.signOut();
            //     Navigator.of(context).pushReplacement(
            //         MaterialPageRoute(builder: (context) => loginScreen()));
            //   },
            // ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
            ),
            delete(groupId: widget.groupId),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: const Color.fromARGB(255, 148, 219, 166),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasError) {}
          if (snapshot.connectionState == ConnectionState.done) {
            String? title = snapshot.data as String;
            return Scaffold(
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(8.0),
                child: add(
                  groupId: widget.groupId,
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endDocked,
              body: RefreshIndicator(
                backgroundColor: null,
                color: Colors.lightGreen,
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 0), () {
                    setState(() {});
                  });
                },
                child: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: SingleChildScrollView(
                    child: RefreshIndicator(
                      color: Colors.lightGreen,
                      backgroundColor: null,
                      onRefresh: () {
                        return Future.delayed(Duration(seconds: 0), () {
                          setState(() {});
                        });
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          pendingPlayers(
                            groupId: widget.groupId,
                          ),
                          FutureBuilder(
                            future: getData(),
                            builder: ((context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: SizedBox(
                                    height: size.height,
                                    child: Scaffold(
                                      body: ListView.separated(
                                          itemCount: allIds.length,
                                          separatorBuilder: (context, index) {
                                            return const SizedBox(
                                              height: 10,
                                            );
                                          },
                                          itemBuilder: (context, index) {
                                            return Center(
                                                child: SizedBox(
                                              width: 300,
                                              child: ListTile(
                                                subtitle: Center(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 20),
                                                      Text(
                                                        allDates[index],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SizedBox(height: 20),
                                                        SizedBox(
                                                          height: 50,
                                                          child: Image.asset(
                                                            images[countries
                                                                .indexOf(
                                                              (allTeam1[index]),
                                                            )],
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        Colors
                                                                            .green),
                                                            padding:
                                                                MaterialStateProperty
                                                                    .all(EdgeInsets
                                                                        .zero),
                                                          ),
                                                          onPressed: () {
                                                            addVote(
                                                              allIds[index],
                                                              allTeam1[index],
                                                              index,
                                                            );
                                                            setState(() {});
                                                          },
                                                          child: Text(
                                                              allTeam1[index]),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(' VS ',
                                                        style: TextStyle(
                                                            fontSize: 14)),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      children: [
                                                        SizedBox(height: 20),
                                                        SizedBox(
                                                          height: 50,
                                                          child: Image.asset(
                                                            images[countries
                                                                .indexOf(
                                                                    allTeam2[
                                                                        index])],
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        Colors
                                                                            .green),
                                                            padding:
                                                                MaterialStateProperty
                                                                    .all(EdgeInsets
                                                                        .zero),
                                                          ),
                                                          onPressed: () {
                                                            addVote(
                                                              allIds[index],
                                                              allTeam2[index],
                                                              index,
                                                            );
                                                            setState(() {});
                                                          },
                                                          child: Text(
                                                              allTeam2[index]),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                tileColor: Color.fromARGB(
                                                    255, 199, 231, 207),
                                                onTap: () {},
                                              ),
                                            ));
                                          }),
                                    ),
                                  ),
                                );
                              }

                              return Text('');
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CupertinoActivityIndicator(
                radius: 10,
              ),
            );
          }
        },
        future: getName(),
      ),
    );
  }
}

class pendingPlayers extends StatefulWidget {
  const pendingPlayers({Key? key, required this.groupId}) : super(key: key);
  final String groupId;
  @override
  State<pendingPlayers> createState() => _pendingPlayersState();
}

class _pendingPlayersState extends State<pendingPlayers> {
  @override
  FirebaseAuth auth = FirebaseAuth.instance;
  String admin = "";
  String? uid = "";
  String? userEmail = "";
  var pendingList = <dynamic>[];
  var uidList = <dynamic>[];
  var emailList = <dynamic>[];

  Future checkAdmin() async {
    User? user = auth.currentUser;
    uid = user?.uid;
    userEmail = user?.email;
    CollectionReference _adminRef =
        FirebaseFirestore.instance.collection('groups');
    await _adminRef.doc(widget.groupId).get().then((value) {
      admin = value.data()!["admin"];
    });
    if (admin == userEmail) {
      pendingList = <String>[];
      CollectionReference _pendingRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('pending');
      await _pendingRef.get().then((QuerySnapshot qs) {
        for (var element in qs.docs) {
          pendingList.add(element.get('name'));
          uidList.add(element.id);
          emailList.add(element.get('email'));
        }
      });
    }
  }

  Future admit(int index) async {
    CollectionReference _addRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');
    await _addRef.doc(uidList[index]).set({
      'email': emailList[index],
      'name': pendingList[index],
      'timestamp': FieldValue.serverTimestamp(),
      'wins': 0,
      'losses': 0,
    });
    await FirebaseFirestore.instance
        .collection('players')
        .doc(uidList[index])
        .collection('groups')
        .doc(widget.groupId)
        .set({});
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('pending')
        .doc(uidList[index])
        .delete();
  }

  Future deny(int index) async {
    CollectionReference _pendRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('pending');
    await _pendRef.doc(uidList[index]).delete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkAdmin(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (admin == userEmail && pendingList.isNotEmpty) {
            return Center(
              child: Column(children: [
                const Text("Pending Player Requests"),
                SizedBox(
                  height: pendingList.length * 50,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.separated(
                    itemCount: pendingList.length,
                    itemBuilder: ((context, index) {
                      return Center(
                        child: SizedBox(
                          child: ListTile(
                            iconColor: Color.fromARGB(255, 148, 219, 166),
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(pendingList[index]),
                            ),
                            trailing: Container(
                              width: 160,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await admit(index);
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.check),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await deny(index);
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.close),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                  ),
                ),
              ]),
            );
          } else {
            return const Text('');
          }
        } else {
          return const Text('');
        }
      }),
    );
  }
}

// ignore: camel_case_types, must_be_immutable
class add extends StatelessWidget {
  add({required this.groupId, Key? key}) : super(key: key);
  final String groupId;
  FirebaseAuth auth = FirebaseAuth.instance;
  String admin = "";
  String? uid = "";
  String? userEmail = "";

  Future checkAdmin() async {
    User? user = auth.currentUser;
    uid = user?.uid;
    userEmail = user?.email;
    CollectionReference _adminRef =
        FirebaseFirestore.instance.collection('groups');
    await _adminRef.doc(groupId).get().then((value) {
      admin = value.data()!["admin"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (admin == userEmail) {
            return FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 148, 219, 166),
              child: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => addGameScreen(
                          groupId: groupId,
                        )),
              ),
            );
          } else {
            return Text('');
          }
        } else
          return Text('');
      }),
      future: checkAdmin(),
    );
  }
}

class delete extends StatelessWidget {
  delete({Key? key, required this.groupId}) : super(key: key);
  final String groupId;
  FirebaseAuth auth = FirebaseAuth.instance;
  String admin = "";
  String? uid = "";
  String? userEmail = "";

  Future permaDelete() async {
    List<String> idList = [];
    User? user = auth.currentUser;
    uid = user?.uid;
    userEmail = user?.email;

    CollectionReference _playerRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('players');
    CollectionReference _allPlayerRef =
        FirebaseFirestore.instance.collection('players');

    await _playerRef.get().then((QuerySnapshot querySnapshot) async {
      for (var element in querySnapshot.docs) {
        idList.add(element.id);
      }
      await _allPlayerRef.get().then((QuerySnapshot querySnapshot) async {
        for (var element in querySnapshot.docs) {
          if (idList.contains(element.id)) {
            await _allPlayerRef
                .doc(element.id)
                .collection('groups')
                .doc(groupId)
                .delete();
          }
        }
      });
    });
    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget deleteButton = TextButton(
      child: const Text("Delete"),
      onPressed: () async {
        await permaDelete();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Deleting this group is a permanent action."),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future checkAdmin() async {
    User? user = auth.currentUser;
    uid = user?.uid;
    userEmail = user?.email;
    CollectionReference _adminRef =
        FirebaseFirestore.instance.collection('groups');
    await _adminRef.doc(groupId).get().then((value) {
      admin = value.data()!["admin"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (admin == userEmail) {
            return ListTile(
              title: Text("Delete Group"),
              leading: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onTap: () async {
                showAlertDialog(context);
              },
            );
          } else {
            return Text('');
          }
        } else
          return Text('');
      }),
      future: checkAdmin(),
    );
  }
}
