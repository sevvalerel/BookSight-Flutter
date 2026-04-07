import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

import 'screens/book_detail_screen.dart';
import 'services/book_service.dart';

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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/book-detail': (context) => BookDetailScreen(
          book: ModalRoute.of(context)!.settings.arguments as Book,
),
      },
    );
  }
}