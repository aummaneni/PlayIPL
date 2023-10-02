import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playipl/screens/auth/RegisterScreen.dart';
import 'package:playipl/screens/groupScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class loginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 148, 219, 166),
        title: const Text('Login'),
      ),
      body: loginForm(),
      backgroundColor: Colors.white,
    );
  }
}

class loginForm extends StatefulWidget {
  const loginForm({Key? key}) : super(key: key);

  @override
  State<loginForm> createState() => _loginFormState();
}

class _loginFormState extends State<loginForm> {
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String emailError = "";
  String passwordError = "";
  bool _success = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> tryLogin(
    TextEditingController _eControl,
    TextEditingController _pControl,
  ) async {
    print('trying');
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _eControl.text,
        password: _pControl.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emailError = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        passwordError = 'Wrong password provided for that user.';
      }
    }
    _formkey.currentState!.validate();
    _success = true;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final snackBar = const SnackBar(
    content: Text('Logging in ...'),
    duration: Duration(seconds: 1),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                  //side: BorderSide(color: Colors.black, width: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('PlayIPL', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 30),
                    Container(
                      width: 300,
                      child: TextFormField(
                        autocorrect: false,
                        controller: _emailController,
                        decoration: const InputDecoration(
                            hintText: 'Enter email address'),
                        validator: (value) {
                          if (!emailError.isEmpty)
                            return emailError;
                          else
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
                            hintText: 'Enter password',
                          ),
                          validator: (value) {
                            if (!passwordError.isEmpty)
                              return passwordError;
                            else
                              return null;
                          }),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () {
                            emailError = "";
                            passwordError = "";
                            _scaffoldKey.currentState!.showSnackBar(snackBar);
                            tryLogin(_emailController, _passwordController)
                                .then(
                              (value) {
                                setState(() {
                                  if (_formkey.currentState!.validate()) {
                                    //dispose();
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                groupScreen()));
                                  }
                                });
                              },
                            );
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => registerScreen()));
                          },
                          child: Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
