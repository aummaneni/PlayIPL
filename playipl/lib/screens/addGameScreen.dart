import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playipl/screens/yourGroup.dart';

class addGameScreen extends StatefulWidget {
  final String groupId;
  const addGameScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<addGameScreen> createState() => _addGameScreenState();
}

class _addGameScreenState extends State<addGameScreen> {
  String selectedValue = "CSK";
  String selectedValue2 = "DC";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 148, 219, 166),
        title: const Text('Create a game'),
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        width: double.infinity,
        //height: MediaQuery.of(context).size.height * 0.70,
        //alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Enter match details', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: 90, child: Image.asset(images[index])),
                      ElevatedButton(
                        child: Text("     $selectedValue    ",
                            style: TextStyle(color: colorVar2)),
                        onPressed: () {
                          showPicker();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 148, 219, 166),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Text(' VS '),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      SizedBox(height: 90, child: Image.asset(images[index2])),
                      ElevatedButton(
                        child: Text(
                          "     $selectedValue2     ",
                          style: TextStyle(color: colorVar2),
                        ),
                        onPressed: () {
                          team2Picker();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 148, 219, 166),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Enter game date and time',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 25),
              Text(
                '$selectedText',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, decoration: TextDecoration.underline),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                child: const Text("Pick a Date"),
                onPressed: () {
                  showDatePicker();
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 148, 219, 166),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedText == '______') {
                    showAlertDialog(context);
                  } else if (selectedValue == selectedValue2) {
                    showAlertDialog2(context);
                  } else {
                    publishMatch();
                  }
                },
                child: const Text(
                  'Publish Match Details',
                ),
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 148, 219, 166),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons

    Widget continueButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text("Missing match date"),
      content:
          const Text("Enter a date for your match to publish match details."),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog2(BuildContext context) {
    // set up the buttons

    Widget continueButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text("Invalid matchup"),
      content: const Text("The teams you have selected cannot be the same. "),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Color colorVar = Colors.white;
  Color colorVar2 = Colors.white;

  List<Text> countries = const [
    Text('CSK'),
    Text('DC'),
    Text('KKR'),
    Text('LSG'),
    Text('GT'),
    Text('MI'),
    Text('PK'),
    Text('RR'),
    Text('BRC'),
    Text('HSR'),
  ];

  Future publishMatch() async {
    CollectionReference _gameRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('games');
    print(selectedText);
    DateTime dt = DateFormat('MM-dd-yyy  hh:mm a').parse(selectedText).toUtc();
    String date = DateFormat('MM-dd-yyy  hh:mm a').format(dt);
    await _gameRef.add(
      {
        'team1': selectedValue,
        'team2': selectedValue2,
        'dateAndTime': date, //selectedText
      },
    ).then((val) {
      Navigator.of(context).pop();
    });
  }

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
  DateTime? selectedDate = null;
  String selectedText = "______";
  void showDatePicker() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (value) {
                if (value != null && value != selectedDate) {
                  setState(() {
                    selectedDate = value;
                    selectedText = DateFormat(
                            selectedDate == null ? "" : 'MM-dd-yyy  hh:mm a')
                        .format(selectedDate!);
                  });
                }
              },
              initialDateTime: DateTime.now(),
              minimumYear: 2021,
              maximumYear: 2100,
            ),
          );
        });
  }

  int index = 0;
  void showPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: CupertinoPicker(
              children: countries,
              onSelectedItemChanged: (value) {
                Text text = countries[value];
                selectedValue = text.data.toString();
                index = value;
                if (selectedValue == selectedValue2) {
                  colorVar = Colors.red;
                } else {
                  colorVar = Colors.white;
                }
                if (selectedValue2 == selectedValue) {
                  colorVar2 = Colors.red;
                } else {
                  colorVar2 = Colors.white;
                }
                setState(() {});
              },
              itemExtent: 25,
              diameterRatio: 1,
              useMagnifier: true,
              magnification: 1.3,
              scrollController: FixedExtentScrollController(
                initialItem: index,
              ),
            ));
      },
    );
  }

  int index2 = 1;
  void team2Picker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: CupertinoPicker(
              children: countries,
              onSelectedItemChanged: (value) {
                Text text = countries[value];
                selectedValue2 = text.data.toString();
                index2 = value;
                if (selectedValue == selectedValue2) {
                  colorVar2 = Colors.red;
                } else {
                  colorVar2 = Colors.white;
                }

                setState(() {});
              },
              itemExtent: 25,
              diameterRatio: 1,
              useMagnifier: true,
              magnification: 1.3,
              scrollController: FixedExtentScrollController(
                initialItem: index2,
              ),
            ));
      },
    );
  }
}
