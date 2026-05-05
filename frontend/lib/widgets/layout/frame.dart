import 'package:flutter/material.dart';

// Chứa layout cho header hoặc footer
class Frame extends StatelessWidget{
  final Widget child;
  const Frame({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive height and padding
    double frameHeight = screenHeight * 0.08; // 8% of screen height
    double horizontalPadding = screenWidth * 0.03; // 3% of screen width
    
    // Constrain values for better UX
    frameHeight = frameHeight.clamp(50.0, 90.0);
    horizontalPadding = horizontalPadding.clamp(12.0, 30.0);
    
    return Container(
      width: double.infinity,
      height: frameHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      color: Colors.white,
      child: child
    );
  }
}