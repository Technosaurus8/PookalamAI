import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pookalamai/screens/draw_screen.dart';
import 'package:pookalamai/screens/leaderboard_screen.dart';

import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/worker_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WelcomeScreen());
  }
}
