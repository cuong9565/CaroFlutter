import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Friends extends StatelessWidget {
  const Friends({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.userPlus, color: Colors.blue),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          ),
                          Text(
                            "Friends Request",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: Text(
                              "2",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEDEDE),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(
                                        100.0,
                                      ),
                                      color: const Color(0xFFBEBFBF),
                                    ),
                                    child: Align(
                                      alignment: AlignmentGeometry.center,
                                      child: Text(
                                        "C",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CoolPlayer88",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("3 mutual friends"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Icon(FontAwesomeIcons.check),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Icon(FontAwesomeIcons.x),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEDEDE),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(
                                        100.0,
                                      ),
                                      color: const Color(0xFFBEBFBF),
                                    ),
                                    child: Align(
                                      alignment: AlignmentGeometry.center,
                                      child: Text(
                                        "G",
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "GameMaster",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("1 mutual friends"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Icon(FontAwesomeIcons.check),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Icon(FontAwesomeIcons.x),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: Text(
                          "Friends Request (4)",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEDEDE),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                            100.0,
                                          ),
                                          color: const Color(0xFFBEBFBF),
                                        ),
                                        child: Align(
                                          alignment: AlignmentGeometry.center,
                                          child: Text(
                                            "D",
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.0,
                                      bottom: 10.0,
                                      child: Container(
                                        width: 16.0,
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                          border: BoxBorder.all(
                                            color: Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DragonMaster",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("45W / 12L - Online"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Challenge"),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Icon(FontAwesomeIcons.comment),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                    fixedSize: Size(100, 25),
                                  ),
                                  child: PopupMenuButton<int>(
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<int>>[
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.userXmark,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text("Remove Friend"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.ban,
                                                  color: Colors.red,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text(
                                                  "Block",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEDEDE),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                            100.0,
                                          ),
                                          color: const Color(0xFFBEBFBF),
                                        ),
                                        child: Align(
                                          alignment: AlignmentGeometry.center,
                                          child: Text(
                                            "Q",
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.0,
                                      bottom: 10.0,
                                      child: Container(
                                        width: 16.0,
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                          border: BoxBorder.all(
                                            color: Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "QueenBee",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("38W / 18L - Online"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Challenge"),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Icon(FontAwesomeIcons.comment),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                    fixedSize: Size(100, 25),
                                  ),
                                  child: PopupMenuButton<int>(
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<int>>[
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.userXmark,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text("Remove Friend"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.ban,
                                                  color: Colors.red,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text(
                                                  "Block",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEDEDE),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                            100.0,
                                          ),
                                          color: const Color(0xFFBEBFBF),
                                        ),
                                        child: Align(
                                          alignment: AlignmentGeometry.center,
                                          child: Text(
                                            "S",
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Positioned(
                                    //   right: 10.0,
                                    //   bottom: 10.0,
                                    //   child: Container(
                                    //     width: 16.0,
                                    //     height: 16.0,
                                    //     decoration: BoxDecoration(
                                    //       shape: BoxShape.circle,
                                    //       color: Colors.green,
                                    //       border: BoxBorder.all(
                                    //         color: Colors.white,
                                    //         width: 2.0,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ShadowNinja",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("52W / 20L - Offline"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Challenge"),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Icon(FontAwesomeIcons.comment),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                    fixedSize: Size(100, 25),
                                  ),
                                  child: PopupMenuButton<int>(
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<int>>[
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.userXmark,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text("Remove Friend"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.ban,
                                                  color: Colors.red,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text(
                                                  "Block",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEDEDE),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                            100.0,
                                          ),
                                          color: const Color(0xFFBEBFBF),
                                        ),
                                        child: Align(
                                          alignment: AlignmentGeometry.center,
                                          child: Text(
                                            "P",
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.0,
                                      bottom: 10.0,
                                      child: Container(
                                        width: 16.0,
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                          border: BoxBorder.all(
                                            color: Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Phoenix99",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("29W / 15L - Online"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text("Challenge"),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Icon(FontAwesomeIcons.comment),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    10.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.black,
                                    fixedSize: Size(100, 25),
                                  ),
                                  child: PopupMenuButton<int>(
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<int>>[
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.userXmark,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text("Remove Friend"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.ban,
                                                  color: Colors.red,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10.0,
                                                    0.0,
                                                    10.0,
                                                    0.0,
                                                  ),
                                                ),
                                                Text(
                                                  "Block",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    0.0,
                                    10.0,
                                    0.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
