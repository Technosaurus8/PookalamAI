import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Design tokens (matches app-wide Onam palette) ---
class _Palette {
  static const green = Color(0xFF0F3D2E);
  static const gold = Color(0xFFF2A93C);
  static const red = Color(0xFFC1432E);
  static const cream = Color(0xFFFAF6EE);
  static const purple = Color(0xFF6B3FA0);
  static const yellow = Color(0xFFF7D046);
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    // Slow, ambient rotation — not a loading spinner, a living motif.
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  String _resolvedName() {
    final entered = _nameController.text.trim();
    if (entered.isNotEmpty) return entered;
    // Auto-generate so a blank field never blocks play — keeps the demo
    // frictionless for judges walking up cold.
    final id = Random().nextInt(9000) + 1000;
    return 'Artist_$id';
  }

  void _startDrawing() {
    final playerName = _resolvedName();
    // TODO: replace with real navigation once CanvasScreen exists.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _PlaceholderScreen(title: 'Canvas — playerName: $playerName'),
      ),
    );
  }

  void _openLeaderboard() {
    // TODO: replace with real navigation once LeaderboardScreen exists.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _PlaceholderScreen(title: 'Leaderboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.green,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Signature element: rotating pookalam ring ---
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _ringController.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: CustomPaint(
                      size: const Size(160, 160),
                      painter: _PookalamRingPainter(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // --- Title ---
                  Text(
                    'Pookalam.ai',
                    style: GoogleFonts.baloo2(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: _Palette.gold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Draw a pookalam. Let AI judge your art.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _Palette.cream.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // --- Name entry card ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _Palette.cream,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _Palette.green,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Your name (optional)',
                        hintStyle: GoogleFonts.inter(
                          color: _Palette.green.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                      ),
                      onSubmitted: (_) => _startDrawing(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Primary CTA ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startDrawing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Palette.gold,
                        foregroundColor: _Palette.green,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Start Drawing',
                        style: GoogleFonts.baloo2(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Secondary action ---
                  TextButton(
                    onPressed: _openLeaderboard,
                    style: TextButton.styleFrom(
                      foregroundColor: _Palette.cream.withOpacity(0.85),
                    ),
                    child: Text(
                      'View Leaderboard',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: _Palette.cream.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a small concentric pookalam: rings of petal-dots in the Onam
/// palette. This is the app's signature visual element — a live preview
/// of the thing the player is about to make, not a stock icon.
class _PookalamRingPainter extends CustomPainter {
  static const _ringColors = [
    _Palette.red,
    _Palette.gold,
    _Palette.yellow,
    _Palette.purple,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Center bud
    canvas.drawCircle(
      center,
      maxRadius * 0.12,
      Paint()..color = _Palette.cream,
    );

    for (int ring = 0; ring < _ringColors.length; ring++) {
      final ringRadius = maxRadius * (0.28 + ring * 0.22);
      final petalCount = 8 + ring * 4;
      final petalRadius = maxRadius * (0.09 - ring * 0.008);
      final color = _ringColors[ring];

      for (int i = 0; i < petalCount; i++) {
        final angle = (2 * pi / petalCount) * i;
        final petalCenter = Offset(
          center.dx + ringRadius * cos(angle),
          center.dy + ringRadius * sin(angle),
        );
        canvas.drawCircle(
          petalCenter,
          petalRadius,
          Paint()..color = color.withOpacity(0.95),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PookalamRingPainter oldDelegate) => false;
}

/// Temporary stand-in until CanvasScreen / LeaderboardScreen exist.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.green,
      appBar: AppBar(backgroundColor: _Palette.green, elevation: 0),
      body: Center(
        child: Text(
          title,
          style: GoogleFonts.inter(color: _Palette.cream, fontSize: 16),
        ),
      ),
    );
  }
}
