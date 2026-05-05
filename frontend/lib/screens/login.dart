import 'package:encrypter/encrypter/xor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/providers/login_with_email_provider.dart';
import 'package:frontend/screens/login_with_google.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isVisible = true;
  late String _username = "";
  late String _password = "";

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
                    "Đăng nhập",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, color: Colors.red),
                  ),
                ),
                Text(
                  "Tên đăng nhập",
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
                      hintText: 'Tên đăng nhập',
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                Text(
                  "Mật khẩu",
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
                      hintText: 'Mật khẩu',
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
                      Text("Bạn chưa có tài khoản? Đăng ký tại đây: "),
                      InkWell(
                        child: Text(
                          "Bấm vào đây",
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () => context.go("/signin"),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text("Đăng nhập"),
                  onPressed: () {
                    check();
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Divider(thickness: 2.0, color: Colors.black),
                ),
                SignInTest(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void check() async {
    // debugPrint('Login submit pressed');
    // debugPrint('Username: $_username');
    // debugPrint('Password length: ${_password.length}');
    if (_username.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Thông báo"),
          content: Text("Tên đăng nhập không được để trống!"),
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
      return;
    }
    if (_password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Thông báo"),
          content: Text("Mật khẩu không được để trống!"),
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
      return;
    }
    debugPrint(await FlutterSecureStorage().read(key: 'uid'));
    bool check = await LoginWithEmailProvider().checkUserEmail(_username);
    // debugPrint('User exists: $check');
    if (check) {
      String decryptPassword = await LoginWithEmailProvider().getPassword(
        _username,
      );
      // debugPrint('Encrypted password: $decryptPassword');
      String decodePassword = XOR().xorDecode(decryptPassword);
      // debugPrint(
      //   'Decoded password matches input: ${decodePassword == _password}',
      // );
      if (decodePassword == _password) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Thông báo"),
            content: Text("Chào mừng"),
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
        try {
          final String id = await LoginWithEmailProvider().getUserId(_username);
          await FlutterSecureStorage().write(key: 'uid', value: id);
          if (!mounted) return;
          context.go("/");
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint('Email login flow failed: $e');
            debugPrint('$st');
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Thông báo"),
              content: Text("Đăng nhập thất bại"),
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
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Thông báo"),
            content: Text("Mật khẩu không đúng"),
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Thông báo"),
          content: Text("Không tìm thấy người dùng"),
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
