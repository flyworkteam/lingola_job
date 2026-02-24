import 'package:flutter/material.dart';

import 'colors.dart';
import 'radius.dart';
import 'spacing.dart';
import 'typography.dart';

export 'colors.dart';
export 'radius.dart';
export 'spacing.dart';
export 'typography.dart';

/// Uygulama teması: renk, spacing ve radius token'larına dayanır.
abstract final class AppTheme {
  AppTheme._();

  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    error: AppColors.error,
    onError: AppColors.onError,
  );

  static ThemeData get light => ThemeData.from(
        colorScheme: _lightScheme,
        useMaterial3: true,
        textTheme: AppTypography.textTheme,
      ).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryBrand,
          selectionColor: AppColors.primaryBrand.withValues(alpha: 0.3),
          selectionHandleColor: AppColors.primaryBrand,
        ),
      );
}
