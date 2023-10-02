import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:playipl/screens/auth/LoginScreen.dart';
import 'package:after_layout/after_layout.dart';
import 'package:playipl/screens/groupScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.green),
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    //await prefs.setBool('seen', false);
    if (_seen) {
      late StreamSubscription<User?> user;
      user = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          print('User is currently signed out!');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => loginScreen()));
        } else {
          print('User is currently signed in!');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const groupScreen()));
        }
      });
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => introScreen()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello'),
      ),
      body: const Center(
        child: Text('This is the second page'),
      ),
    );
  }
}

class introScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 171, 228, 173),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PlayIPL',
              style: TextStyle(fontSize: 39),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Ready to play?',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              child: Row(
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => loginScreen()));
                    },
                    child: Row(
                      children: const [
                        SizedBox(width: 20),
                        Text('Go'),
                        SizedBox(width: 40),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ],
              ),
              width: 150,
            ),
          ],
        ),
      ),
    );
  }
}
