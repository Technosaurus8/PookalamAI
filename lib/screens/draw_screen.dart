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
import '../theme/app_theme.dart';
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
  final ScrollController _scrollController = ScrollController();

  Color _currentColor = onamPalette[0]; // marigold default
  double _currentWidth = brushMedium;
  bool _isEraser = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  bool _isDrawingActive = false;

  void _onStrokeStart() => setState(() => _isDrawingActive = true);
  void _onStrokeEnd() => setState(() => _isDrawingActive = false);

  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something before submitting!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await WidgetsBinding.instance.endOfFrame;

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
        builder: (ctx) => AppDecor.themedDialog(
          title: Text('Score!', style: AppText.heading(size: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score / 100',
                style: AppText.heading(size: 36, color: AppColors.green),
              ),
              const SizedBox(height: 12),
              Text(
                comment,
                textAlign: TextAlign.center,
                style: AppText.body(
                  color: AppColors.green,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK', style: AppText.button(size: 14)),
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
      backgroundColor: AppColors.green,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.cream),
        title: Text('Pookalam.ai', style: AppText.heading(size: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(18),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Drawing as ${widget.playerName}',
              style: AppText.label(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            const maxContentWidth = 640.0;
            const horizontalPadding = 32.0; // Padding(16) on each side
            const railCardWidth = 64.0;
            const railGap = 16.0;

            final isWide = outerConstraints.maxWidth >= 550;

            // Canvas sizing: on wide layouts, the rail sits *inside* the same
            // 640-wide content column (beside the canvas), so it eats into the
            // canvas's own width budget rather than growing the page.
            final availableForCanvas = isWide
                ? maxContentWidth - railCardWidth - railGap
                : maxContentWidth;
            final widthBasedSize = availableForCanvas - horizontalPadding;

            final isShortViewport = outerConstraints.maxHeight < 640;
            final heightBasedSize = outerConstraints.maxHeight - 260;

            final canvasSize = isShortViewport
                ? (widthBasedSize < heightBasedSize
                      ? widthBasedSize
                      : heightBasedSize)
                : widthBasedSize;

            final clampedSize = canvasSize.clamp(200.0, 560.0);

            // --- Shared pieces ---

            final colorsSection = Column(
              children: [
                Text('COLORS', style: AppText.label()),
                const SizedBox(height: 10),
                ColorSwatchRow(
                  selectedColor: _currentColor,
                  onColorSelected: _selectColor,
                ),
              ],
            );

            final canvasCard = Container(
              padding: const EdgeInsets.all(10),
              decoration: AppDecor.card(radius: 16),
              child: SizedBox(
                width: clampedSize,
                height: clampedSize,
                child: PookalamCanvas(
                  repaintBoundaryKey: _repaintBoundaryKey,
                  currentColor: _currentColor,
                  currentWidth: _currentWidth,
                  isEraser: _isEraser,
                  strokes: _strokes,
                  onStrokeStart: _onStrokeStart,
                  onStrokeEnd: _onStrokeEnd,
                ),
              ),
            );

            final brushSection = Column(
              children: [
                Text('BRUSH', style: AppText.label()),
                const SizedBox(height: 10),
                BrushSizeRow(
                  selectedWidth: _currentWidth,
                  onWidthSelected: _selectWidth,
                ),
              ],
            );

            final submitButton = SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppDecor.primaryButton,
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.green,
                        ),
                      )
                    : Text('Submit Pookalam', style: AppText.button(size: 18)),
              ),
            );

            final toolButtons = [
              IconButton(
                icon: const Icon(Icons.undo),
                color: AppColors.cream,
                onPressed: _undo,
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.cream,
                onPressed: _clear,
                tooltip: 'Clear',
              ),
              IconButton(
                icon: Icon(_isEraser ? Icons.brush : Icons.auto_fix_normal),
                onPressed: _toggleEraser,
                tooltip: _isEraser ? 'Switch to pencil' : 'Switch to eraser',
                color: _isEraser ? AppColors.gold : AppColors.cream,
              ),
            ];

            final toolRow = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: toolButtons,
            );

            final toolRail = Container(
              width: railCardWidth,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: AppDecor.card(
                radius: 16,
                color: AppColors.cream.withOpacity(0.08),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final button in toolButtons) ...[
                    button,
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            );

            // Rail sits alongside the canvas, but a matching invisible spacer on
            // the right balances it — otherwise the Column's default centering
            // treats [rail, gap, canvas] as one block and shifts the canvas itself
            // off-center to the right.
            final canvasRow = isWide
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      toolRail,
                      const SizedBox(width: railGap),
                      canvasCard,
                      const SizedBox(width: railGap),
                      SizedBox(
                        width: railCardWidth,
                      ), // balances toolRail's width
                    ],
                  )
                : canvasCard;

            final centerColumn = Column(
              children: [
                colorsSection,
                const SizedBox(height: 20),
                canvasRow,
                const SizedBox(height: 20),
                brushSection,
                if (!isWide) ...[const SizedBox(height: 8), toolRow],
                const SizedBox(height: 16),
                submitButton,
                const SizedBox(height: 16),
              ],
            );

            return Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              radius: const Radius.circular(8),
              thickness: 6,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: _isDrawingActive
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: centerColumn,
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
