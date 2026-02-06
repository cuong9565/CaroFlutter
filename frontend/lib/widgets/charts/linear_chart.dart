import 'package:flutter/material.dart';

class LinearChart extends StatelessWidget {
  final String title;
  final int number;
  final int total;
  final Color color;

  const LinearChart({
    super.key,
    required this.title,
    required this.number,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              number.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        LinearProgressIndicator(
            value: number * 1.0 / total,
            minHeight: 10.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}