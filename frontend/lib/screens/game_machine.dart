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

class GameMachine extends ConsumerStatefulWidget {
  const GameMachine({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameMachineState();
}

class _GameMachineState extends ConsumerState<GameMachine> {
  String? idRoom;
  String? idUser;

  bool yourX = true;
  bool yourTurn = true;
  int stateGame = -1; // -1: Chua ket thuc, 0: Thang, 1: Thua, 2: Hoa
  bool isOverLay = false;

  final int gridSize = 16;
  final double cellSize = 25;

  Offset? hoverCell;
  Set<Offset> visitedX = {};
  Set<Offset> visitedO = {};

  @override
  void initState() {
    super.initState();
    ref.listenManual(userNotifier, (previous, next) {
      if (next.hasValue) {
        _initSocket(next.value);
      }
    });

    final current = ref.read(userNotifier);
    if (current.hasValue) {
      _initSocket(current.value);
    }
  }

  @override
  void dispose() {
    if (idRoom != null && idUser != null) {
      SocketService.emit('request-out-room', {
        'idRoom': idRoom,
        'idUser': idUser,
      });
    }
    SocketService.off('response-start-game-with-bot');
    SocketService.off('response-on-move-with-bot');
    super.dispose();
  }

  void _initSocket(Map<String, dynamic>? userData) {
    final userId = userData?['user']?['id'];
    if (userId == null) return;

    idUser = userId;
    SocketService.init(userId);

    SocketService.off('response-start-game-with-bot');
    SocketService.on('response-start-game-with-bot', (data) {
      if (!mounted || data['state'] != 'PLAY') return;

      final List<List<int>> boards = (data['board'] as List)
          .map((row) => List<int>.from(row))
          .toList();

      Set<Offset> newVisitedX = {};
      Set<Offset> newVisitedO = {};

      for (int i = 0; i < boards.length; i++) {
        for (int j = 0; j < boards[i].length; j++) {
          if (boards[i][j] == 0) {
            newVisitedX.add(Offset(i.toDouble(), j.toDouble()));
          } else if (boards[i][j] == 1) {
            newVisitedO.add(Offset(i.toDouble(), j.toDouble()));
          }
        }
      }

      setState(() {
        idRoom = data['idRoom'];
        yourTurn = data['yourTurn'] ?? true;
        yourX = data['yourX'] ?? true;
        stateGame = -1;
        visitedX = newVisitedX;
        visitedO = newVisitedO;
        hoverCell = null;
      });
    });

    SocketService.off('response-on-move-with-bot');
    SocketService.on('response-on-move-with-bot', (data) {
      if (!mounted) return;
      if (data['state'] == 'ERROR') {
        setState(() {
          yourTurn = true;
        });
        return;
      }

      if (data['state'] == 'ENDGAME') {
        setState(() {
          stateGame = data['result'] ?? 2;
          yourTurn = false;

          if (data['lastTurn'] != null && stateGame == 1) {
            final botMove = Offset(
              data['lastTurn']['x'].toDouble(),
              data['lastTurn']['y'].toDouble(),
            );
            if (yourX) {
              visitedO = {...visitedO, botMove};
            } else {
              visitedX = {...visitedX, botMove};
            }
          }
        });
        return;
      }

      setState(() {
        final botMove = Offset(data['x'].toDouble(), data['y'].toDouble());
        if (yourX) {
          visitedO = {...visitedO, botMove};
        } else {
          visitedX = {...visitedX, botMove};
        }
        yourTurn = true;
      });
    });

    SocketService.emit('request-play-with-bot', {
      'idUser': userId,
    });
  }

  void _handleOnTapUp(TapUpDetails details) {
    if (!yourTurn || idRoom == null || idUser == null || stateGame != -1) return;

    final locationPosition = details.localPosition;
    int row = (locationPosition.dy / cellSize).floor();
    int col = (locationPosition.dx / cellSize).floor();

    if (0 <= row &&
        row < gridSize &&
        0 <= col &&
        col < gridSize &&
        !visitedX.contains(Offset(row.toDouble(), col.toDouble())) &&
        !visitedO.contains(Offset(row.toDouble(), col.toDouble()))) {
      setState(() {
        final move = Offset(row.toDouble(), col.toDouble());
        if (yourX) {
          visitedX = {...visitedX, move};
        } else {
          visitedO = {...visitedO, move};
        }
        yourTurn = false;
        hoverCell = null;
      });

      SocketService.emit('request-on-move-with-bot', {
        'idRoom': idRoom,
        'idUser': idUser,
        'x': row,
        'y': col,
      });
    }
  }

  void _playAgain() {
    if (idRoom != null && idUser != null) {
      SocketService.emit('request-out-room', {
        'idRoom': idRoom,
        'idUser': idUser,
      });
    }

    setState(() {
      idRoom = null;
      stateGame = -1;
      isOverLay = false;
      visitedX = {};
      visitedO = {};
      hoverCell = null;
      yourTurn = true;
      yourX = true;
    });

    if (idUser != null) {
      SocketService.emit('request-play-with-bot', {
        'idUser': idUser,
      });
    }
  }

  void _showEndGameDialog() {
    isOverLay = true;
    String txt = 'Ban da hoa';
    if (stateGame == 0) {
      txt = 'Ban da thang';
    } else if (stateGame == 1) {
      txt = 'Ban da thua';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(txt),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _playAgain();
              },
              child: const Text('Choi lai'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/');
              },
              child: const Text('Trang chu'),
            ),
          ],
        );
      },
    ).then((_) {
      isOverLay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (idRoom == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Text(
              'Dang tao van dau voi may...',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
            ),
            const CircularProgressIndicator(),
            ButtonNormal(
              text: 'Thoat',
              onPressed: () {
                context.go('/');
              },
            ),
          ],
        ),
      );
    }

    if (stateGame != -1 && !isOverLay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || isOverLay) return;
        _showEndGameDialog();
      });
    }

    return Column(
      children: [
        Frame(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  yourX ? MyCustomPaintX(size: 25) : MyCustomPaintO(size: 25),
                ],
              ),
              Text(
                yourTurn ? 'Luot cua ban' : 'May dang di...',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  yourX ? MyCustomPaintO(size: 25) : MyCustomPaintX(size: 25),
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
                              setState(() {
                                hoverCell = null;
                              });
                              return;
                            }

                            final location = event.localPosition;
                            int row = (location.dy / cellSize).floor();
                            int col = (location.dx / cellSize).floor();

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
                                hoverCell = Offset(row.toDouble(), col.toDouble());
                              });
                            } else {
                              setState(() {
                                hoverCell = null;
                              });
                            }
                          },
                          child: GestureDetector(
                            onTapUp: _handleOnTapUp,
                            child: CustomPaint(
                              size: Size(gridSize * cellSize, gridSize * cellSize),
                              painter: MyCustomPaintGameBoardCustomPainter(
                                gridSize,
                                cellSize,
                                visitedX,
                                visitedO,
                                hoverCell,
                                yourX,
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
                  context.go('/');
                },
                child: Row(
                  spacing: 5,
                  children: [
                    const Text('Thoát', style: TextStyle(fontSize: 16, color: Colors.black)),
                    const Icon(FontAwesomeIcons.flag, size: 16, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
