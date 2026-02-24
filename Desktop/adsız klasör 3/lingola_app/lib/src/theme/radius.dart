import 'package:flutter/material.dart';

/// Border radius tek sistem. Tüm yuvarlak köşeler bu token'lardan gelir.
abstract final class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;

  static BorderRadius get zero => BorderRadius.circular(none);
  static BorderRadius get small => BorderRadius.circular(xs);
  static BorderRadius get medium => BorderRadius.circular(sm);
  static BorderRadius get large => BorderRadius.circular(md);
  static BorderRadius get xLarge => BorderRadius.circular(lg);
  static BorderRadius get xxLarge => BorderRadius.circular(xl);
  static BorderRadius get round => BorderRadius.circular(full);
}
