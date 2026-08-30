// lib/widgets/pookalam_canvas.dart
import 'package:flutter/material.dart';
import '../models/stroke.dart';

class PookalamCanvas extends StatefulWidget {
  final GlobalKey repaintBoundaryKey;
  final Color currentColor;
  final double currentWidth;
  final bool isEraser;
  final List<Stroke> strokes;
  final VoidCallback? onStrokeStart;
  final VoidCallback? onStrokeEnd;

  const PookalamCanvas({
    super.key,
    required this.repaintBoundaryKey,
    required this.currentColor,
    required this.currentWidth,
    required this.isEraser,
    required this.strokes,
    this.onStrokeStart,
    this.onStrokeEnd,
  });

  @override
  State<PookalamCanvas> createState() => _PookalamCanvasState();
}

class _PookalamCanvasState extends State<PookalamCanvas> {
  Stroke? _activeStroke;

  Offset _clampToCanvas(Offset point, Size canvasSize) {
    return Offset(
      point.dx.clamp(0.0, canvasSize.width),
      point.dy.clamp(0.0, canvasSize.height),
    );
  }

  void _onPointerDown(PointerDownEvent event, RenderBox box) {
    widget.onStrokeStart?.call();
    final local = _clampToCanvas(box.globalToLocal(event.position), box.size);
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

  void _onPointerMove(PointerMoveEvent event, RenderBox box) {
    if (_activeStroke == null) return;
    final local = _clampToCanvas(box.globalToLocal(event.position), box.size);
    setState(() {
      _activeStroke!.points.add(local);
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    _activeStroke = null;
    widget.onStrokeEnd?.call();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activeStroke = null;
    widget.onStrokeEnd?.call();
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
              color: Colors.white,
              child: Builder(
                builder: (ctx) {
                  return Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (e) =>
                        _onPointerDown(e, ctx.findRenderObject() as RenderBox),
                    onPointerMove: (e) =>
                        _onPointerMove(e, ctx.findRenderObject() as RenderBox),
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    child: ClipRect(
                      child: CustomPaint(
                        painter: PookalamPainter(strokes: widget.strokes),
                        size: Size.infinite,
                      ),
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
