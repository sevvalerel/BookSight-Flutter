import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const BookSightApp());
}

class BookSightApp extends StatelessWidget {
  const BookSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8BC3A3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}