import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'on board screen.dart';

void main() {
  runApp(CleverTypeApp());
}

class CleverTypeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleverType AI Keyboard',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Color(0xFF1a1a2e),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF16213e),
          foregroundColor: Colors.white,
        ),
      ),
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
