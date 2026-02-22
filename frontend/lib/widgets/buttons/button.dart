
import 'package:flutter/material.dart';

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
          if(states.contains(WidgetState.pressed)) return Colors.grey[100];
          return Colors.transparent;   
        }),
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

class CircleButton1 extends StatelessWidget{
  final void Function(BuildContext) onPressed;
  final Widget child;

  const CircleButton1({super.key, required this.onPressed, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(context), 
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((state){ return CircleBorder(); }),        
        backgroundColor: WidgetStateProperty.resolveWith((state){ return Colors.grey[200]; }),
        overlayColor: WidgetStateProperty.resolveWith((states){ 
          if(states.contains(WidgetState.pressed)) return Colors.grey[300];
          return Colors.transparent;   
        }),
        elevation: WidgetStateProperty.resolveWith((states){ 
          if(states.contains(WidgetState.pressed)) return 0;
          if(states.contains(WidgetState.hovered)) return 3;
          return 1.5;  
        }),
        padding: WidgetStateProperty.resolveWith((state){ return EdgeInsets.all(15); }),
        minimumSize: WidgetStateProperty.resolveWith((state){ return Size.zero; }),
      ),
      child: child,
    );
  }
}

// class CircleButton2 extends StatelessWidget{
//   final void Function() onPressed;
//   final Widget child;
//   const CircleButton2({super.key, required this.onPressed, required this.child});
  
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: (){ onPressed(); },
//       style: ButtonStyle(
//         shape: WidgetStateProperty.resolveWith((state){ return CircleBorder(); }),
//         backgroundColor: WidgetStateProperty.resolveWith((state){ return Color.fromRGBO(255, 255, 255, 0); }),
//         overlayColor: WidgetStateProperty.resolveWith((state){ 
//           if(state.contains(WidgetState.pressed)) return Colors.grey[200];
//           if(state.contains(WidgetState.hovered)) return Colors.grey[200];
//           return Color.fromRGBO(255, 255, 255, 0);
//         }),
//         elevation: WidgetStateProperty.resolveWith((state){ 
//           if(state.contains(WidgetState.pressed)) return 0; // Khi nhấn
//           if(state.contains(WidgetState.hovered)) return 3; // Khi hover
//           return 0;
//         }),
//         padding: WidgetStatePropertyAll(EdgeInsets.zero), // Bỏ padding mặc định
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,  // Bỏ padding mặc định
//         minimumSize: WidgetStateProperty.all(Size.zero),  // Bỏ padding mặc định
//       ),
//       child: child,
//     );
//   }
// }
class CircleButton2 extends StatelessWidget{
  final bool isVisible;
  final void Function(BuildContext) onPressed;
  final Widget child;
  const CircleButton2({super.key, required this.onPressed, required this.child, required this.isVisible});
  
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      maintainSize: true,       // Bật maintainSize, maintainAnimation, maintainState cùng lúc thì 
      maintainAnimation: true,  // => kích thước element vẫn không đổi và không thể tác động
      maintainState: true,      // Tắt cả 3 thì kích thước element bằng 0 nhưng vẫn chiếm chỗ
      
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: (){ onPressed(context); },
        hoverColor: Colors.grey[200],  // Màu hover
        splashColor: Colors.grey[300], // Màu sau pressed
        child: child,
      )
    );
  }
}

class ButtonRectangle1 extends StatelessWidget{
  final void Function() onPressed;
  final Widget child;
  const ButtonRectangle1({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((state){ return RoundedRectangleBorder(borderRadius: BorderRadius.zero); }),
        backgroundColor: WidgetStateProperty.resolveWith((state){ return Colors.white; }),
        overlayColor: WidgetStateProperty.resolveWith((states){ 
          if(states.contains(WidgetState.pressed)) return Colors.grey[300];
          if(states.contains(WidgetState.hovered)) return Colors.grey[100];
          return Colors.transparent;   
        }),
        elevation: WidgetStateProperty.resolveWith((states){ 
          if(states.contains(WidgetState.pressed)) return 0;
          if(states.contains(WidgetState.hovered)) return 3;
          return 1.5;
        }),
        padding: WidgetStateProperty.resolveWith((state){ return EdgeInsets.fromLTRB(15, 0, 15, 0); }),
      ), 
      child: child
    );
  }
}
class ButtonRectangle2 extends StatelessWidget{
  final void Function() onPressed;
  final Widget child;
  const ButtonRectangle2({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((state){ 
          return RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
            side: BorderSide(
              color: Colors.grey,
              width: 0.5
            ),
          );
        }),
        backgroundColor: WidgetStateProperty.resolveWith((state){ return Colors.white; }),
        overlayColor: WidgetStateProperty.resolveWith((states){
          if(states.contains(WidgetState.pressed)) return Colors.grey[300];
          if(states.contains(WidgetState.hovered)) return Colors.grey[100];
          return Colors.transparent;
        }),
        elevation: WidgetStateProperty.resolveWith((states){
          return 0;
        }),
        
        padding: WidgetStateProperty.resolveWith((state){ return EdgeInsets.fromLTRB(15, 5, 15, 5); }),
      ),
      child: child
    );
  }
}
class ButtonIconForeGround extends StatefulWidget{
  final IconData iconData;
  final double sizeIcon;
  final Color textColor;
  final Color textHoverColor;
  final void Function() onPressed;
  const ButtonIconForeGround({super.key, required this.iconData, required this.sizeIcon, required this.textColor, required this.textHoverColor, required this.onPressed});

  @override
  State<StatefulWidget> createState() => _ButtonIconForeGround();
}

class _ButtonIconForeGround extends State<ButtonIconForeGround>{
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event){
        setState(() {
          isHover = true;
        });
      },
      onExit: (event){
        setState(() {
          isHover = false;
        });
      },
      child: GestureDetector(
        onTap: () => widget.onPressed(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Icon(widget.iconData, size: widget.sizeIcon, color: isHover ? widget.textHoverColor : widget.textColor),
        ),
      )
    );
  }
}