import 'package:flutter/material.dart';

/// Ortak ikon butonu: kare, yuvarlatılmış köşe, tıklanabilir alan.
/// Bildirim, ayarlar vb. ikon butonları için kullanılır.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 48,
    this.borderRadius = 12,
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? const Color(0xFFF2F5FC),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}
