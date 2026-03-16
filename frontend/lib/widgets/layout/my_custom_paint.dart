import 'dart:math';

import 'package:flutter/material.dart';

class MyCustomPaintO extends StatelessWidget {
  final double size;
  const MyCustomPaintO({super.key, required this.size});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _MyCustomPaintO());
  }
}

class _MyCustomPaintO extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double r = w / 2;
    final double stroke = w * 0.2;
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle
          .stroke // Khi vẽ sẽ nằm giữa stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(Offset(r, r), r - stroke / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MyCustomPaintX extends StatelessWidget {
  final double size;
  const MyCustomPaintX({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _MyCustomPaintX());
  }
}

class _MyCustomPaintX extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double stroke = w * 0.2;
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawLine(
      Offset(stroke / 2, stroke / 2),
      Offset(w - stroke / 2, w - stroke / 2),
      paint,
    );
    canvas.drawLine(
      Offset(w - stroke / 2, stroke / 2),
      Offset(stroke / 2, w - stroke / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CircleCountDown extends StatefulWidget {
  final double size;
  final int seconds;
  const CircleCountDown({super.key, required this.size, required this.seconds});

  @override
  State<StatefulWidget> createState() {
    return _CircleCountDown();
  }
}

class _CircleCountDown extends State<CircleCountDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _MyCustomPaintCircleCountDown(_controller.value),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MyCustomPaintCircleCountDown extends CustomPainter {
  final double progress;
  const _MyCustomPaintCircleCountDown(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double r = w / 2;
    final double stroke = w * 0.15;
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(r, r), radius: r - stroke / 2),
      -pi / 2, // Điểm bắt đầu
      2 * pi * progress, // Chiều dài đường tròn
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MyCustomPaintCircleCountDown oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class GameBoard extends StatefulWidget {
  final bool currMoveIsX;
  final bool isYourTurn;
  const GameBoard({
    super.key,
    required this.currMoveIsX,
    this.isYourTurn = true,
  }); // 1 -> X, 0 -> O

  @override
  State<StatefulWidget> createState() {
    return _GameBoard();
  }
}

class _GameBoard extends State<GameBoard> {
  late bool currMoveIsX;
  late bool isYourTurn;
  final int gridSize = 16;
  final double cellSize = 25;

  Offset? hoverCell;
  Set<Offset> visitedX = {};
  Set<Offset> visitedO = {};

  @override
  void initState() {
    super.initState();
    currMoveIsX = widget.currMoveIsX;
    isYourTurn = widget.isYourTurn;
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
        currMoveIsX = !currMoveIsX;
        hoverCell = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        if (!isYourTurn) {
          hoverCell = null;
          return;
        }
        final locationPostion = event.localPosition;
        int row = (locationPostion.dy / cellSize).floor();
        int col = (locationPostion.dx / cellSize).floor();
        if (0 <= row &&
            row < gridSize &&
            0 <= col &&
            col < gridSize &&
            !visitedX.contains(Offset(row.toDouble(), col.toDouble())) &&
            !visitedO.contains(Offset(row.toDouble(), col.toDouble()))) {
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
        onTapUp: _handelOnTapUp,
        child: CustomPaint(
          size: Size(gridSize * cellSize, gridSize * cellSize),
          painter: MyCustomPaintGameBoardCustomPainter(
            gridSize,
            cellSize,
            visitedX,
            visitedO,
            hoverCell,
            currMoveIsX,
          ),
        ),
      ),
    );
  }
}

class MyCustomPaintGameBoardCustomPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;
  final bool currMoveIsX;
  final Offset? hoverCell;
  final Set<Offset> visitedX;
  final Set<Offset> visitedO;
  const MyCustomPaintGameBoardCustomPainter(
    this.gridSize,
    this.cellSize,
    this.visitedX,
    this.visitedO,
    this.hoverCell,
    this.currMoveIsX,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = 1;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(gridSize * cellSize, i * cellSize),
        paint,
      );
    }

    for (int i = 0; i < gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellSize + 0.5, 0),
        Offset(i * cellSize + 0.5, gridSize * cellSize),
        paint,
      );
    }

    canvas.drawLine(
      Offset(gridSize * cellSize - 0.5, 0),
      Offset(gridSize * cellSize - 0.5, gridSize * cellSize),
      paint,
    );

    // Vẽ X
    final double strokeX = cellSize * 0.15;
    final paintX = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeX;
    for (Offset cell in visitedX) {
      final double y = cell.dx * cellSize;
      final double x = cell.dy * cellSize + 0.5;
      _drawX(canvas, cellSize, cellSize * 0.15, paintX, x, y);
    }

    // Vẽ O
    final double wO = cellSize;
    final double strokeO = wO * 0.15;
    final paintO = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeO;
    for (Offset cell in visitedO) {
      final double y = cell.dx * cellSize;
      final double x = cell.dy * cellSize + 0.5;
      canvas.drawCircle(
        Offset(x + wO / 2, y + wO / 2),
        wO / 2 - strokeO / 2 - 3,
        paintO,
      );
    }

    // Vẽ hover
    if (hoverCell != null) {
      if (currMoveIsX) {
        final double strokeHoverX = cellSize * 0.15;
        final paintX = Paint()
          ..color = Colors.red[200]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeHoverX;
        final double y = hoverCell!.dx * cellSize;
        final double x = hoverCell!.dy * cellSize + 0.5;
        _drawX(canvas, cellSize, strokeHoverX, paintX, x, y);
      } else {
        final double strokeO = cellSize * 0.15;
        final paintO = Paint()
          ..color = Colors.green[200]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeO;
        final double y = hoverCell!.dx * cellSize;
        final double x = hoverCell!.dy * cellSize + 0.5;

        _drawO(canvas, cellSize, strokeO, x, y, paintO);
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant MyCustomPaintGameBoardCustomPainter oldDelegate,
  ) {
    return (oldDelegate.visitedX.length != visitedX.length) ||
        (oldDelegate.visitedO.length != visitedO.length) ||
        (oldDelegate.hoverCell != hoverCell);
  }
}

void _drawX(
  Canvas canvas,
  double w,
  double stroke,
  Paint paint,
  double x,
  double y,
) {
  canvas.drawLine(
    Offset(x + 1.5 + stroke / 2, y + 1.5 + stroke / 2),
    Offset(x - 1.5 + w - stroke / 2, y - 1.5 + w - stroke / 2),
    paint,
  );
  canvas.drawLine(
    Offset(x - 1.5 + w - stroke / 2, y + 1.5 + stroke / 2),
    Offset(x + 1.5 + stroke / 2, y - 1.5 + w - stroke / 2),
    paint,
  );
}

void _drawO(
  Canvas canvas,
  double w,
  double stroke,
  double x,
  double y,
  Paint paint,
) {
  canvas.drawCircle(
    Offset(x + w / 2, y + w / 2),
    w / 2 - stroke / 2 - 3,
    paint,
  );
}
