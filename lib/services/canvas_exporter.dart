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
  ///
  /// Note: Flutter Web has no isolate/compute() offloading (compute()
  /// silently runs on the main thread on web), so the decode/resize/encode
  /// work below is genuinely synchronous. We insert explicit
  /// `Future.delayed(Duration.zero)` yields between the expensive steps so
  /// the event loop gets a chance to actually paint the pending "submitting"
  /// frame (spinner, disabled button) instead of it being starved until
  /// the whole block finishes.
  static Future<String> exportToBase64({
    required GlobalKey repaintBoundaryKey,
    int targetSize = 512,
    int startingQuality = 85,
  }) async {
    final boundary =
        repaintBoundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

    final logicalSize = boundary.size.width;
    final pixelRatio = targetSize / logicalSize;

    final uiImage = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Yield before the CPU-heavy part starts, so any pending UI frame
    // (e.g. the spinner swap from setState) gets to paint first.
    await WidgetsBinding.instance.endOfFrame;
    final decoded = img.decodeImage(pngBytes)!;

    await WidgetsBinding.instance.endOfFrame;

    final resized = img.copyResize(
      decoded,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.average,
    );

    await WidgetsBinding.instance.endOfFrame;

    var quality = startingQuality;
    Uint8List jpgBytes = Uint8List.fromList(
      img.encodeJpg(resized, quality: quality),
    );

    // Safety net: an unusually dense/busy drawing could still come out
    // large. Step quality down until comfortably under budget, yielding
    // between each retry so a multi-pass encode doesn't compound into one
    // long unbroken block.
    const maxBase64Chars = 700 * 1024; // ~700KB of base64 text
    while (base64.encode(jpgBytes).length > maxBase64Chars && quality > 30) {
      await WidgetsBinding.instance.endOfFrame;
      quality -= 15;
      jpgBytes = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }

    return base64.encode(jpgBytes);
  }
}
