import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/charts/circle_chart.dart';
import 'package:frontend/widgets/charts/linear_chart.dart';
import 'package:frontend/widgets/layout/pop_up_layout.dart';
import 'package:frontend/widgets/rules/rules.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        margin: EdgeInsets.fromLTRB(40, 30, 40, 30),
        color: Colors.transparent,

        child: ResponsiveBuilder(
          builder: (context, sizing) {
            if (sizing.isDesktop) {
              return Container(
                constraints: BoxConstraints(maxWidth: 900),
                child: Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 10,
                        children: [_GameMode(), _Ranking()],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Column(
                        spacing: 10,
                        children: [_GameProcess(), _GameRules()],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return (Column(
                spacing: 20,
                children: [
                  _GameMode(),
                  _Ranking(),
                  _GameProcess(),
                  _GameRules(),
                ],
              ));
            }
          },
        ),
      ),
    );
  }
}

class _GameMode extends StatelessWidget {
  // Danh sách icon cho nút bấm
  final List<IconData> _iconButton = [
    FontAwesomeIcons.userGroup,
    FontAwesomeIcons.robot,
    FontAwesomeIcons.globe,
  ];
  // Danh sách tiêu đề cho nút bấm
  final List<String> _titleButon = [
    "Chơi với một người bạn",
    "Chơi với máy",
    "Chơi trực tuyến",
  ];
  // Danh sách chức năng cho nút bấm
  final List<void Function(BuildContext)> _functionButton = [
    (BuildContext context) {
      _navigateToPlayWithFriend(context);
    },
    (BuildContext context) {},
    (BuildContext context) {
      context.go('/game-online');
    },
  ];
  // Danh sách chức năng cho nút trợ giúp
  final List<void Function(BuildContext)> _functionHelper = [
    (BuildContext btnContext) {
      final List<String> txts = [
        "Chơi cùng một người bạn",
        "+ Thông qua đường link (hoặc mã QR)",
        "+ Thông qua danh sách bạn bè",
      ];
      _funtionHelperLayout(btnContext, 110, "Chơi với một người bạn", txts);
    },
    (BuildContext btnContext) {
      final List<String> txts = ["Chơi với máy"];
      _funtionHelperLayout(btnContext, 60, "Chơi với máy", txts);
    },
    (BuildContext btnContext) {
      final List<String> txts = [
        "Chơi cùng một người ngẫu nhiên trong danh sách chờ",
      ];
      _funtionHelperLayout(btnContext, 80, "Chơi trực tuyến", txts);
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
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
              for (int i = 0; i < _iconButton.length; i++)
                Button1(
                  onPressed: () {
                    _functionButton[i](context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: !sizing.isMobile
                        ? [
                            CircleButton2(
                              onPressed: (btncontext) =>
                                  _functionHelper[i](btncontext),
                              isVisible: false,
                              child: Icon(
                                FontAwesomeIcons.circleQuestion,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Row(
                                spacing: 20,
                                children: [
                                  Icon(
                                    _iconButton[i],
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  Text(
                                    _titleButon[i],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleButton2(
                              onPressed: (btncontext) =>
                                  _functionHelper[i](btncontext),
                              isVisible: true,
                              child: Icon(
                                FontAwesomeIcons.circleQuestion,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ]
                        : [
                            Icon(_iconButton[i], color: Colors.grey, size: 20),
                            Text(
                              _titleButon[i],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            CircleButton2(
                              onPressed: (btncontext) =>
                                  _functionHelper[i](btncontext),
                              isVisible: true,
                              child: Icon(
                                FontAwesomeIcons.circleQuestion,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Ranking extends StatelessWidget {
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
                for (int i = 0; i < 10; i++)
                  DataRow(
                    onSelectChanged: (indexSelected) {
                      print(indexSelected);
                    },
                    cells: [
                      DataCell(Text("#1", style: TextStyle())),
                      DataCell(
                        Row(
                          children: [Icon(Icons.abc_outlined), Text("Player1")],
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text("150/45/5/76.9%", style: TextStyle()),
                        ),
                      ),
                    ],
                  ),
                DataRow(
                  onSelectChanged: (indexSelected) {
                    print(indexSelected);
                  },
                  cells: [
                    DataCell(Text("#999", style: TextStyle())),
                    DataCell(
                      Row(children: [Icon(Icons.abc_outlined), Text("Me")]),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("150/45/5/76.9%", style: TextStyle()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Khung chứa tiến trình trò chơi
class _GameProcess extends StatelessWidget {
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
          LinearChart(
            title: "Thắng",
            number: 45,
            total: 70,
            color: Colors.green,
          ),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Khung chứa luật chơi
class _GameRules extends StatelessWidget {
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
          Rules(),
        ],
      ),
    );
  }
}

// Khung chứa nội dung trợ giúp
void _funtionHelperLayout(
  BuildContext btnContext,
  double h,
  String txtHeader,
  List<String> txts,
) {
  final double w = 350;
  final EdgeInsets padding = EdgeInsets.fromLTRB(15, 0, 15, 0);

  // Gọi hàm
  PopUpLayout(
    w: w,
    h: h,
    btnContext: btnContext,
    txtHeader: txtHeader,
    onPressedLength: 1,
    widgets: [
      Container(
        width: w,
        height: h,
        padding: padding,
        child: Column(
          spacing: 2,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < txts.length; i++)
              Text(
                txts[i],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    ],
  ).showPopUp();
}

// Hàm chức năng navigate cho nút chơi cùng một người bạn
void _navigateToPlayWithFriend(BuildContext context) {
  context.go('/game');
}
//