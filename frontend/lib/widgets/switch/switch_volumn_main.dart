import 'package:flutter/material.dart';
import 'package:frontend/widgets/sliders/my_slider.dart';

class SwitchVolumnMain extends StatefulWidget{
  final double h;
  final double currVolumn;
  final double minVolumn;
  final double maxVolumn;
  const SwitchVolumnMain({super.key, required this.h, required this.currVolumn, required this.minVolumn, required this.maxVolumn});
  
  @override
  State<StatefulWidget> createState() {
    return _SwitchVolumnMain();    
  }
}

class _SwitchVolumnMain extends State<SwitchVolumnMain>{
  late double h;
  late double currVolumn;
  late double minVolumn;
  late double maxVolumn;

  @override
  void initState() {
    super.initState();
    h = widget.h;
    currVolumn = widget.currVolumn;
    minVolumn = widget.minVolumn;
    maxVolumn = widget.maxVolumn;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: h,
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Âm lượng: ${currVolumn.toInt()}%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
            ],
          ),
        ),
        MySlider(currValue: currVolumn, minValue: minVolumn, maxValue: maxVolumn, onChange: (value){
          setState(() {
            currVolumn = value;
          });
        }),
      ],
    );
  }
}