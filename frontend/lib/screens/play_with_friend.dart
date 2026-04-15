import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/models/line.dart';
import 'package:frontend/core/notifiers/user_notifier.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/layout/frame.dart';
import 'package:frontend/widgets/layout/my_custom_paint.dart';
import 'package:frontend/widgets/layout/my_divider.dart';
import 'package:frontend/widgets/layout/my_error.dart';
import 'package:frontend/widgets/layout/my_loading.dart';
import 'package:frontend/widgets/layout/my_qr.dart';
import 'package:go_router/go_router.dart';

class PlayWithFriend extends ConsumerStatefulWidget {
  final String idRoom;
  const PlayWithFriend({super.key, required this.idRoom});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayWithFriendState();
}

class _PlayWithFriendState extends ConsumerState<PlayWithFriend> {
  late String idRoom;
  late String idUser;
  String startGame = ""; // "" || "QR" || ERROR || PLAY
  int isUserReady = 0; // 0: Chưa sẵn sàng, 1: Đã sẵn sàng, 2: Đã out
  int isYouReady = 0;

  // FOR GAME--------------------------------------------------------------------------------------
  late bool yourX;
  late bool yourTurn;
  late bool isUser0X;
  int stateGame = -1; // -1: Chưa đấu xong, 0 => Thắng, 1 => Thua, 2 => Hòa
  bool isOverLay = false;
  late int yourRationWin, yourRationLoose, yourRationDraw;
  late int opponentRationWin, opponentRationLoose, opponentRationDraw;
  late List<Line> lines;
  final int gridSize = 16;
  final double cellSize = 25;

  Offset? hoverCell;
  Set<Offset> visitedX = {};
  Set<Offset> visitedO = {};
  // -----------------------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    idRoom = widget.idRoom;
    // Lắng nghe khi userNotifier thay đổi
    ref.listenManual(userNotifier, (previous, next) {
      if (next.hasValue) {
        _initOnceSocket(next.value);
      }
    });

