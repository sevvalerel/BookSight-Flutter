import 'package:flutter/material.dart';

import 'navigation/app_page_route.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/user_profile_screen.dart';
import 'services/auth_service.dart';
import 'services/book_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loggedIn = await AuthService().isLoggedIn();
  runApp(BookSightApp(initialRoute: loggedIn ? '/home' : '/login'));
}

class BookSightApp extends StatelessWidget {
  final String initialRoute;
  const BookSightApp({super.key, required this.initialRoute});

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
      initialRoute: initialRoute,
      routes: {
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
          case '/user-profile':
            final username = settings.arguments as String;
            return AppPageRoute(
              settings: settings,
              page: UserProfileScreen(username: username),
            );
          default:
            return null;
        }
      },
    );
  }
}