import 'package:flutter/material.dart';
import '../models/stroke.dart';
import '../widgets/pookalam_canvas.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final List<Stroke> _strokes = [];

  Color _currentColor =
      Colors.deepOrange; // stand-in for marigold swatch, swap in step 4
  double _currentWidth = 4.0; // stand-in for brush-size presets, swap in step 5
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pookalam.ai — Draw')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Toolbar — bare bones for now, full palette/brush UI comes next
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
              // The square canvas — centered, responsive, capped so it
              // doesn't blow past available height on short screens.
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
              ElevatedButton(
                onPressed: () {
                  // Submit wiring comes in step 8-9 (RepaintBoundary -> image -> Worker)
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