    // Khi widget được khởi tạo
    final current = ref.read(userNotifier);
    if (current.hasValue) {
      _initOnceSocket(current.value);
    }
  }

  void _initOnceSocket(Map<String, dynamic>? valueUserGlobal) {
    idUser = valueUserGlobal!['user']['id'];
    SocketService.socket.off('response-start-game');
    SocketService.socket.on('response-start-game', (data) {
      if (!mounted) return;
      // data: { state: String = "" || "QR" || ERROR || PLAY || WAITING "Xu ly cho doi thu" || ENDGAME }
      setState(() {
        startGame = data['state'];

        if (data['state'] == "PLAY" || data['state'] == "LOAD") {
          // data: { yourTurn: true || false; yourX: true || false; board: number[][] }
          // yourTurn,
          // yourX,
          // board: request.match?.boards,
          // stateGame:
          yourTurn = data['yourTurn'];
          yourX = data['yourX'];
          isUser0X = data['isUser0X'];
          stateGame = data['stateGame'];
          isUserReady = data['isUserReady'];
          isYouReady = data['isYouReady'];
          yourRationWin = data['yourRation']['win'];
          yourRationLoose = data['yourRation']['loose'];
          yourRationDraw = data['yourRation']['draw'];
          opponentRationWin = data['opponentRation']['win'];
          opponentRationLoose = data['opponentRation']['loose'];
          opponentRationDraw = data['opponentRation']['draw'];
          lines = (data['lines'] as List<dynamic>)
              .map(
                (item) => Line(
                  typeLine: item['typeLine'],
                  top: Point(x: item['top']['x'], y: item['top']['y']),
                  bottom: Point(x: item['bottom']['x'], y: item['bottom']['y']),
                ),
              )
              .toList();

          if (isOverLay) {
            isOverLay = false;
            Navigator.pop(context);
          }

          List<List<int>> boards = (data['board'] as List)
              .map((row) => List<int>.from(row))
              .toList();

          Set<Offset> newVisitedX = {};
          Set<Offset> newVisitedO = {};

          for (int i = 0; i < boards.length; i++) {
            for (int j = 0; j < boards[i].length; j++) {
              if (boards[i][j] == 0) {
                if (isUser0X) {
                  newVisitedX.add(Offset(i.toDouble(), j.toDouble()));
                } else {
                  newVisitedO.add(Offset(i.toDouble(), j.toDouble()));
                }
              } else if (boards[i][j] == 1) {
                if (!isUser0X) {
                  newVisitedX.add(Offset(i.toDouble(), j.toDouble()));
                } else {
                  newVisitedO.add(Offset(i.toDouble(), j.toDouble()));
                }
              }
            }
          }

          visitedX = newVisitedX;
          visitedO = newVisitedO;
        }
      });
    });

    SocketService.socket.off('response-on-move');
    SocketService.socket.on('response-on-move', (data) {
      if (!mounted) return;
      setState(() {
        if (data['state'] == "ENDGAME") {
          yourTurn = false;
          yourRationWin = data['yourRation']['win'];
          yourRationLoose = data['yourRation']['loose'];
          yourRationDraw = data['yourRation']['draw'];
          opponentRationWin = data['opponentRation']['win'];
          opponentRationLoose = data['opponentRation']['loose'];
          opponentRationDraw = data['opponentRation']['draw'];
          stateGame = data['result'];
          // Update lines win
          lines = (data['lines'] as List<dynamic>)
              .map(
                (item) => Line(
                  typeLine: item['typeLine'],
                  top: Point(x: item['top']['x'], y: item['top']['y']),
                  bottom: Point(x: item['bottom']['x'], y: item['bottom']['y']),
                ),
              )
              .toList();

          if (stateGame != 0) {
            if (!yourX) {
              visitedX = {
                ...visitedX,
                Offset(
                  data['lastTurn']['x'].toDouble(),
                  data['lastTurn']['y'].toDouble(),
                ),
              };
            } else {
              visitedO = {
                ...visitedO,
                Offset(
                  data['lastTurn']['x'].toDouble(),
                  data['lastTurn']['y'].toDouble(),
                ),
              };
            }
          }
          return;
        }
        yourTurn = true;
        if (!yourX) {
          visitedX = {
            ...visitedX,
            Offset(data['x'].toDouble(), data['y'].toDouble()),
          };
        } else {
          visitedO = {
            ...visitedO,
            Offset(data['x'].toDouble(), data['y'].toDouble()),
          };
        }
      });
    });

    SocketService.socket.off('response-out-room');
    SocketService.socket.on('response-out-room', (data) {
      context.go('/');
    });

    SocketService.socket.off('response-playagain');
    SocketService.socket.on('response-playagain', (data) {
      setState(() {
        if (isOverLay) {
          Navigator.pop(context);
          isOverLay = false;
        }
        isUserReady = 1;
      });
    });

    SocketService.socket.emit('request-start-game', {
      'idRoom': idRoom,
      'idUser': idUser,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (startGame.isEmpty) return MyLoading(text: "");
    if (startGame == "ERROR") return MyErrorPageURL();
    if (startGame == "QR") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Text(
                "Quét mã QR hoặc truy cập vào trang",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SelectableText(
                GoRouterState.of(context).uri.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              MyQR(url: GoRouterState.of(context).uri.toString()),
              ElevatedButton(
                onPressed: () {
                  SocketService.socket.emit('request-out-room', {
                    'idRoom': idRoom,
                    'idUser': idUser,
                  });
                  context.go('/');
                },
                child: Text('Thoát'),
              ),
            ],
          ),
        ),
      );
    }
    // Nếu trận đấu đã kết thúc
    if (stateGame != -1 && !isOverLay) {
      stateEndGame();
      setState(() {
        isOverLay = true;
      });
    }

    return ref
        .watch(userNotifier)
        .when(
          data: (data) => Column(
            children: [
              Frame(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      // spacing: 2,
                      children: [
                        yourX
                            ? MyCustomPaintX(size: 25)
                            : MyCustomPaintO(size: 25),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          spacing: 0,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "User1",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "12 giây",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        CircleCountDown(size: 40, seconds: 5),
                        Text(
                          yourRationWin.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          ":",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          opponentRationWin.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                        CircleCountDown(size: 40, seconds: 5),
                        Column(
                          spacing: 0,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "User1",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "12 giây",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        !yourX
                            ? MyCustomPaintX(size: 25)
                            : MyCustomPaintO(size: 25),
                      ],
                    ),
                  ],
                ),
              ),
              MyDivider(),
              Expanded(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.minWidth,
                              minHeight: constraints.minHeight,
                            ),
                            child: Center(
                              child: MouseRegion(
                                onHover: (event) {
                                  if (!yourTurn) {
                                    hoverCell = null;
                                    return;
                                  }
                                  final locationPostion = event.localPosition;
                                  int row = (locationPostion.dy / cellSize)
                                      .floor();
                                  int col = (locationPostion.dx / cellSize)
                                      .floor();
                                  if (0 <= row &&
                                      row < gridSize &&
                                      0 <= col &&
                                      col < gridSize &&
                                      !visitedX.contains(
                                        Offset(row.toDouble(), col.toDouble()),
                                      ) &&
                                      !visitedO.contains(
                                        Offset(row.toDouble(), col.toDouble()),
                                      )) {
                                    setState(() {
                                      hoverCell = Offset(
                                        row.toDouble(),
                                        col.toDouble(),
                                      );
                                    });
                                  } else {
                                    setState(() {
                                      hoverCell = null;
                                    });
                                  }
                                },
                                child: GestureDetector(
                                  onTapUp: _handelOnTapUp,
                                  child: CustomPaint(
                                    size: Size(
                                      gridSize * cellSize,
                                      gridSize * cellSize,
                                    ),
                                    painter:
                                        MyCustomPaintGameBoardCustomPainter(
                                          gridSize,
                                          cellSize,
                                          visitedX,
                                          visitedO,
                                          hoverCell,
                                          yourX,
                                          lines,
                                          stateGame,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              MyDivider(),
              Frame(
                child: Row(
                  children: [
                    ButtonRectangle2(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Bạn có chắc muốn thoát?"),
                              content: Text(
                                "Việc hủy bỏ ván đấu mặc định đối thủ sẽ thắng.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => {
                                    SocketService.socket.emit(
                                      'request-out-room',
                                      {'idRoom': idRoom, 'idUser': idUser},
                                    ),
                                    context.go('/'),
                                  },
                                  child: const Text('Hủy bỏ ván đấu'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            "Bỏ cuộc",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Icon(
                            FontAwesomeIcons.flag,
                            size: 16,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        );
  }

  void _handelOnTapUp(TapUpDetails details) {
    if (!yourTurn) return;
    final locationPostion = details.localPosition;
    int row = (locationPostion.dy / cellSize).floor();
    int col = (locationPostion.dx / cellSize).floor();
    if (0 <= row &&
        row < gridSize &&
        0 <= col &&
        col < gridSize &&
        !visitedX.contains(Offset(row.toDouble(), col.toDouble())) &&
        !visitedO.contains(Offset(row.toDouble(), col.toDouble()))) {
      setState(() {
        if (yourX) {
          visitedX = {...visitedX, Offset(row.toDouble(), col.toDouble())};
        } else {
          visitedO = {...visitedO, Offset(row.toDouble(), col.toDouble())};
        }
        yourTurn = false;
        hoverCell = null;
        SocketService.socket.emit('request-on-move', {
          'idRoom': idRoom,
          'idUser': idUser,
          'x': row,
          'y': col,
        });
      });
    }
  }

  void stateEndGame() {
    // Đã kết thúc trận đấu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String str = "";
      switch (stateGame) {
        case 0:
          str = "Bạn đã thắng";
          break;
        case 1:
          str = "Bạn đã thua";
          break;
        case 2:
          str = "Bạn đã hòa";
          break;
      }
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return isYouReady == 1
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          "Đang chờ đối thủ...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            SocketService.socket.emit('request-out-room', {
                              'idRoom': idRoom,
                              'idUser': idUser,
                            });
                            context.go('/');
                          },
                          child: Text('Rời khỏi phòng'),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        str,
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),

                      isUserReady == 0
                          ? Text(
                              "Đối thủ chưa sẵn sàng",
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            )
                          : isUserReady == 1
                          ? Text(
                              "Đối thủ đã sẵn sàng",
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            )
                          : Text(
                              "Đối thủ đã thoát",
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            ),

                      ButtonNormal(
                        text: "Chơi lại",
                        onPressed: () {
                          SocketService.socket.emit('request-playagain', {
                            'idRoom': idRoom,
                            'idUser': idUser,
                          });
                          if (isUserReady == 0) {
                            setState(() {
                              isYouReady = 1;
                            });
                            isOverLay = false;
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              startGame = "";
                              isOverLay = false;
                              Navigator.pop(context);
                            });
                          }
                        },
                      ),
                      ButtonNormal(
                        text: "Rời khỏi phòng",
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/');
                          SocketService.socket.emit('request-out-room', {
                            'idRoom': idRoom,
                            'idUser': idUser,
                          });
                        },
                      ),
                    ],
                  ),
                );
        },
      );
    });
  }
}
