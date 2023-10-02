import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class voteScreen extends StatefulWidget {
  final String groupId;

  const voteScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  State<voteScreen> createState() => _voteScreenState();
}

class _voteScreenState extends State<voteScreen> {
  void refresh() {
    setState(() {});
  }

  var allTeam1 = <String>[];
  var allTeam2 = <String>[];
  var allDates = <String>[];
  var allIds = <String>[];
  var voidList = <dynamic>[];
  var allTeam1Count = [];
  var allTeam2Count = [];

  Future getData() async {
    allTeam1 = <String>[];
    allTeam2 = <String>[];
    allDates = <String>[];

    allIds = <String>[];

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    // Get docs from collection reference

    CollectionReference _gameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games');
    CollectionReference _playerGameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');

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

    int idx = -1;
    allTeam1Count = [];
    allTeam2Count = [];

    await _gameRef.get().then((QuerySnapshot querySnapshot) async {
      for (var element in querySnapshot.docs) {
        await _gameRef
            .doc(element.id)
            .collection('Votes')
            .get()
            .then((QuerySnapshot qS) async {
          allTeam1Count.add(0);
          allTeam2Count.add(0);
          idx++;
          for (var el in qS.docs) {
            if (el.get('vote') == 0) {
              allTeam1Count[idx] = allTeam1Count[idx] + 1;
            } else {
              allTeam2Count[idx] = allTeam2Count[idx] + 1;
            }
          }
        });
      }
    });

    // return allGroupIds;
  }

  Future getVoteCount() async {}
  List<String> countries = const [
    'CSK',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 148, 219, 166),
        title: const Text('Games and Votes'),
      ),
      body: RefreshIndicator(
        displacement: 0,
        backgroundColor: null,
        color: Colors.lightGreen,
        onRefresh: () {
          return Future.delayed(Duration(seconds: 0), () {
            setState(() {});
          });
        },
        child: FutureBuilder(
          future: getData(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return Center(child: CupertinoActivityIndicator());
            } else {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView.separated(
                      itemCount: allTeam1.length,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(height: 20),
                                    SizedBox(
                                      height: 50,
                                      child: Image.asset(
                                        images[countries.indexOf(
                                          (allTeam1[index]),
                                        )],
                                      ),
                                    ),
                                    Text(allTeam1Count[index].toString()),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                left(
                                    groupId: widget.groupId,
                                    index: index,
                                    voter: this),
                                const Text(' VS ',
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(
                                  child: right(
                                    groupId: widget.groupId,
                                    index: index,
                                    voter: this,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    SizedBox(height: 20),
                                    SizedBox(
                                      height: 50,
                                      child: Image.asset(
                                        images[
                                            countries.indexOf(allTeam2[index])],
                                      ),
                                    ),
                                    Text(allTeam2Count[index].toString()),
                                  ],
                                ),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            tileColor: Color.fromARGB(255, 199, 231, 207),
                            onTap: null,
                          ),
                        ));
                      }),
                );
              }

              return Text('Waiting');
            }
          }),
        ),
      ),
    );
  }
}

class left extends StatefulWidget {
  final groupId;
  final index;
  final voter;
  const left({Key? key, this.groupId, this.index, this.voter})
      : super(key: key);

  @override
  State<left> createState() => _leftState();
}

class _leftState extends State<left> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String admin = "";
  String? uid = "";
  String? userEmail = "";
  var allTeam1 = <String>[];
  var allTeam2 = <String>[];
  var allDates = <String>[];
  var allIds = <String>[];
  var voidList = <dynamic>[];
  var isAfter = false;
  var allTeam1Count = [];
  var allTeam2Count = [];

  Future getData(int index) async {
    User? user = auth.currentUser;
    uid = user?.uid;
    userEmail = user?.email;
    CollectionReference _adminRef =
        FirebaseFirestore.instance.collection('groups');
    await _adminRef.doc(widget.groupId).get().then((value) {
      admin = value.data()!["admin"];
    });
    allTeam1 = <String>[];
    allTeam2 = <String>[];
    allDates = <String>[];

    allIds = <String>[];

    // Get docs from collection reference

    CollectionReference _gameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games');
    CollectionReference _playerGameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');

    await _gameRef.get().then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        allTeam1.add(element.get('team1'));
        allTeam2.add(element.get('team2'));
        allDates.add(element.get('dateAndTime'));
        allIds.add(element.id);
      }
    });

    int idx = -1;
    allTeam1Count = [];
    allTeam2Count = [];

    await _gameRef.get().then((QuerySnapshot querySnapshot) async {
      for (var element in querySnapshot.docs) {
        await _gameRef
            .doc(element.id)
            .collection('Votes')
            .get()
            .then((QuerySnapshot qS) async {
          allTeam1Count.add(0);
          allTeam2Count.add(0);
          idx++;
          for (var el in qS.docs) {
            if (el.get('vote') == 0) {
              allTeam1Count[idx] = allTeam1Count[idx] + 1;
            } else {
              allTeam2Count[idx] = allTeam2Count[idx] + 1;
            }
          }
        });
      }
    });
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games')
        .doc(allIds[index])
        .get()
        .then(
      (value) {
        var dateTime = DateFormat("MM-dd-yyy  hh:mm a")
            .parse(value.get('dateAndTime'), true);
        var dateLocal = dateTime.toLocal();
        if (DateTime.now().isAfter(dateLocal)) {
          isAfter = true;
        }
      },
    );
    print(DateTime.now().timeZoneName);

    // return allGroupIds;
  }

  var winList = [];
  var loseList = [];
  Future assignLeft() async {
    winList = [];
    loseList = [];
    CollectionReference _gameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games')
        .doc(allIds[widget.index])
        .collection('Votes');
    CollectionReference _playerRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');
    await _gameRef.get().then((QuerySnapshot qS) {
      for (var element in qS.docs) {
        if (element.get('vote') == 0) {
          winList.add(element.id);
        } else if (element.get('vote') == 1) {
          loseList.add(element.id);
        }
      }
    });
    await _playerRef.get().then(
      (QuerySnapshot qS) async {
        for (var element in qS.docs) {
          if (winList.contains(element.id)) {
            await _playerRef.doc(element.id).update({
              'wins': FieldValue.increment(1),
            });
          }
          if (loseList.contains(element.id)) {
            await _playerRef.doc(element.id).update({
              'losses': FieldValue.increment(1),
            });
          }
        }
      },
    );
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games')
        .doc(allIds[widget.index])
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(widget.index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CupertinoActivityIndicator();
          }
          if (snapshot.connectionState == ConnectionState.done &&
              admin == userEmail &&
              isAfter) {
            return SizedBox(
              width: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () async {
                  await assignLeft();
                  widget.voter.refresh();
                },
                child: Center(child: const Icon(Icons.star)),
              ),
            );
          }
          return Text('');
        });
  }
}

