import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class PopUpLayout{
  final double w;
  final double h;
  final double hHeader = 55;
  final BuildContext btnContext; 
  final String txtHeader;
  final int onPressedLength;
  final List<Widget> widgets;

  const PopUpLayout({
    required this.w,
    required this.h,
    required this.btnContext,
    required this.txtHeader,
    required this.onPressedLength,
    required this.widgets,
  });

  void showPopUp(){
    showPopover(
      width: w,
      height: h * onPressedLength + hHeader,
      backgroundColor: Colors.white,
      direction: PopoverDirection.bottom,
      barrierColor: Color.fromRGBO(0, 0, 0, 0.3),
      context: btnContext, 
      bodyBuilder: (context){
        return SizedBox(
          child: Column(
            children: [
              PopUpTitleLayout(
                title: txtHeader,
                width: w,
              ),
              ...widgets
            ],
          )
        );
      },
    );
  }
}

class PopUpTitleLayout extends StatelessWidget{
  final String title;
  final double width;
  final double height = 55;
  final EdgeInsets padding = const EdgeInsets.fromLTRB(10, 0, 10, 0);
  
  const PopUpTitleLayout({super.key, required this.title, required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: height,
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          )
        ),
        Divider(color: Colors.grey, height: 0, thickness: 1,),
      ],
    );
  }
}