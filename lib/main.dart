import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

void main() => runApp(const HauntedMansionApp());

class HauntedMansionApp extends StatelessWidget {
  const HauntedMansionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Haunted Creature Registry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
