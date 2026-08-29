import 'package:flutter/material.dart';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;

  Stroke({
    required this.color,
    required this.width,
    this.isEraser = false,
    List<Offset>? points,
  }) : points = points ?? [];
}
