import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Button1 extends StatelessWidget{
  final VoidCallback onPressed;
  final Widget child;

  const Button1({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
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
      child: child,
    );
  }
}