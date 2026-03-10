import 'package:flutter/material.dart';

class MyLoading extends StatelessWidget {
  final String text;
  const MyLoading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return Center(child: CircularProgressIndicator());
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 30,
        children: [
          Text(text, style: TextStyle(fontSize: 18)),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
