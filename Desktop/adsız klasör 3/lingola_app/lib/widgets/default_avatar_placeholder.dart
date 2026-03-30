import 'package:flutter/material.dart';

import 'package:lingola_app/theme/colors.dart';

/// Profil fotoğrafı yokken kullanılan nötr ikon (dummy görsel yerine).
class DefaultAvatarPlaceholder extends StatelessWidget {
  const DefaultAvatarPlaceholder({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.52,
        color: AppColors.outline,
      ),
    );
  }
}
