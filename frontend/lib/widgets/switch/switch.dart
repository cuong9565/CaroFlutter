import 'package:flutter/material.dart';

class MySwitch extends StatefulWidget{
  final bool stateSwitch;
  final void Function() onPressed;
  const MySwitch({super.key, required this.stateSwitch, required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return _MySwitch();
  }
}

class _MySwitch extends State<MySwitch>{
  late bool stateSwitch;

  @override
  void initState() {
    super.initState();
    stateSwitch = widget.stateSwitch;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: stateSwitch, 
      onChanged: (state){
        widget.onPressed();
        setState(() {
          stateSwitch = state;
        });
      },
      activeThumbColor: Colors.blue[700],
    );
  }
}