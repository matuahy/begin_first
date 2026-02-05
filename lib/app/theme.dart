import 'package:flutter/cupertino.dart';

class AppColors {
  static const primary = CupertinoColors.systemBlue;
  static const secondary = CupertinoColors.systemGrey;
  static const success = CupertinoColors.systemGreen;
  static const warning = CupertinoColors.systemOrange;
  static const error = CupertinoColors.systemRed;

  static const background = CupertinoColors.systemBackground;
  static const secondaryBackground = CupertinoColors.secondarySystemBackground;
  static const groupedBackground = CupertinoColors.systemGroupedBackground;

  static const textPrimary = CupertinoColors.label;
  static const textSecondary = CupertinoColors.secondaryLabel;
  static const textTertiary = CupertinoColors.tertiaryLabel;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

class AppTheme {
  static CupertinoThemeData light() {
    return const CupertinoThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.secondaryBackground,
    );
  }
}
