import 'package:flutter/material.dart';

/// Back butonunda kullanılır: önceki sayfa soldan sağa (geri gelir) animasyonla açılır.
void pushReplacementWithBackAnimation(BuildContext context, Widget previousPage) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => previousPage,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(-0.25, 0), // soldan gelir
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        return SlideTransition(position: slide, child: child);
      },
    ),
  );
}
