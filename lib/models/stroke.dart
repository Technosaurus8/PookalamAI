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

// lib/models/stroke.dart — add a compact serializer
extension StrokeSerialization on Stroke {
  Map<String, dynamic> toFirestoreMap() {
    // Flat [x1, y1, x2, y2, ...] instead of a map per point, and
    // round to 1 decimal — sub-pixel precision doesn't matter for replay.
    final flatPoints = <double>[];
    for (final p in points) {
      flatPoints.add(double.parse(p.dx.toStringAsFixed(1)));
      flatPoints.add(double.parse(p.dy.toStringAsFixed(1)));
    }
    return {
      'color': color.value,
      'width': width,
      'isEraser': isEraser,
      'points': flatPoints,
    };
  }
}
