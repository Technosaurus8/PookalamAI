// lib/screens/draw_screen.dart
import 'package:flutter/material.dart';
import '../models/stroke.dart';
import '../widgets/pookalam_canvas.dart';
import '../widgets/color_swatch_row.dart';
import '../widgets/brush_size_row.dart';
import '../constants/onam_palette.dart';
import '../constants/brush_sizes.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pookalam.ai — Draw')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ColorSwatchRow(
                selectedColor: _currentColor,
                onColorSelected: _selectColor,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                      maxHeight: 600,
                    ),
                    child: PookalamCanvas(
                      repaintBoundaryKey: _repaintBoundaryKey,
                      currentColor: _currentColor,
                      currentWidth: _currentWidth,
                      isEraser: _isEraser,
                      strokes: _strokes,
                    ),
                  ),
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
                    icon: Icon(_isEraser ? Icons.brush : Icons.auto_fix_normal),
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
                onPressed: () {
                  // Submit wiring: step 8-9
                },
                child: const Text('Submit Pookalam'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
