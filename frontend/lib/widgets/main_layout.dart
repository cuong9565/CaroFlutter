import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/screens/account.dart';
import 'package:frontend/screens/chat.dart';
import 'package:frontend/screens/friends.dart';
import 'package:frontend/screens/history.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/layout/pop_up_layout.dart';
import 'package:frontend/widgets/switch/switch.dart';
import 'package:frontend/widgets/switch/switch_volumn_main.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class Mainlayout extends StatefulWidget {
  const Mainlayout({super.key});

  @override
  State<Mainlayout> createState() => _MainLayout();
}

class _MainLayout extends State<Mainlayout> {
  int _selectedIndex = 0;
  bool _isExpanded = true;

  final List<Widget> _pages = [Home(), Chat(), Friends(), History(), Account()];

  // Danh sách icon cho navbar
  final List<IconData> _iconsNavigation = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.message,
    FontAwesomeIcons.userGroup,
    FontAwesomeIcons.clockRotateLeft,
    FontAwesomeIcons.userGear,
  ];

  // Danh sách tên navbar
  final List<String> _titleNavigation = [
    "Trang chủ",
    "Nhắn tin",
    "Bạn bè",
    "Lịch sử đấu",
    "Tài khoản"
  ];

  // Danh sách các hàm cho chức năng ở header
  final List<void Function(BuildContext)> showPopOverFunctions = [
    _showPopOverUser,
    _showPopOverAlert,
    _showPopOverSetting
  ];

  // Danh sách icon cho chức năng ở header
  final List<IconData> popOverFunctionsIcon = [
    FontAwesomeIcons.user,
    FontAwesomeIcons.bell,
    FontAwesomeIcons.gear
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  child: Row(
                    spacing: 10,
                    children: [
                      Image(
                        image: AssetImage('assets/images/logo.png'),
                        width: 50,
                        height: 50,
                      ),
                      Text(
                        'Caro Online',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  spacing: 10,
                  children: [
                    for(int i=0; i<showPopOverFunctions.length; i++) CircleButton1(
                      onPressed: (btnContext){ showPopOverFunctions[i](btnContext); },
                      child: Icon(
                        popOverFunctionsIcon[i],
                        size: 15,
                        color: Colors.grey[800],
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ResponsiveBuilder(
                builder: (context, sizing) {
                  if (sizing.isMobile) {
                    return _mobileNavigate();
                  } else {
                    return _desktopMainLayout();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileNavigate() {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          for(int i=0; i<_iconsNavigation.length; i++)
            SalomonBottomBarItem(
              icon: Icon(_iconsNavigation[i]),
              title: Text(_titleNavigation[i]),
              selectedColor: Colors.blue,
            )
        ]
      ),
    );
  }

  Widget _desktopMainLayout() {
    return Stack(
      children: [
        Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              extended: _isExpanded,
              minExtendedWidth: 200,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: [
                for(int i=0; i<_iconsNavigation.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_iconsNavigation[i]),
                    label: Text(_titleNavigation[i]),
                  ),
              ],
              selectedIconTheme: IconThemeData(color: Colors.blue),
              selectedLabelTextStyle: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: TextStyle(color: Colors.black),
            ),
            VerticalDivider(width: 1),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
        AnimatedPositioned(
          left: _isExpanded ? 173 : 52,
          top: 0,
          bottom: 0,
          duration: Duration(milliseconds: 200),
          child: Center(
            child: ElevatedButton(
              onPressed: (){
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(15),
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[800],
              ),
              child: Icon(_isExpanded ? FontAwesomeIcons.anglesLeft : FontAwesomeIcons.anglesRight),
            ),
          ),
        )
      ],
    );
  }
}

// Hàm hiển thị popup cho button
void _showPopOverUser(BuildContext btnContext){
  final double w = 250;
  final double h = 55;
  // For Header
  final String txtHeader = "USER";

  // For Item PopUp
  final List<void Function()>onPresseds = [
    (){
      Navigator.of(btnContext).pop();
    },
    (){},
  ];
  final List<IconData>iconDatas = [
    FontAwesomeIcons.arrowRightToBracket,
    FontAwesomeIcons.arrowRightFromBracket
  ];
  final List<String>txts = [
    "Lưu tài khoản",
    "Đăng xuất"
  ];
  final List<Color>colors = [
    Colors.black,
    Colors.red
  ];

  // Gọi hàm
  PopUpLayout(
    w: w,
    h: h,
    btnContext: btnContext, 
    txtHeader: txtHeader, 
    onPressedLength: onPresseds.length,
    widgets: [
      for(int i=0; i<onPresseds.length; i++) SizedBox(
        height: h,
        child: ButtonRectangle1(
          onPressed: onPresseds[i],
          child: Row(
            spacing: 10,
            children: [
              Icon(iconDatas[i], size: 15, color: colors[i]),
              Text(txts[i], style: TextStyle(fontSize: 14, color: colors[i]))
            ],
          )
        )
      )
    ],
  ).showPopUp();
}

void _showPopOverAlert(BuildContext btnContext){
  final double w = 350;
  final double h = 70;
  // For Header
  final String txtHeader = "Thông báo";

  // For Item PopUp
  final List<void Function()>onPresseds = [
    (){},
    (){},
  ];
  final List<bool>stateAlerts = [
    false,
    true
  ];
  final List<String>txts = [
    "Player123 đã gửi yêu cầu kết bạn",
    "Player123 đã gửi một tin nhắn"
  ];
  final List<String>times = [
    "5 phút trước",
    "1 tiếng trước"
  ];

  // Gọi hàm
  PopUpLayout(
    w: w,
    h: h,
    btnContext: btnContext, 
    txtHeader: txtHeader, 
    onPressedLength: onPresseds.length,
    widgets: [
      for(int i=0; i<onPresseds.length; i++) SizedBox(
        height: h,
        child: ButtonRectangle1(
          onPressed: onPresseds[i],
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 10,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 8, 
                        height: 8,
                        margin: EdgeInsets.fromLTRB(0, 17, 0, 0),
                        decoration: BoxDecoration(
                          color: (stateAlerts[i] ? Colors.transparent : Colors.blue), 
                          shape: BoxShape.circle,
                        )
                      ),
                    ],
                  ),
                  Column(
                    spacing: 3,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txts[i], style: TextStyle(fontSize: 14, color: Colors.black)),
                      Text(times[i], style: TextStyle(fontSize: 10, color: Colors.grey))
                    ],
                  )
                ],
              ),

              Container(
                margin: EdgeInsets.fromLTRB(0, 14, 0, 0),
                child: ButtonIconForeGround(
                  iconData: FontAwesomeIcons.x,
                  sizeIcon: 15,
                  textColor: Colors.black,
                  textHoverColor: Colors.red,
                  onPressed: (){
                    print("CLOSE");
                  },
                )
              )
            ],
          )
        )
      )
    ],
  ).showPopUp();
}

void _showPopOverSetting(BuildContext btnContext){
  final double w = 250;
  final double h = 55;
  final double currVolumn = 20;
  final double minVolumn = 0;
  final double maxVolumn = 100;
  // For Header
  final String txtHeader = "Cài đặt";

  // For Item PopUp
  final List<String>txts = [
    "Nhạc",
    "Rung",
    "Nền tối"
  ];
  final List<bool>stateButton = [
    false,
    false,
    false
  ];
  final List<void Function()> onPresseds = [
    (){
      print("TURN SWITCH");
    },
    (){},
    (){},
  ];

  // Gọi hàm
  PopUpLayout(
    w: w,
    h: h,
    btnContext: btnContext, 
    txtHeader: txtHeader, 
    onPressedLength: txts.length + 2,
    widgets: [
      SwitchVolumnMain(h: h, currVolumn: currVolumn, minVolumn: minVolumn, maxVolumn: maxVolumn),
      for(int i=0; i<txts.length; i++) Container(
        height: h,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(txts[i], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
            MySwitch(stateSwitch: stateButton[i], onPressed: onPresseds[i])
          ],
        ),
      )
    ],
  ).showPopUp(); 
}

// ----------------------------------