import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class MainPopUpLayout{
  final double w;
  final double h;
  final double hHeader = 55;
  final BuildContext btnContext; 
  final String txtHeader;
  final int onPressedLength;
  final List<Widget> widgets;

  const MainPopUpLayout({
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
      context: btnContext, 
      bodyBuilder: (context){
        return SizedBox(
          child: Column(
            children: [
              Container(
                height: hHeader,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(txtHeader, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                )
              ),
              Divider(color: Colors.grey, height: 0, thickness: 1,),
              ...widgets
            ],
          )
        );
      },
    );
  }
}