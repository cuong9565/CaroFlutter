import 'package:flutter/material.dart';
import 'package:frontend/widgets/main_layout.dart';

void main() {
  runApp(MaterialApp(
      title: 'Caro Online',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: SafeArea(child: Mainlayout()),
      debugShowCheckedModeBanner: false,
  ));
}