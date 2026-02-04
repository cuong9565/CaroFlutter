import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircleChart extends StatelessWidget {
  final int number;
  final int total;

  const CircleChart({super.key, required this.number, required this.total});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 90.0,
      lineWidth: 15.0,
      percent: number / total,
      center: Text(
        "Tỉ lệ thắng\n${(number / total * 100).toStringAsFixed(2)}%", 
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)
      ),
      progressColor: Colors.green,
    );
  }
}