import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required Widget page,
    RouteSettings? settings,
    Duration transitionDuration = const Duration(milliseconds: 320),
    Duration reverseTransitionDuration = const Duration(milliseconds: 260),
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved);

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
        );
}

extension AppNavigator on BuildContext {
  Future<T?> pushFadeSlide<T>(Widget page, {RouteSettings? settings}) {
    return Navigator.push<T>(
      this,
      AppPageRoute<T>(page: page, settings: settings),
    );
  }
}
