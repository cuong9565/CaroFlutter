import 'package:flutter/material.dart';

class MySlider extends StatefulWidget{
  final double currValue;
  final double minValue;
  final double maxValue;
  final void Function(double) onChange;

  const MySlider({super.key, required this.currValue, required this.minValue, required this.maxValue, required this.onChange});  

  @override
  State<StatefulWidget> createState() {
    return _MySlider();
  }
}

class _MySlider extends State<MySlider>{
  late double currentValue;
  late double maxValue;
  late double minValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.currValue;
    minValue = widget.minValue;
    maxValue = widget.maxValue;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Slider(
      value: currentValue, 
      min: minValue,
      max: maxValue,
      onChanged: (state){
        widget.onChange(state);
        setState(() {
          currentValue = state;
        });
      }
    );
  }
}