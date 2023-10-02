import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playipl/screens/auth/LoginScreen.dart';
import 'package:playipl/screens/yourGroup.dart';

class groupScreen extends StatefulWidget {
  const groupScreen({Key? key}) : super(key: key);

  @override
  State<groupScreen> createState() => _groupScreenState();
}

class _groupScreenState extends State<groupScreen> {
  var allGroupIds = <String>[];
  var allGroupNames = <String>[];
  TextEditingController joinCode = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  Future getData() async {
    allGroupIds = <String>[];
    allGroupNames = <String>[];
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final uid = user?.uid;
    CollectionReference _collectionRef = FirebaseFirestore.instance
        .collection('players')
        .doc(uid)
        .collection('groups');

    // Get docs from collection reference
    await _collectionRef.get().then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        allGroupIds.add(element.id);
      }
    });

    CollectionReference _nameRef =
        FirebaseFirestore.instance.collection('groups');

    await _nameRef.get().then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        if (allGroupIds.contains(element.id)) {
          allGroupNames.add(element.get('groupName'));
        }
      }
    });
    return allGroupIds;
  }

  String _codeError = '';
  bool error = false;
  Future tryJoin(
    TextEditingController _codeControl,
  ) async {
    CollectionReference _idRef =
        FirebaseFirestore.instance.collection('groups');
    var checkList = <dynamic>[];
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final uid = user?.uid;
    String name = "";
    CollectionReference _name =
        FirebaseFirestore.instance.collection('players');
    await _idRef.get().then((QuerySnapshot querySnapshot) async {
      for (var element in querySnapshot.docs) {
        checkList = [];
        if (_codeControl.text != "" && element.id == _codeControl.text) {
          await _idRef
              .doc(element.id)
              .collection('players')
              .get()
              .then((QuerySnapshot qS) {
            for (var element in qS.docs) {
              checkList.add(element.id);
            }
          });
          if (!checkList.contains(user?.uid)) {
            error = false;
            CollectionReference _playerRef = FirebaseFirestore.instance
                .collection('groups')
                .doc(_codeControl.text)
                .collection('players');

            CollectionReference _pendPlayerRef = FirebaseFirestore.instance
                .collection('groups')
                .doc(_codeControl.text)
                .collection('pending');
            await FirebaseFirestore.instance
                .collection('players')
                .doc(uid)
                .get()
                .then((val) {
              name = val.data()!['name'];
            });
            final CollectionReference players =
                FirebaseFirestore.instance.collection('players');
            await _pendPlayerRef.doc(user?.uid).set({
              'email': user?.email,
              'name': name,
              'timestamp': FieldValue.serverTimestamp(),
            });
            // await players       //use this later STAMP
            //     .doc(uid)
            //     .collection('groups')
            //     .doc(_codeControl.text)
            //     .set({});
            // _playerRef.doc(user?.uid).set({
            //   'admin': '',
            //   'wins': 0,
            //   'losses': 0,
            //   'email': user?.email,
            //   'name': name,
            //   'timestamp': FieldValue.serverTimestamp(),
            // });
            break;
          } else {
            error = true;
          }
        } else {
          error = true;
        }
      }

      if (error) {
        _codeError = 'Group not found';
      }
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        displacement: 0,
        backgroundColor: null,
        color: Colors.lightGreen,
        onRefresh: () {
          return Future.delayed(Duration(seconds: 1), () {
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
                      itemCount: allGroupNames.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 10,
                        );
                      },
                      itemBuilder: (context, index) {
                        return Center(
                            child: SizedBox(
                          width: 300,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: Center(child: Text(allGroupNames[index])),
                            tileColor: Color.fromARGB(255, 199, 231, 207),
                            onTap: () async {
                              await checkGroup(index);

                              setState(() {});
                            },
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PlayIPL',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  SizedBox(height: 85),
                  Text('User: ' + auth.currentUser!.email.toString()),
                ],
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 148, 219, 166),
              ),
            ),
            ListTile(
              title: const Text('Join Group'),
              subtitle: Row(
                children: [
                  Form(
                    key: _formkey,
                    child: Container(
                      width: 200,
                      child: TextFormField(
                        controller: joinCode,
                        decoration: const InputDecoration(
                            hintText: 'Enter group join code'),
                        validator: (value) {
                          if (_codeError.isNotEmpty) {
                            return _codeError;
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _codeError = '';
                      tryJoin(joinCode).then(((value) {
                        setState(() {
                          if (_formkey.currentState!.validate()) {
                            showJoinDialog(context);
                          }
                        });
                      }));
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 2),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => loginScreen()));
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: const Color.fromARGB(255, 148, 219, 166),
        actions: [
          IconButton(
            onPressed: () {
              showAlertDialog(context);
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
    );
  }

  Future checkGroup(int index) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('groups');

      var doc = await collectionRef.doc(allGroupIds[index]).get();
      if (doc.exists) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => yourGroup(
              groupId: allGroupIds[index],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {});
    }
  }
}

String id = "";
String generateName() {
  final random = Random();
  id = random.nextInt(9).toString() +
      "" +
      random.nextInt(9).toString() +
      "" +
      random.nextInt(9).toString() +
      "" +
      random.nextInt(9).toString() +
      "" +
      random.nextInt(9).toString() +
      "";
  FirebaseFirestore.instance
      .collection('groups')
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      if (id == doc) {
        generateName();
        return;
      }
    });
  });
  return id;
}

showJoinDialog(BuildContext context) {
  // set up the buttons

  CupertinoAlertDialog alert = const CupertinoAlertDialog(
    title: Text("Sent Join Request!"),
    content: Text("The group's admin has to accept your request, hang tight!"),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future createGroup() async {
  String yourName = "";
  final CollectionReference groups =
      FirebaseFirestore.instance.collection('groups');
  final CollectionReference players =
      FirebaseFirestore.instance.collection('players');
  FirebaseAuth auth = FirebaseAuth.instance;
  String name = generateName();
  User? user = auth.currentUser;
  final uid = user?.uid;
  await groups.doc(name).set(
    {
      'players': 1,
      'groupName': 'Your Group',
      'admin': FirebaseAuth.instance.currentUser?.email,
    },
  );

  // await groups.doc(name).collection('players').doc('Players').set({});
  await FirebaseFirestore.instance
      .collection('players')
      .doc(uid)
      .get()
      .then((val) {
    yourName = val.data()!['name'];
  });
  await groups
      .doc(name)
      .collection('players')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .set(
    {
      'wins': 0,
      'losses': 0,
      'email': user?.email,
      'name': yourName,
      'timestamp': FieldValue.serverTimestamp(),
    },
  ).then((value) {
    print("done");
  });
  await players.doc(uid).collection('groups').doc(name).set({});
}

class continueButton extends StatefulWidget {
  const continueButton({Key? key}) : super(key: key);

  @override
  State<continueButton> createState() => _continueButtonState();
}

class _continueButtonState extends State<continueButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text("Create"),
      onPressed: () {
        createGroup();
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          print(id);
          return yourGroup(groupId: id);
        }));
        setState(() {});
      },
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () => Navigator.of(context).pop(),
  );
  // Widget continueButton = TextButton(
  //   child: const Text("Create"),
  //   onPressed: () {
  //     createGroup();
  //     Navigator.of(context).pop();
  //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  //       print(id);
  //       return yourGroup(groupId: id);
  //     }));
  //   },
  // );
  // set up the AlertDialog
  CupertinoAlertDialog alert = CupertinoAlertDialog(
    title: const Text("Creating New Group"),
    content: const Text("Would you like to create a new group?"),
    actions: [
      cancelButton,
      const continueButton(),
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
