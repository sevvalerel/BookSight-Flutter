import 'package:flutter/material.dart';

import 'navigation/app_page_route.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

import 'screens/book_detail_screen.dart';
import 'services/book_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return AppPageRoute(
              settings: settings,
              page: const RegisterScreen(),
            );
          case '/book-detail':
            final book = settings.arguments as Book;
            return AppPageRoute(
              settings: settings,
              page: BookDetailScreen(book: book),
            );
          default:
            return null;
        }
      },
    );
  }
}