// lib/widgets/pookalam_canvas.dart
import 'package:flutter/material.dart';
import '../models/stroke.dart';

class PookalamCanvas extends StatefulWidget {
  final GlobalKey repaintBoundaryKey;
  final Color currentColor;
  final double currentWidth;
  final bool isEraser;
  final List<Stroke> strokes; // lifted state, see note below

  const PookalamCanvas({
    super.key,
    required this.repaintBoundaryKey,
    required this.currentColor,
    required this.currentWidth,
    required this.isEraser,
    required this.strokes,
  });

  @override
  State<PookalamCanvas> createState() => _PookalamCanvasState();
}

class _PookalamCanvasState extends State<PookalamCanvas> {
  Stroke? _activeStroke;

  void _onPanStart(DragStartDetails details, RenderBox box) {
    final local = box.globalToLocal(details.globalPosition);
    final stroke = Stroke(
      color: widget.isEraser ? Colors.white : widget.currentColor,
      width: widget.currentWidth,
      isEraser: widget.isEraser,
    )..points.add(local);
    setState(() {
      _activeStroke = stroke;
      widget.strokes.add(stroke);
    });
  }

  void _onPanUpdate(DragUpdateDetails details, RenderBox box) {
    if (_activeStroke == null) return;
    final local = box.globalToLocal(details.globalPosition);
    setState(() {
      _activeStroke!.points.add(local);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _activeStroke = null;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RepaintBoundary(
            key: widget.repaintBoundaryKey,
            child: Container(
              color: Colors.white, // fixed canvas background
              child: Builder(
                builder: (ctx) {
                  return GestureDetector(
                    onPanStart: (d) =>
                        _onPanStart(d, ctx.findRenderObject() as RenderBox),
                    onPanUpdate: (d) =>
                        _onPanUpdate(d, ctx.findRenderObject() as RenderBox),
                    onPanEnd: _onPanEnd,
                    child: CustomPaint(
                      painter: PookalamPainter(strokes: widget.strokes),
                      size: Size.infinite,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class PookalamPainter extends CustomPainter {
  final List<Stroke> strokes;
  PookalamPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final points = stroke.points;
      if (points.isEmpty) continue;

      if (points.length == 1) {
        // single tap — draw a dot
        canvas.drawCircle(
          points[0],
          stroke.width / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }

      final path = Path()..moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final midpoint = Offset(
          (current.dx + next.dx) / 2,
          (current.dy + next.dy) / 2,
        );
        path.quadraticBezierTo(
          current.dx,
          current.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }
      // last segment: curve into the final point
      path.lineTo(points.last.dx, points.last.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PookalamPainter oldDelegate) => true;
}
