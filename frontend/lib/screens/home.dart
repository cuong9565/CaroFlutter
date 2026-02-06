import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/charts/circle_chart.dart';
import 'package:frontend/widgets/charts/linear_chart.dart';
import 'package:frontend/widgets/rules/rules.dart';
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 1000,
        alignment: Alignment.topCenter,
        constraints: BoxConstraints(
          maxWidth: 1000
        ),
        margin: EdgeInsets.all(16),
        color: Colors.yellow[300],
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: 350,
              ),
              child: Column(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: 15,
                      children: [
                        Row(
                          spacing: 15,
                          children: [
                            Icon(FontAwesomeIcons.gamepad, color: Colors.green, size: 30),
                            Text(
                              "Chế độ chơi",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Button1(
                          onPressed: (){
                            print("Chơi với một người bạn");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(FontAwesomeIcons.userGroup, color: Colors.grey, size: 20),
                              Text("Chơi với một người bạn", style: TextStyle(color: Colors.black, fontSize: 15),),
                              Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                            ]
                          ),
                        ),
                        Button1(
                          onPressed: (){
                            print("Chơi với máy");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(FontAwesomeIcons.robot, color: Colors.grey, size: 20),
                              Text("Chơi với máy", style: TextStyle(color: Colors.black, fontSize: 15),),
                              Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                            ]
                          ),
                        ),
                        Button1(
                          onPressed: (){
                            print("Chơi trực tuyến");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(FontAwesomeIcons.globe, color: Colors.grey, size: 20),
                              Text("Chơi trực tuyến", style: TextStyle(color: Colors.black, fontSize: 15),),
                              Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                            ]
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: 20,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Icon(FontAwesomeIcons.trophy, color: Colors.orange, size: 30),
                            Text(
                              "Bảng xếp hạng",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 350,
              ),
              child: Column(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Icon(FontAwesomeIcons.chartLine, color: Colors.green, size: 30),
                            Text(
                              "Tiến trình trò chơi",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        CircleChart(number: 45, total: 70),
                        LinearChart(title: "Thắng", number: 45, total: 70, color: Colors.green),
                        LinearChart(title: "Thua", number: 20, total: 70, color: Colors.red),
                        LinearChart(title: "Hòa", number: 5, total: 70, color: Colors.orange),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Số trận:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "70",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: 20,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Icon(FontAwesomeIcons.book, color: Colors.green, size: 30),
                            Text(
                              "Luật chơi cờ Caro",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Rules()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
} 