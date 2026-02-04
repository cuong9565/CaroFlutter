import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Button1 extends StatelessWidget{
  const Button1({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states){ return Colors.white; }),
        overlayColor: WidgetStateProperty.resolveWith((states){ 
          if(states.contains(WidgetState.pressed)) return Colors.grey[200];
          return Colors.transparent;   
        }),
        // elevation: WidgetStateProperty.resolveWith((states){ return 2.0; }),
        elevation: WidgetStateProperty.resolveWith((states){ 
          if(states.contains(WidgetState.pressed)) return 0;
          if(states.contains(WidgetState.hovered)) return 3;
          return 1.5;  
        }),
        padding: WidgetStateProperty.resolveWith((states){ return EdgeInsets.all(20); }),
        shape: WidgetStateProperty.resolveWith((states){ return 
          RoundedRectangleBorder( 
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: Colors.grey,
              width: 0.5
            )   
          ); 
        })
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(FontAwesomeIcons.userGroup, color: Colors.grey, size: 20),
          Text("Chơi với một người bạn", style: TextStyle(color: Colors.black, fontSize: 15),),
          Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
        ]
      ),
    );
  }
}