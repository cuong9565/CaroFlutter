import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/notifiers/user_notifier.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/widgets/buttons/button.dart';
import 'package:frontend/widgets/layout/frame.dart';
import 'package:frontend/widgets/layout/my_custom_paint.dart';
import 'package:frontend/widgets/layout/my_divider.dart';
import 'package:go_router/go_router.dart';

class GameOnline extends ConsumerStatefulWidget {
  const GameOnline({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameOnlineState();
}

class _GameOnlineState extends ConsumerState<GameOnline> {
  late bool currMoveIsX;
  late bool isYourTurn;
  bool status = false;
  final int gridSize = 16;
  final double cellSize = 25;

  Offset? hoverCell;
  Set<Offset> visitedX = {};
  Set<Offset> visitedO = {};

  String? idRoom;
  late Function(dynamic) joinRoomListener, onYourMove;

  @override
  void initState() {
    super.initState();
    ref.listenManual(userNotifier, (previous, next) {
      if (next.hasValue) {
        _connectSocket(next.value);
      }
    });

    final current = ref.read(userNotifier);
    if (current.hasValue) {
      _connectSocket(current.value);
    }
  }

  @override
  void dispose() {
    SocketService.socket.emit('out-room');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (idRoom == null) {
      // Chưa tìm được người chơi
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
                SocketService.socket.emit('out-room'),
                context.go("/"),
              },
            ),
          ],
        ),
      );
    }
    if (status == true) {
      // Đã kết thúc trận đấu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Bạn có chắc muốn thoát?"),
              content: Text("Việc hủy bỏ ván đấu mặc định đối thủ sẽ thắng."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/');
                  },
                  child: const Text('Hủy bỏ ván đấu'),
                ),
              ],
            );
          },
        );
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
                        currMoveIsX
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
                          "0",
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
                          "0",
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
                        !currMoveIsX
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
                                  if (!isYourTurn) {
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
                                          currMoveIsX,
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
                                  onPressed: () => context.go('/'),
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

  void _connectSocket(dynamic data) {
    joinRoomListener = (data) {
      if (!mounted) return;
      setState(() {
        idRoom = data['idRoom'];
        isYourTurn = data['isYourTurn'];
        currMoveIsX = data['isYourTurn'];
      });
    };
    onYourMove = (data) {
      if (!mounted) return;
      if (data['status'] == true) {
        setState(() {
          status = true;
        });
        return;
      }

      setState(() {
        isYourTurn = true;
        if (!currMoveIsX) {
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
    };
    final id = ref.read(userNotifier).value;
    SocketService.socket.on('join-room', joinRoomListener);
    SocketService.socket.on('your-turn-move', onYourMove);
    SocketService.socket.emit('request-play-game-online', {
      'idUser': id!['user']['id'],
    });
  }

  void _handelOnTapUp(TapUpDetails details) {
    if (!isYourTurn) return;
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
        if (currMoveIsX) {
          visitedX = {...visitedX, Offset(row.toDouble(), col.toDouble())};
        } else {
          visitedO = {...visitedO, Offset(row.toDouble(), col.toDouble())};
        }
        isYourTurn = false;
        hoverCell = null;
        SocketService.socket.emit('on-move', {
          'roomId': idRoom,
          'x': row,
          'y': col,
        });
      });
    }
  }
}
