import 'package:flutter/material.dart';

class Rules extends StatelessWidget{
  const Rules({super.key});

  @override
  Widget build(BuildContext context) {

    List<String>rules = [
      "Hai người chơi lần lượt đặt quân cờ lên bàn cờ.",
      "Quân trắng đi trước.",
      "Một khi đã đặt quân, không được di chuyển.",
      "Người chơi giành chiến thắng khi đặt được 5 quân cờ liên tiếp theo 1 hàng (chiều ngang, chiều dọc, đường chéo).",
      "Hai người chơi cùng hòa khi bàn cờ đã kín hoặc đã hết thời gian quy định."
    ];

    return Column(
      spacing: 7,
      children: List.generate(rules.length, (index){
        return Row(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${index + 1}.", style: TextStyle(color: Colors.blue, fontSize: 17, fontWeight: FontWeight.bold)),
            Expanded(child: Text(rules[index], style: TextStyle(color: Colors.grey[700], fontSize: 17)))
          ]
        );
      }),
    );
 
  }
}