import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/layout/frame.dart';
import 'package:frontend/widgets/layout/my_custom_paint.dart';
import 'package:frontend/widgets/layout/my_divider.dart';
import 'package:go_router/go_router.dart';

class Game extends StatelessWidget{
  final int sizeGrid = 16;
  const Game({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Frame(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                // spacing: 2,
                children: [
                  MyCustomPaintX(size: 25)
                ],
              ),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    spacing: 0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("User1", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black),),
                      Text("12 giây", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black),),
                    ],
                  ),
                  CircleCountDown(
                    size: 40, 
                    seconds: 5,
                    running: true,
                  ),
                  Text("0", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.grey[600]),),
                  Text(":", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.grey[600]),),
                  Text("0", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.grey[600]),),
                  CircleCountDown(
                    size: 40, 
                    seconds: 5,
                    running: true,
                  ),
                  Column(
                    spacing: 0,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User1", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.black),),
                      Text("12 giây", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black),),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  MyCustomPaintO(size: 25)
                ],
              ),
            ]
          )
        ),
        MyDivider(),
        Expanded(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            child: LayoutBuilder(builder: (context, constraints){
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.minWidth,
                      minHeight: constraints.minHeight,
                    ),
                    child: Center(
                      child: GameBoard(currMoveIsX: true)
                      
                      
                      
                      // Container(
                      //   width: sizeGrid * 25,
                      //   height: sizeGrid * 25,
                      //   margin: EdgeInsets.all(15),
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       top: BorderSide(color: Colors.black, style: BorderStyle.solid, width: 1),
                      //       left: BorderSide(color: Colors.black, style: BorderStyle.solid, width: 1)
                      //     )
                      //   ),
                      //   child: GridView.builder(
                      //     physics: const NeverScrollableScrollPhysics(),
                      //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //       crossAxisCount: sizeGrid,
                      //     ),
                      //     itemCount: sizeGrid * sizeGrid,
                      //     itemBuilder: (context, index){
                      //       return Container(
                      //         decoration: BoxDecoration(
                      //           border: Border(
                      //             bottom: BorderSide(color: Colors.black, style: BorderStyle.solid, width: 1),
                      //             right: BorderSide(color: Colors.black, style: BorderStyle.solid, width: 1),
                      //           )
                      //         ),
                      //       );
                      //     }
                      //   ),
                      // ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        MyDivider(),
        Frame(
          child: Row(
            children: [
              ButtonRectangle2(
                onPressed: (){
                  context.go('/');
                },
                child: Row(
                  spacing: 5,
                  children: [
                    Text("Bỏ cuộc", style: TextStyle(fontSize: 16, color: Colors.black)),
                    Icon(FontAwesomeIcons.flag, size: 16, color: Colors.black),
                  ]
                ),
              )
            ],
          )
        ),
      ],
    );
  }
}