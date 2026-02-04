import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/screens/account.dart';
import 'package:frontend/screens/chat.dart';
import 'package:frontend/screens/friends.dart';
import 'package:frontend/screens/history.dart';
import 'package:frontend/screens/home.dart';
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

  final _items = [
    SalomonBottomBarItem(
      icon: Icon(FontAwesomeIcons.house),
      title: Text("Trang chủ"),
      selectedColor: Colors.blue,
    ),
    SalomonBottomBarItem(
      icon: Icon(FontAwesomeIcons.message),
      title: Text("Nhắn tin"),
      selectedColor: Colors.blue,
    ),
    SalomonBottomBarItem(
      icon: Icon(FontAwesomeIcons.userGroup),
      title: Text("Bạn bè"),
      selectedColor: Colors.blue,
    ),
    SalomonBottomBarItem(
      icon: Icon(FontAwesomeIcons.clockRotateLeft),
      title: Text("Lịch sử đấu"),
      selectedColor: Colors.blue,
    ),
    SalomonBottomBarItem(
      icon: Icon(FontAwesomeIcons.userGear),
      title: Text("Tài khoản"),
      selectedColor: Colors.blue,
    ),
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
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.all(15),
                        minimumSize: Size.zero,
                      ),
                      child: Icon(
                        FontAwesomeIcons.user, 
                        size: 15,
                        color: Colors.grey[800],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.all(15),
                        minimumSize: Size.zero,
                      ),
                      child: Icon(
                        FontAwesomeIcons.bell, 
                        size: 17,                        
                        color: Colors.grey[800],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.all(15),
                        minimumSize: Size.zero,
                      ),
                      child: Icon(
                        FontAwesomeIcons.gear, 
                        size: 17,
                        color: Colors.grey[800],
                      )
                    )
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
        items: _items,
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
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.house),
                  label: Text("Trang chủ"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.message),
                  label: Text("Nhắn tin"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.userGroup),
                  label: Text("Bạn bè"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.clockRotateLeft),
                  label: Text("Lịch sử đấu"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.userGear),
                  label: Text("Tài khoản"),
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