class right extends StatefulWidget {
  final groupId;
  final index;
  final voter;
  const right({Key? key, this.index, this.groupId, this.voter})
      : super(key: key);

  @override
  State<right> createState() => _rightState();
}

class _rightState extends State<right> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String admin = "";
  String? uid = "";
  String? userEmail = "";
  var isAfter = false;
  var allTeam1 = <String>[];
  var allTeam2 = <String>[];
  var allDates = <String>[];
  var allIds = <String>[];
  var voidList = <dynamic>[];
  var allTeam1Count = [];
  var allTeam2Count = [];

  Future getData() async {
    User? user = auth.currentUser;
    uid = user?.uid;
    userEmail = user?.email;
    CollectionReference _adminRef =
        FirebaseFirestore.instance.collection('groups');
    await _adminRef.doc(widget.groupId).get().then((value) {
      admin = value.data()!["admin"];
    });
    allTeam1 = <String>[];
    allTeam2 = <String>[];
    allDates = <String>[];

    allIds = <String>[];

    // Get docs from collection reference

    CollectionReference _gameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games');
    CollectionReference _playerGameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');

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
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games')
        .doc(allIds[widget.index])
        .get()
        .then(
      (value) {
        var dateTime = DateFormat("MM-dd-yyy  hh:mm a")
            .parse(value.get('dateAndTime'), true);
        var dateLocal = dateTime.toLocal();
        if (DateTime.now().isAfter(dateLocal)) {
          isAfter = true;
        }
      },
    );

    int idx = -1;
    allTeam1Count = [];
    allTeam2Count = [];

    await _gameRef.get().then((QuerySnapshot querySnapshot) async {
      for (var element in querySnapshot.docs) {
        await _gameRef
            .doc(element.id)
            .collection('Votes')
            .get()
            .then((QuerySnapshot qS) async {
          allTeam1Count.add(0);
          allTeam2Count.add(0);
          idx++;
          for (var el in qS.docs) {
            if (el.get('vote') == 0) {
              allTeam1Count[idx] = allTeam1Count[idx] + 1;
            } else {
              allTeam2Count[idx] = allTeam2Count[idx] + 1;
            }
          }
        });
      }
    });

    // return allGroupIds;
  }

  var winList = [];
  var loseList = [];

  Future assignRight() async {
    winList = [];
    loseList = [];
    CollectionReference _gameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games')
        .doc(allIds[widget.index])
        .collection('Votes');
    CollectionReference _playerRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('players');
    await _gameRef.get().then(
      (QuerySnapshot qS) {
        for (var element in qS.docs) {
          if (element.get('vote') == 1) {
            winList.add(element.id);
          } else if (element.get('vote') == 0) {
            loseList.add(element.id);
          }
        }
      },
    );

    await _playerRef.get().then((QuerySnapshot qS) async {
      for (var element in qS.docs) {
        if (winList.contains(element.id)) {
          await _playerRef.doc(element.id).update({
            'wins': FieldValue.increment(1),
          });
        }
        if (loseList.contains(element.id)) {
          await _playerRef.doc(element.id).update({
            'losses': FieldValue.increment(1),
          });
        }
      }
    });
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games')
        .doc(allIds[widget.index])
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CupertinoActivityIndicator();
          }
          if (snapshot.connectionState == ConnectionState.done &&
              admin == userEmail &&
              isAfter) {
            return SizedBox(
              width: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () async {
                  await assignRight();
                  widget.voter.refresh();
                },
                child: const Icon(Icons.star),
              ),
            );
          }
          return Text('');
        });
  }
}
