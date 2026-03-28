import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Açık tema splash: lavanta → nane yeşili gradient, logo, slogan, sayfa noktaları.
abstract final class _SplashColors {
  static const Color lavenderTop = Color(0xFFE8E4F3);
  static const Color mintBottom = Color(0xFFE5F4EC);
  static const Color taglineGrey = Color(0xFF4A5A66);
  static const Color dotPurple = Color(0xFFB8A9E0);
  static const Color dotMint = Color(0xFF9FD4B8);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _navDelay = Duration(milliseconds: 2600);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final loggedIn = await AuthService().isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }
    _timer = Timer(_navDelay, _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _SplashColors.lavenderTop,
              _SplashColors.mintBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  'assets/images/booksight_logo.png',
                  width: 280,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 28),
                Text(
                  'Kişisel okuma yolculuğun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _SplashColors.taglineGrey.withValues(alpha: 0.95),
                    height: 1.35,
                  ),
                ),
                const Spacer(flex: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(_SplashColors.dotMint),
                    const SizedBox(width: 10),
                    _buildDot(_SplashColors.dotPurple),
                    const SizedBox(width: 10),
                    _buildDot(_SplashColors.dotMint),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
