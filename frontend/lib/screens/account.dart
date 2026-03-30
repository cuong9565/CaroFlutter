import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/notifiers/email_notifier.dart';
import 'package:frontend/core/notifiers/gmail_notifier.dart';
import 'package:frontend/core/notifiers/user_notifier.dart';
import 'package:frontend/core/providers/login_with_email_provider.dart';
import 'package:frontend/core/providers/login_with_google_provider.dart';
import 'package:frontend/core/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hovering/hovering.dart';
import 'package:file_picker/file_picker.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  TextEditingController userEdit = TextEditingController();
  TextEditingController emailEdit = TextEditingController();
  late String _username = '';
  late String _email = '';
  late int _totalWins = 0;
  late int _totalLosses = 0;
  late int _totalDraws = 0;
  String? _avartarUrl;
  late int _type = 0;

  PlatformFile? _platformFile;
  bool check = true;

  @override
  void initState() {
    super.initState();

    final data = ref.read(userNotifier);
    // debugPrint(data.toString());
    if (data.hasValue) {
      setState(() {
        _username = data.value!['user']['username'];
        userEdit.value = TextEditingValue(text: _username);
        _totalWins = data.value!['user']['total_wins'];
        _totalLosses = data.value!['user']['total_losses'];
        _totalDraws = data.value!['user']['total_draws'];
        _avartarUrl = data.value!['user']['avartar_url'] ?? '';
        _platformFile = null;
        _type = data.value!['user']['type_login'];
      });
    }

    if (_type == 1) {
      ref.listenManual(emailNotifier, (prev, next) {
        if (next.hasValue && next.value != null) {
          _email = next.value!['email']['email'];
          emailEdit.value = TextEditingValue(text: _email);
        }
      });
    } else if (_type == 2) {
      ref.listenManual(gmailNotifier, (prev, next) {
        if (next.hasValue && next.value != null) {
          _email = next.value!['gmail']['email'];
          emailEdit.value = TextEditingValue(text: _email);
        }
      });
    }
  }

  void delete() async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Alert"),
        content: Text("Are you sure want delete account"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (uid != null) {
                if (_type == 1) {
                  await LoginWithEmailProvider().deleteEmail(uid);
                }
                if (_type == 2) {
                  await LoginWithGoogleProvider().deleteEmail(uid);
                }
                await UserProvider.deleteUser(uid);
                await FlutterSecureStorage().delete(key: 'uid');
                Navigator.of(context).pop();
                context.go('/');
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> update() async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    String? photoUrl = _platformFile?.path.toString();

    if (uid != null && photoUrl != null) {
      await UserProvider.updateUser(uid, _username, photoUrl);
    }
  }

  Future<void> pickImage() async {
    try {
      // Pick an image file using file_picker package
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // If user cancels the picker, do nothing
      if (result == null) return;

      // If user picks an image, update the state with the new image file
      setState(() {
        _platformFile = result.files.first;
      });
    } catch (e) {
      // If there is an error, show a snackbar with the error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          child: Card(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    'Account Manager',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 30.0,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Profile Picture',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(elevation: 0),
                      onHover: (value) => {
                        ElevatedButton.styleFrom(elevation: 0),
                      },
                      onPressed: pickImage,
                      child: HoverContainer(
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        hoverDecoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child:
                            _platformFile != null &&
                                _platformFile!.bytes != null
                            // 1. Ảnh mới chọn
                            ? ClipOval(
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(100.0),
                                  child: Image.memory(
                                    _platformFile!.bytes!,
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              )
                            // 2. Ảnh từ server
                            : (_avartarUrl != null && _avartarUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: SizedBox.fromSize(
                                        size: Size.fromRadius(100.0),
                                        child: Image.network(
                                          _avartarUrl!,
                                          width: 300,
                                          height: 300,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.camera),
                                        ),
                                      ),
                                    )
                                  // 3. fallback
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: MouseRegion(
                                        onEnter: (_) =>
                                            setState(() => check = false),
                                        onExit: (_) =>
                                            setState(() => check = true),
                                        child: check
                                            ? Center(
                                                child: Text(
                                                  'G',
                                                  style: TextStyle(
                                                    fontSize: 30.0,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              )
                                            : const Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons.camera,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      child: Column(
                        children: [
                          Text('Click to upload a new photo'),
                          Text(
                            'JPG, PNG or GIF (MAX. 5MB)',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListTile(title: Text('Display Name')),
                Container(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    controller: userEdit,
                    readOnly: _type == 2 ? true : false,
                    onChanged: (value) => _username = value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                ListTile(title: Text('Email Address')),
                Container(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    readOnly: true,
                    controller: emailEdit,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FaIcon(FontAwesomeIcons.envelope),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Text(
                    'Login to register your email',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Statistics',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                _totalWins.toString(),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Wins',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                _totalLosses.toString(),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Lose',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                _totalDraws.toString(),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                'Draws',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: SizedBox(
                    width: 1280.0,
                    height: 50.0,
                    child: FloatingActionButton(
                      hoverColor: Colors.blue[600],
                      onPressed: update,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.floppyDisk),
                          Padding(padding: EdgeInsets.all(5.0)),
                          Text('Save change'),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Divider(thickness: 1, height: 10.0),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Once you delete your account, there is no going back. Please be certain.',
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        child: SizedBox(
                          width: 200.0,
                          height: 50.0,
                          child: FloatingActionButton(
                            heroTag: 'delete',
                            onPressed: delete,
                            backgroundColor: Colors.red[50],
                            hoverColor: Colors.red[200],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  color: Colors.red,
                                ),
                                Padding(padding: EdgeInsets.all(5.0)),
                                Text(
                                  'Save change',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
