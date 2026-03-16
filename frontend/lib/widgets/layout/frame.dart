import 'package:flutter/material.dart';

// Chứa layout cho header hoặc footer
class Frame extends StatelessWidget{
  final Widget child;
  const Frame({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: child
    );
  }
}