// lib/services/canvas_exporter.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class CanvasExporter {
  /// Captures the canvas, forces it to exactly [targetSize] x [targetSize],
  /// and returns a base64-encoded JPEG string sized to fit comfortably
  /// under Firestore's 1MB document limit.
  static Future<String> exportToBase64({
    required GlobalKey repaintBoundaryKey,
    int targetSize = 512,
    int startingQuality = 85,
  }) async {
    final boundary =
        repaintBoundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

    // Canvas is square, so width == height. Capture at a pixelRatio that
    // lands close to our target resolution — this way we're not throwing
    // away detail by capturing huge and shrinking hard, regardless of
    // whether the canvas rendered at 360px (phone) or 600px (desktop).
    final logicalSize = boundary.size.width;
    final pixelRatio = targetSize / logicalSize;

    final uiImage = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Decode and force an EXACT 512x512 — toImage's pixelRatio math can be
    // off by a pixel or two depending on the source size, and we want a
    // guaranteed, consistent dimension for every submission.
    final decoded = img.decodeImage(pngBytes)!;
    final resized = img.copyResize(
      decoded,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.average,
    );

    // JPEG, not PNG, for the stored image — flat-color line art compresses
    // dramatically better as JPEG, and we don't need PNG's transparency
    // since the canvas background is always solid white.
    var quality = startingQuality;
    Uint8List jpgBytes = Uint8List.fromList(
      img.encodeJpg(resized, quality: quality),
    );

    // Safety net: an unusually dense/busy drawing could still come out
    // large. Step quality down until comfortably under budget, leaving
    // headroom in the 1MB doc cap for the strokes array + metadata fields.
    const maxBase64Chars = 700 * 1024; // ~700KB of base64 text
    while (base64.encode(jpgBytes).length > maxBase64Chars && quality > 30) {
      quality -= 15;
      jpgBytes = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }

    return base64.encode(jpgBytes);
  }
}
