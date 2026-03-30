import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/notifiers/user_notifier.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/layout/frame.dart';
import 'package:frontend/widgets/layout/my_divider.dart';
import 'package:frontend/widgets/layout/pop_up_layout.dart';
import 'package:frontend/widgets/router.dart';
import 'package:frontend/widgets/switch/switch.dart';
import 'package:frontend/widgets/switch/switch_volumn_main.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class Mainlayout extends ConsumerStatefulWidget {
  final Widget child;
  const Mainlayout({super.key, required this.child});

  @override
  ConsumerState<Mainlayout> createState() => _MainLayout();
}

class _MainLayout extends ConsumerState<Mainlayout> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
  }

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
    "Tài khoản",
  ];

  // Danh sách các hàm cho chức năng ở header
  final List<void Function(BuildContext)> showPopOverFunctions = [
    _showPopOverUser,
    _showPopOverAlert,
    _showPopOverSetting,
  ];

  // Danh sách icon cho chức năng ở header
  final List<IconData> popOverFunctionsIcon = [
    FontAwesomeIcons.user,
    FontAwesomeIcons.bell,
    FontAwesomeIcons.gear,
  ];

  // Danh đường dẫn
  final List<String> paths = ['/', '/chat', '/friends', '/history', '/account'];

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(userNotifier)
        .when(
          data: (data) {
            return Column(
              children: [
                Frame(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          context.go('/');
                        },
                        child: Row(
                          spacing: 10,
                          children: [
                            Image(
                              image: AssetImage(
                                'assets/images/tic-tac-toe.png',
                              ),
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
                          for (int i = 0; i < showPopOverFunctions.length; i++)
                            CircleButton1(
                              onPressed: (btnContext) {
                                showPopOverFunctions[i](btnContext);
                              },
                              child: Icon(
                                popOverFunctionsIcon[i],
                                size: 15,
                                color: Colors.grey[800],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                MyDivider(),
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
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("ERROR")),
        );
  }

  Widget _mobileNavigate() {
    final selectedIndex = findIndexByPath(context);
    final child = widget.child;

    return Scaffold(
      body: child,
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          context.go(paths[index]);
        },
        items: [
          for (int i = 0; i < _iconsNavigation.length; i++)
            SalomonBottomBarItem(
              icon: Icon(_iconsNavigation[i]),
              title: Text(_titleNavigation[i]),
              selectedColor: Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _desktopMainLayout() {
    final selectedIndex = findIndexByPath(context);
    final child = widget.child;

    return Stack(
      children: [
        Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              extended: _isExpanded,
              minExtendedWidth: 200,
              onDestinationSelected: (index) {
                context.go(paths[index]);
              },
              destinations: [
                for (int i = 0; i < _iconsNavigation.length; i++)
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
            Expanded(child: child),
          ],
        ),
        AnimatedPositioned(
          left: _isExpanded ? 173 : 52,
          top: 0,
          bottom: 0,
          duration: Duration(milliseconds: 200),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
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
              child: Icon(
                _isExpanded
                    ? FontAwesomeIcons.anglesLeft
                    : FontAwesomeIcons.anglesRight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Hàm hiển thị popup cho button
void _showPopOverUser(BuildContext btnContext) {
  final double w = 250;
  final double h = 55;
  // For Header
  final String txtHeader = "USER";

  // For Item PopUp
  final List<void Function()> onPresseds = [
    () {
      Navigator.of(btnContext).pop();
    },
    () {
      btnContext.go("/login");
    },
    () async {
      (!kIsWeb)
          ? {
              await FlutterSecureStorage().delete(key: 'uid'),
              btnContext.go('/'),
            }
          : {
              await FlutterSecureStorage().delete(key: 'uid'),
              GoogleSignIn.instance.disconnect(),
              btnContext.go('/'),
            };
    },
  ];
  final List<IconData> iconDatas = [
    FontAwesomeIcons.arrowRightToBracket,
    FontAwesomeIcons.arrowRightToBracket,
    FontAwesomeIcons.arrowRightFromBracket,
  ];
  final List<String> txts = ["Lưu tài khoản", "Đăng nhập", "Đăng xuất"];
  final List<Color> colors = [Colors.black, Colors.black, Colors.red];

  // Gọi hàm
  PopUpLayout(
    w: w,
    h: h,
    btnContext: btnContext,
    txtHeader: txtHeader,
    onPressedLength: onPresseds.length,
    widgets: [
      for (int i = 0; i < onPresseds.length; i++)
        SizedBox(
          height: h,
          child: ButtonRectangle1(
            onPressed: onPresseds[i],
            child: Row(
              spacing: 10,
              children: [
                Icon(iconDatas[i], size: 15, color: colors[i]),
                Text(txts[i], style: TextStyle(fontSize: 14, color: colors[i])),
              ],
            ),
          ),
        ),
    ],
  ).showPopUp();
}

void _showPopOverAlert(BuildContext btnContext) {
  final double w = 350;
  final double h = 70;
  // For Header
  final String txtHeader = "Thông báo";

  // For Item PopUp
  final List<void Function()> onPresseds = [() {}, () {}];
  final List<bool> stateAlerts = [false, true];
  final List<String> txts = [
    "Player123 đã gửi yêu cầu kết bạn",
    "Player123 đã gửi một tin nhắn",
  ];
  final List<String> times = ["5 phút trước", "1 tiếng trước"];

  // Gọi hàm
  PopUpLayout(
    w: w,
    h: h,
    btnContext: btnContext,
    txtHeader: txtHeader,
    onPressedLength: onPresseds.length,
    widgets: [
      for (int i = 0; i < onPresseds.length; i++)
        SizedBox(
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
                            color: (stateAlerts[i]
                                ? Colors.transparent
                                : Colors.blue),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      spacing: 3,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          txts[i],
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          times[i],
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                Container(
                  margin: EdgeInsets.fromLTRB(0, 14, 0, 0),
                  child: ButtonIconForeGround(
                    iconData: FontAwesomeIcons.x,
                    sizeIcon: 15,
                    textColor: Colors.black,
                    textHoverColor: Colors.red,
                    onPressed: () {
                      print("CLOSE");
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  ).showPopUp();
}

void _showPopOverSetting(BuildContext btnContext) {
  final double w = 250;
  final double h = 55;
  final double currVolumn = 20;
  final double minVolumn = 0;
  final double maxVolumn = 100;
  // For Header
  final String txtHeader = "Cài đặt";

  // For Item PopUp
  final List<String> txts = ["Nhạc", "Rung", "Nền tối"];
  final List<bool> stateButton = [false, false, false];
  final List<void Function()> onPresseds = [
    () {
      print("TURN SWITCH");
    },
    () {},
    () {},
  ];

  // Gọi hàm
  PopUpLayout(
    w: w,
    h: h,
    btnContext: btnContext,
    txtHeader: txtHeader,
    onPressedLength: txts.length + 2,
    widgets: [
      SwitchVolumnMain(
        h: h,
        currVolumn: currVolumn,
        minVolumn: minVolumn,
        maxVolumn: maxVolumn,
      ),
      for (int i = 0; i < txts.length; i++)
        Container(
          height: h,
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                txts[i],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              MySwitch(stateSwitch: stateButton[i], onPressed: onPresseds[i]),
            ],
          ),
        ),
    ],
  ).showPopUp();
}

// ----------------------------------
