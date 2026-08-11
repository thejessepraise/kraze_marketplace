import 'package:flutter/material.dart';

/// A single, shared page transition used everywhere Kraze pushes a new
/// screen — a subtle fade combined with a small upward slide.
///
/// WHY ONE HELPER INSTEAD OF PER-SCREEN TRANSITIONS:
/// Every push in the app (Product Detail, Search, Chat, Post Item,
/// Signup, ...) should feel identical. Building this once means a
/// future tweak (duration, curve, distance) only has to happen here.
///
/// Kept intentionally restrained: ~220ms, ease-out curve, and a small
/// 6% screen-height slide — enough that navigation doesn't feel like an
/// instant teleport, subtle enough that it's barely noticed.
class KrazePageRoute<T> extends PageRouteBuilder<T> {
  KrazePageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
