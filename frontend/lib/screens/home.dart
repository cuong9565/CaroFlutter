import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/charts/circle_chart.dart';
import 'package:frontend/widgets/charts/linear_chart.dart';
import 'package:frontend/widgets/rules/rules.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height
        ),
        margin: EdgeInsets.fromLTRB(40, 30, 40, 30),
        color: Colors.transparent,
        
        child: ResponsiveBuilder(
          builder: (context, sizing){
            if(sizing.isDesktop){
              return Container(
                constraints: BoxConstraints(
                  maxWidth: 900
                ),
                child: Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 10,
                        children: [
                          _GameMode(),
                          _Ranking(),
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 300
                      ),
                      child: Column(
                        spacing: 10,
                        children: [
                          _GameProcess(),
                          _GameRules(),
                        ],
                      ),
                    ),
                  ],
                )
                
              );
              
            }
            else{
              return (
                Column(
                  spacing: 20,
                  children: [
                    _GameMode(),
                    _Ranking(),
                    _GameProcess(),
                    _GameRules(),
                  ],
                )
              );
            }
          },
        ),
      )
    );
  }
} 
class _GameMode extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizing){
      return Container(
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
              child: (!sizing.isMobile ? 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.transparent, size: 20),
                    SizedBox(
                      width: 200,
                      child: Row(
                        spacing: 20,
                        children: [
                          Icon(FontAwesomeIcons.userGroup, color: Colors.grey, size: 20),
                          Text("Chơi với một người bạn", style: TextStyle(color: Colors.black, fontSize: 15),),
                        ]
                      ),
                    ),
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                  ]
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.userGroup, color: Colors.grey, size: 20),
                    Text("Chơi với một người bạn", style: TextStyle(color: Colors.black, fontSize: 15),),
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                  ]
                )
              )
            ),
            Button1(
              onPressed: (){
                print("Chơi với máy");
              },
              child: (!sizing.isMobile ? 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.transparent, size: 20),
                    SizedBox(
                      width: 200,
                      child: Row(
                        spacing: 20,
                        children: [
                          Icon(FontAwesomeIcons.robot, color: Colors.grey, size: 20),
                          Text("Chơi với máy", style: TextStyle(color: Colors.black, fontSize: 15),),
                        ]
                      ),
                    ),
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                  ]
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.robot, color: Colors.grey, size: 20),
                    Text("Chơi với máy", style: TextStyle(color: Colors.black, fontSize: 15),),
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                  ]
                )
              )
            ),
            Button1(
              onPressed: (){
                print("Chơi trực tuyến");
              },
              child: (!sizing.isMobile ? 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.transparent, size: 20),
                    SizedBox(
                      width: 200,
                      child: Row(
                        spacing: 20,
                        children: [
                          Icon(FontAwesomeIcons.globe, color: Colors.grey, size: 20),
                          Text("Chơi trực tuyến", style: TextStyle(color: Colors.black, fontSize: 15),),
                        ]
                      ),
                    ),
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                  ]
                ) : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.globe, color: Colors.grey, size: 20),
                    Text("Chơi trực tuyến", style: TextStyle(color: Colors.black, fontSize: 15),),
                    Icon(FontAwesomeIcons.circleQuestion, color: Colors.grey, size: 20)
                  ]
                )
              )
            ),
          ],
        )
      );

    });
    
  }
}
class _Ranking extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(
            width: double.infinity,
            child: DataTable(
              horizontalMargin: 0,
              showCheckboxColumn: false,
              columnSpacing: 8,
              columns: [
                DataColumn(
                  label: Text("Hạng", style: TextStyle()),
                  headingRowAlignment: MainAxisAlignment.start,
                ),
                DataColumn(
                  label: Text("Người chơi", style: TextStyle()),
                  headingRowAlignment: MainAxisAlignment.start,
                ),
                DataColumn(
                  label: Text("W/L/D/Rate", style: TextStyle()),
                  headingRowAlignment: MainAxisAlignment.end,
                ),
              ],
              rows: [
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#1", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Player1")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
                DataRow(
                  onSelectChanged: (indexSelected){
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#999", style: TextStyle(),)),
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.abc_outlined),
                          Text("Me")
                        ],
                      )
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle(),),
                      )
                    ),
                  ],
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}
class _GameProcess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
class _GameRules extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}