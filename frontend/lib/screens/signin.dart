import 'package:encrypter/encrypter/xor.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/providers/login_with_email_provider.dart';
import 'package:go_router/go_router.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SignInState();
}

class _SignInState extends State<Signin> {
  bool _isVisible1 = true;
  bool _isVisible2 = true;
  late String _username = "";
  late String _email = "";
  late String _password = "";
  late String _passwordAgain = "";
  late String _encryptPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: Center(
          child: Container(
            height: 500,
            width: 500,
            decoration: BoxDecoration(border: Border.all()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: Text(
                    "Sign in",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text("Username"),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hint: Text("Username"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    onChanged: (value) => _username = value,
                  ),
                ),
                Text("Email"),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hint: Text("Email"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    onChanged: (value) => _email = value,
                  ),
                ),
                Text("Password"),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    obscureText: _isVisible1,
                    decoration: InputDecoration(
                      hint: Text("Password"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isVisible1 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() {
                          _isVisible1 = !_isVisible1;
                        }),
                      ),
                    ),
                    onChanged: (value) {
                      _password = value;
                    },
                  ),
                ),
                Text("Password again"),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    obscureText: _isVisible2,
                    decoration: InputDecoration(
                      hint: Text("Password again"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isVisible2 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() {
                          _isVisible2 = !_isVisible2;
                        }),
                      ),
                    ),
                    onChanged: (value) {
                      _passwordAgain = value;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    check();
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void check() {
    bool? check1;
    LoginWithEmailProvider()
        .createEmail(_username, _email, _encryptPassword)
        .then((bool value) {
          check1 = value;
        });

    if (_username.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("Username not null"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("okay"),
            ),
          ],
        ),
      );
    }
    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(_email)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("Email is wrong format"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("okay"),
            ),
          ],
        ),
      );
    }
    if (_password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("Password not null"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("okay"),
            ),
          ],
        ),
      );
    }
    if (_passwordAgain.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("Password again not null"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("okay"),
            ),
          ],
        ),
      );
    }
    if (_password.length < 8) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("Length of password at least 8 characters"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("okay"),
            ),
          ],
        ),
      );
    }
    if (_passwordAgain.length < 8) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("Length of password again at least 8 characters"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("okay"),
            ),
          ],
        ),
      );
    }
    if (_password != _passwordAgain) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("Password or password again is not correct"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("okay"),
            ),
          ],
        ),
      );
    } else {
      _encryptPassword = XOR().xorEncode(_password);
      print(check1);
      if (check1 == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("OK"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("okay"),
              ),
            ],
          ),
        );
        context.go('/login');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("Username is already used"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("okay"),
              ),
            ],
          ),
        );
      }
    }
  }
}
