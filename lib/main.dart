import 'package:flutter/material.dart';
import 'package:cozy_feels_app/features/history/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CozyFeelsApp());
}

class CozyFeelsApp extends StatelessWidget {
  const CozyFeelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Dongle',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}