import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pookalamai/services/leaderboard_service.dart';
import 'package:pookalamai/services/worker_service.dart';
import '../models/stroke.dart';
import '../services/canvas_exporter.dart';
import '../widgets/pookalam_canvas.dart';
import '../widgets/color_swatch_row.dart';
import '../widgets/brush_size_row.dart';
import '../constants/onam_palette.dart';
import '../constants/brush_sizes.dart';
import 'leaderboard_screen.dart';

class DrawScreen extends StatefulWidget {
  final String playerName;
  const DrawScreen({super.key, required this.playerName});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final List<Stroke> _strokes = [];

  Color _currentColor = onamPalette[0]; // marigold default
  double _currentWidth = brushMedium;
  bool _isEraser = false;
  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _clear() {
    setState(() => _strokes.clear());
  }

  void _toggleEraser() {
    setState(() => _isEraser = !_isEraser);
  }

  void _selectColor(Color color) {
    setState(() {
      _currentColor = color;
      _isEraser = false; // picking a color implies going back to pencil
    });
  }

  void _selectWidth(double width) {
    setState(() => _currentWidth = width);
  }

  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something before submitting!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final base64Image = await CanvasExporter.exportToBase64(
        repaintBoundaryKey: _repaintBoundaryKey,
      );

      final result = await WorkerService.scoreImage(base64Image);
      debugPrint(
        'playerName: "${widget.playerName}", length: ${widget.playerName.length}, type: ${widget.playerName.runtimeType}',
      );
      debugPrint(
        'score value: ${result['score']}, type: ${result['score'].runtimeType}',
      );
      final score = result['score'] as int;
      final comment = result['comment'] as String;
      try {
        await LeaderboardService.submitEntry(
          playerName: widget.playerName,
          imageBase64: base64Image,
          score: score,
          comment: comment,
        );
      } catch (e, stack) {
        debugPrint('Submit failed: $e');
        debugPrint('Stack: $stack');
        rethrow;
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Show the result before navigating away
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Score!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score / 100',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(comment, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
      );
    } catch (e) {
      print(e);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      // Drawing is untouched — strokes list is still intact, user can retry
    }
  }

  // used for testing the base64 setup.
  Future<void> _testExport() async {
    final base64Str = await CanvasExporter.exportToBase64(
      repaintBoundaryKey: _repaintBoundaryKey,
    );
    debugPrint('Base64 length: ${base64Str.length} chars');
    // Optional: preview it
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(content: Image.memory(base64Decode(base64Str))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pookalam.ai — Draw')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            // Reserve rough space for toolbar rows above/below the canvas
            // so the canvas itself never has to guess.
            final availableWidth = outerConstraints.maxWidth - 32; // padding
            final availableHeight =
                outerConstraints.maxHeight - 260; // toolbars
            final canvasSize = availableWidth < availableHeight
                ? availableWidth
                : availableHeight;
            final clampedSize = canvasSize.clamp(200.0, 700.0);

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ColorSwatchRow(
                          selectedColor: _currentColor,
                          onColorSelected: _selectColor,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: clampedSize,
                          height: clampedSize,
                          child: PookalamCanvas(
                            repaintBoundaryKey: _repaintBoundaryKey,
                            currentColor: _currentColor,
                            currentWidth: _currentWidth,
                            isEraser: _isEraser,
                            strokes: _strokes,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BrushSizeRow(
                          selectedWidth: _currentWidth,
                          onWidthSelected: _selectWidth,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo),
                              onPressed: _undo,
                              tooltip: 'Undo',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _clear,
                              tooltip: 'Clear',
                            ),
                            IconButton(
                              icon: Icon(
                                _isEraser ? Icons.brush : Icons.auto_fix_normal,
                              ),
                              onPressed: _toggleEraser,
                              tooltip: _isEraser
                                  ? 'Switch to pencil'
                                  : 'Switch to eraser',
                              color: _isEraser
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Submit Pookalam'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
