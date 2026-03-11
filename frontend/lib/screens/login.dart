import 'package:encrypter/encrypter/xor.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/providers/login_with_email_provider.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isVisible = true;
  bool _check = false;
  late String _username = "";
  late String _password = "";
  late String _decryptPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: Center(
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, color: Colors.red),
                  ),
                ),
                Text(
                  "Username",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextField(
                    onChanged: (value) => _username = value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Username',
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                Text(
                  "Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextField(
                    obscureText: _isVisible,
                    onChanged: (value) {
                      _password = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Password',
                      contentPadding: EdgeInsets.all(10.0),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _isVisible = !_isVisible;
                        }),
                        icon: Icon(
                          _isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    children: [
                      Text("You don't have any account please sign up: "),
                      InkWell(
                        child: Text(
                          "Click here",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () => context.go("/signin"),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text("Submit"),
                  onPressed: () {
                    check();
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Divider(thickness: 2.0, color: Colors.black),
                ),
                // SignInTest(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void check() {
    LoginWithEmailProvider().checkUserEmail(_username).then((value) {
      _check = value;
    });
    print(_check);
    if (_check == true) {
      LoginWithEmailProvider().getPassword(_username).then((value) {
        _decryptPassword = value;
      });
      print(_decryptPassword);
      String decodePassword = XOR().xorDecode(_decryptPassword);
      print(decodePassword.compareTo(_password));
      if (decodePassword.compareTo(_password) == 0) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("Welecome"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        // context.go("/");
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("Not Good"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }
}

class SignInTest extends StatefulWidget {
  const SignInTest({super.key});

  @override
  State<SignInTest> createState() => _SignInTestState();
}

class _SignInTestState extends State<SignInTest> {
  GoogleSignInAccount? _user;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    // Initialize and listen to authentication events
    await GoogleSignIn.instance.initialize();

    GoogleSignIn.instance.authenticationEvents.listen((event) {
      setState(() {
        _user = switch (event) {
          GoogleSignInAuthenticationEventSignIn() => event.user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };
      });
    });
  }

  Future<void> _signIn() async {
    try {
      // Check if platform supports authenticate
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        await GoogleSignIn.instance.authenticate(scopeHint: ['email']);
      } else {
        // Handle web platform differently
        print('This platform requires platform-specific sign-in UI');
      }
    } catch (e) {
      print('Sign-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _signIn,
      child: Text("Sign In with Google"),
    );
  }
}
