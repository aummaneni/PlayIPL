import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playipl/screens/auth/LoginScreen.dart';
import 'package:playipl/screens/groupScreen.dart';

class registerScreen extends StatelessWidget {
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String emailError = "";
  String confirmError = "";

  /*
  Method that connects and registers the user
  to the database.
  */
  Future tryRegister(
    TextEditingController _eControl,
    TextEditingController _pControl,
  ) async {
    print('trying');
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user;

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _eControl.text,
        password: _pControl.text,
      );
      user = userCredential.user;
      print(_eControl.text);
      print(_pControl.text);
      user = auth.currentUser;

      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: 'monkey@', password: '1');
      print('heyyyyy');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emailError = ('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
      print('monkey');
    }

    CollectionReference players =
        FirebaseFirestore.instance.collection('players');
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final uid = user?.uid;
    players.doc(uid).collection('groups');
    return players.doc(uid).set(
      {
        'name': _nameController.text,
        'email': _eControl.text,
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  /*
  snack bar
  */
  final snackBar = const SnackBar(
    content: Text('Registering ...'),
    duration: Duration(seconds: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Register'),
          centerTitle: true,
          leading: BackButton(onPressed: () {
            Navigator.of(context).pop();
          }),
          backgroundColor: const Color.fromARGB(255, 148, 219, 166),
        ),
        body: Form(
          key: _formkey,
          child: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                height: 500,
                width: 350,
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('PlayIPL', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 70),
                      Container(
                        width: 300,
                        child: TextFormField(
                          autocorrect: false,
                          controller: _nameController,
                          decoration: const InputDecoration(
                              hintText: 'Enter your name'),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: 300,
                        child: TextFormField(
                          autocorrect: false,
                          controller: _emailController,
                          decoration: const InputDecoration(
                              hintText: 'Enter your email'),
                          validator: (value) {
                            if (!_emailController.text.contains("@")) {
                              return 'Enter a valid email address';
                            } else if (!emailError.isEmpty) {
                              return emailError;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: 300,
                        child: TextFormField(
                          autocorrect: false,
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Enter a password',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: 300,
                        child: TextFormField(
                            autocorrect: false,
                            controller: _confirmController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Confirm password',
                            ),
                            validator: (value) {
                              if (_passwordController.text.length < 6) {
                                return 'Password(s) are too short';
                              } else if (!(_passwordController.text ==
                                  _confirmController.text))
                                return 'Passwords do not match';
                              else
                                return null;
                            }),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton(
                              onPressed: () {
                                emailError = "";
                                confirmError = "";
                                _scaffoldKey.currentState!
                                    .showSnackBar(snackBar);
                                tryRegister(
                                        _emailController, _passwordController)
                                    .then((value) {
                                  if (_formkey.currentState!.validate()) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                groupScreen()));
                                  }
                                });
                              },
                              child: Text('Register')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
