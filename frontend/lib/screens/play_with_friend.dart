import 'dart:async';

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
import 'package:frontend/widgets/layout/player_avatar.dart';
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
  String opponentName = 'Đối thủ';
  String? opponentAvatarUrl;
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
  int gridSize = 16;
  final double cellSize = 25;
  int turnDurationMs = 10000;
  int remainingTurnSeconds = 0;
  int? _turnDeadlineMs;
  Timer? _turnCountdownTimer;

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
    final user = valueUserGlobal?['user'];
    final userId = (user is Map) ? user['id']?.toString() : null;
    if (userId == null || userId.isEmpty) return;

    idUser = userId;
    SocketService.init(idUser);
    final socket = SocketService.socket;
    if (socket == null) return;

    socket.off('response-start-game');
    socket.on('response-start-game', (data) {
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
          turnDurationMs = (data['turnDurationMs'] as num?)?.toInt() ?? 10000;
          final payloadBoardSize =
              (data['boardSize'] as num?)?.toInt() ??
              ((data['board'] as List?)?.length ?? gridSize);
          if (payloadBoardSize > 0) {
            gridSize = payloadBoardSize;
          }
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

          opponentName = data['opponent']?['username']?.toString() ?? 'Đối thủ';
          opponentAvatarUrl = data['opponent']?['avatarUrl']?.toString();

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
          _setTurnDeadline((data['turnDeadlineMs'] as num?)?.toInt());
        }
      });
    });

    socket.off('response-on-move');
    socket.on('response-on-move', (data) {
      if (!mounted) return;
      setState(() {
        if (data['state'] == "ENDGAME") {
          _stopTurnCountdown();
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
        } else if (data['state'] == "TIMEOUT") {
          _stopTurnCountdown();
          yourTurn = false;
          yourRationWin = data['yourRation']['win'];
          yourRationLoose = data['yourRation']['loose'];
          yourRationDraw = data['yourRation']['draw'];
          opponentRationWin = data['opponentRation']['win'];
          opponentRationLoose = data['opponentRation']['loose'];
          opponentRationDraw = data['opponentRation']['draw'];
          stateGame = data['result'];
          return;
        }
        yourTurn = true;
        turnDurationMs =
            (data['turnDurationMs'] as num?)?.toInt() ?? turnDurationMs;
        _setTurnDeadline((data['turnDeadlineMs'] as num?)?.toInt());
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

    socket.off('response-out-room');
    socket.on('response-out-room', (data) {
      context.go('/');
    });

    socket.off('response-playagain');
    socket.on('response-playagain', (data) {
      setState(() {
        if (isOverLay) {
          Navigator.pop(context);
          isOverLay = false;
        }
        isUserReady = 1;
      });
    });

    socket.emit('request-start-game', {'idRoom': idRoom, 'idUser': idUser});
  }

  @override
  void dispose() {
    _stopTurnCountdown();
    super.dispose();
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
                  SocketService.socket?.emit('request-out-room', {
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
          data: (data) {
            final currentUserName =
                data?['user']?['username']?.toString() ?? 'Bạn';
            final currentUserAvatarUrl = data?['user']?['avatar_url']
                ?.toString();
            final currentUserDisplayName = '$currentUserName (Bạn)';
            final opponentDisplayName = '$opponentName (Đối thủ)';
            final yourPiece = yourX ? 'X' : 'O';
            final opponentPiece = yourX ? 'O' : 'X';
            final currentUserStatus = stateGame == -1
                ? (yourTurn ? 'Đang suy nghĩ' : 'Đang chờ')
                : '';
            final opponentStatus = stateGame == -1
                ? (!yourTurn ? 'Đang suy nghĩ' : 'Đang chờ')
                : '';
            final isYourTimerRunning = yourTurn && stateGame == -1;
            final isOpponentTimerRunning = !yourTurn && stateGame == -1;

            return Column(
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
                                currentUserDisplayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentUserStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (isYourTimerRunning) ...[
                                    const SizedBox(width: 6),
                                    _buildTimerChip(
                                      pieceLabel: yourPiece,
                                      seconds: remainingTurnSeconds,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          PlayerAvatar(
                            name: currentUserName,
                            avatarUrl: currentUserAvatarUrl,
                            size: 40,
                          ),
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
                          PlayerAvatar(
                            name: opponentName,
                            avatarUrl: opponentAvatarUrl,
                            size: 40,
                          ),
                          Column(
                            spacing: 0,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opponentDisplayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    opponentStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (isOpponentTimerRunning) ...[
                                    const SizedBox(width: 6),
                                    _buildTimerChip(
                                      pieceLabel: opponentPiece,
                                      seconds: remainingTurnSeconds,
                                    ),
                                  ],
                                ],
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
                                          Offset(
                                            row.toDouble(),
                                            col.toDouble(),
                                          ),
                                        ) &&
                                        !visitedO.contains(
                                          Offset(
                                            row.toDouble(),
                                            col.toDouble(),
                                          ),
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
                                    onPressed: () {
                                      SocketService.emit('request-out-room', {
                                        'idRoom': idRoom,
                                        'idUser': idUser,
                                      });
                                      context.go('/');
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
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
            );
          },
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
        _setTurnDeadline(
          DateTime.now().millisecondsSinceEpoch + turnDurationMs,
        );
        hoverCell = null;
        SocketService.emit('request-on-move', {
          'idRoom': idRoom,
          'idUser': idUser,
          'x': row,
          'y': col,
        });
      });
    }
  }

  void _setTurnDeadline(int? deadlineMs) {
    if (deadlineMs == null || stateGame != -1) {
      _stopTurnCountdown();
      return;
    }
    _turnDeadlineMs = deadlineMs;
    _startTurnCountdown();
  }

  void _startTurnCountdown() {
    _turnCountdownTimer?.cancel();
    _updateCountdownTick();
    _turnCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdownTick();
    });
  }

  void _updateCountdownTick() {
    if (!mounted) return;
    if (_turnDeadlineMs == null || stateGame != -1) {
      _stopTurnCountdown();
      return;
    }
    final msLeft = _turnDeadlineMs! - DateTime.now().millisecondsSinceEpoch;
    final secondsLeft = msLeft <= 0 ? 0 : ((msLeft + 999) ~/ 1000);

    if (remainingTurnSeconds != secondsLeft) {
      setState(() {
        remainingTurnSeconds = secondsLeft;
      });
    }

    if (secondsLeft <= 0) {
      _turnCountdownTimer?.cancel();
    }
  }

  void _stopTurnCountdown() {
    _turnCountdownTimer?.cancel();
    _turnCountdownTimer = null;
    _turnDeadlineMs = null;
    remainingTurnSeconds = 0;
  }

  Widget _buildTimerChip({required String pieceLabel, required int seconds}) {
    final bool isUrgent = seconds <= 10;
    final Color textColor = isUrgent ? Colors.red.shade700 : Colors.black87;
    final Color background = isUrgent
        ? Colors.red.withValues(alpha: 0.14)
        : Colors.grey.withValues(alpha: 0.15);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent ? Colors.red.shade300 : Colors.transparent,
        ),
      ),
      child: Text(
        '$pieceLabel: ${seconds}s',
        style: TextStyle(
          fontSize: isUrgent ? 13 : 12,
          fontWeight: isUrgent ? FontWeight.w700 : FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void stateEndGame() {
    // Đã kết thúc trận đấu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String str = "";
      String subtitle = "";
      Color titleColor = Colors.red;
      switch (stateGame) {
        case 0:
          str = "Chiến thắng";
          subtitle = "Bạn đã đánh bại đối thủ. Tiếp tục chơi lại?";
          titleColor = Colors.green;
          break;
        case 1:
          str = "Thất bại";
          subtitle = "Đối thủ đã giành chiến thắng. Bạn muốn phục thù không?";
          titleColor = Colors.red;
          break;
        case 2:
          str = "Hòa";
          subtitle = "Trận đấu cân bằng. Bạn có muốn chơi tiếp không?";
          titleColor = Colors.orange;
          break;
      }
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return isYouReady == 1
              ? Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          color: Colors.orange.shade700,
                          size: 34,
                        ),
                        const Text(
                          "Bạn đã sẵn sàng chơi lại",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Đanh chờ đối thủ xác nhận...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: () {
                            SocketService.emit('request-out-room', {
                              'idRoom': idRoom,
                              'idUser': idUser,
                            });
                            context.go('/');
                          },
                          child: const Text('Rời khỏi phòng'),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: 12,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          str,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: isUserReady == 0
                              ? Text(
                                  "Đối thủ chưa sẵn sàng",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : isUserReady == 1
                              ? Text(
                                  "Đối thủ đã sẵn sàng",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Text(
                                  "Đối thủ đã rời khỏi phòng",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),

                        ButtonNormal(
                          text: "Chơi lại",
                          onPressed: () {
                            SocketService.emit('request-playagain', {
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
                            SocketService.emit('request-out-room', {
                              'idRoom': idRoom,
                              'idUser': idUser,
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
        },
      );
    });
  }
}
