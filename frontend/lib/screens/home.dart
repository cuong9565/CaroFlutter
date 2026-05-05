import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/notifiers/user_notifier.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/charts/circle_chart.dart';
import 'package:frontend/widgets/charts/linear_chart.dart';
import 'package:frontend/widgets/layout/my_loading.dart';
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
                        children: [GameMode()],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Column(
                        spacing: 10,
                        children: [_GameRules()],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return (Column(
                spacing: 20,
                children: [
                  GameMode(),
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

// ----------------------------------------
// Game mode UI
// ----------------------------------------
class GameMode extends ConsumerStatefulWidget {
  const GameMode({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameMode();
}

class _GameMode extends ConsumerState<GameMode> {
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
  late final List<void Function(BuildContext)> _functionButton = [
    (BuildContext context) {
      // Lắng nghe khi userNotifier thay đổi
      ref.listenManual(userNotifier, (previous, next) {
        final userId = _getUserId(next.value);
        if (userId == null) return;
        _ensureSocketReady(userId);
        SocketService.emit('request-create-room', {'idUser': userId});
      });

      // Khi widget được khởi tạo
      final current = ref.read(userNotifier);
      final userId = _getUserId(current.value);
      if (userId != null) {
        _ensureSocketReady(userId);
        SocketService.emit('request-create-room', {'idUser': userId});
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white,
        builder: (context) {
          return MyLoading(text: "");
        },
      );
    },
    (BuildContext context) {
      // Lắng nghe khi userNotifier thay đổi
      ref.listenManual(userNotifier, (previous, next) {
        final userId = _getUserId(next.value);
        if (userId == null) return;
        _ensureSocketReady(userId);
        SocketService.emit('request-create-room', {
          'idUser': userId,
          'gameMode': 'AI',
        });
      });

      // Khi widget được khởi tạo
      final current = ref.read(userNotifier);
      final userId = _getUserId(current.value);
      if (userId != null) {
        _ensureSocketReady(userId);
        SocketService.emit('request-create-room', {
          'idUser': userId,
          'gameMode': 'AI',
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white,
        builder: (context) {
          return MyLoading(text: "");
        },
      );
    },
    (BuildContext context) {
      // Lắng nghe khi userNotifier thay đổi
      ref.listenManual(userNotifier, (previous, next) {
        final userId = _getUserId(next.value);
        if (userId == null) return;
        _ensureSocketReady(userId);
        SocketService.emit('request-play-game-online', {
          'idUser': userId,
        });
      });

      // Khi widget được khởi tạo
      final current = ref.read(userNotifier);
      final userId = _getUserId(current.value);
      if (userId != null) {
        _ensureSocketReady(userId);
        SocketService.emit('request-play-game-online', {
          'idUser': userId,
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white,
        builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 25,
              children: [
                Text(
                  "Đang tìm một người chơi...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey.shade600,
                  ),
                ),

                CircularProgressIndicator(),
                ButtonNormal(
                  text: "Thoát",
                  onPressed: () => {
                    SocketService.emit('out-room'),
                    Navigator.pop(context),
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  ];
  // Danh sách chức năng cho nút trợ giúp
  List<void Function(BuildContext)> get _functionHelper => [
    (BuildContext btnContext) {
      final List<String> txts = [
        "Chơi cùng một người bạn",
        "+ Thông qua đường link (hoặc mã QR)",
      ];
      _funtionHelperLayout(btnContext, 110, "Chơi với một người bạn", txts);
    },
    (BuildContext btnContext) {
      final List<String> txts = [
        "Chơi với máy",
        "+ Chơi cùng với một ai đơn giản",
      ];
      _funtionHelperLayout(btnContext, 110, "Chơi với máy", txts);
    },
    (BuildContext btnContext) {
      final List<String> txts = [
        "Chơi cùng một người ngẫu nhiên trong danh sách chờ",
      ];
      _funtionHelperLayout(btnContext, 80, "Chơi trực tuyến", txts);
    },
  ];

  @override
  void initState() {
    super.initState();
    // Lắng nghe khi userNotifier thay đổi
    ref.listenManual(userNotifier, (previous, next) {
      final userId = _getUserId(next.value);
      if (userId != null) {
        _initOnceSocket(userId);
      }
    });

    // Khi widget được khởi tạo
    final current = ref.read(userNotifier);
    final userId = _getUserId(current.value);
    if (userId != null) {
      _initOnceSocket(userId);
    }
  }

  String? _getUserId(Map<String, dynamic>? userData) {
    final user = userData?['user'];
    final id = (user is Map) ? user['id'] : null;
    final userId = id?.toString();
    if (userId == null || userId.isEmpty) return null;
    return userId;
  }

  void _ensureSocketReady(String userId) {
    if (!SocketService.isInitialized) {
      SocketService.init(userId);
    }
  }

  void _initOnceSocket(String userId) {
    _ensureSocketReady(userId);
    SocketService.off('response-create-room');
    SocketService.once('response-create-room', (data) {
      if (!mounted) return;
      final String idRoom = data['idRoom'];
      final String gameMode = data['gameMode'] ?? 'FRIEND';

      if (gameMode == 'AI') {
        context.go('/play-ai/$idRoom');
      } else if (gameMode == 'FRIEND') {
        context.go('/play/$idRoom');
      } else {
        context.go('/game-online/$idRoom');
      }
    });
  }

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
