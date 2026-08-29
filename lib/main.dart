import 'package:flutter/material.dart';
import 'package:pookalamai/screens/draw_screen.dart';

import 'screens/welcome_screen.dart';
import 'screens/worker_test_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DrawScreen());
  }
}
