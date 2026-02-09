import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hovering/hovering.dart';

class Account extends StatelessWidget {
  const Account({super.key});

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
                    HoverContainer(
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
                      child: HoverTextIcon(),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Guest',
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                ListTile(title: Text('Email Address')),
                Container(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Guest',
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
                                '24',
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
                                '13',
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
                                '5',
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
                      onPressed: () {},
                      hoverColor: Colors.blue[600],
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
                            onPressed: () {},
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

class HoverTextIcon extends StatefulWidget {
  const HoverTextIcon({super.key});

  @override
  State<HoverTextIcon> createState() => _HoverTextIconState();
}

class _HoverTextIconState extends State<HoverTextIcon> {
  bool check = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: MouseRegion(
        onEnter: (PointerEvent details) => setState(() {
          check = false;
        }),
        onExit: (PointerEvent details) => setState(() {
          check = true;
        }),
        child: check
            ? Center(
                child: Text(
                  'G',
                  style: TextStyle(fontSize: 30.0, color: Colors.grey[700]),
                ),
              )
            : Center(
                child: FaIcon(FontAwesomeIcons.camera, color: Colors.white),
              ),
      ),
    );
  }
}
