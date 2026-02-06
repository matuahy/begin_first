import 'package:flutter/cupertino.dart';

class AppColors {
  static const primary = Color(0xFF22695C);
  static const primaryStrong = Color(0xFF184C42);
  static const primarySoft = Color(0xFFDCEDE7);
  static const accent = Color(0xFFB67A2E);
  static const success = Color(0xFF217A52);
  static const warning = Color(0xFFD0812D);
  static const error = Color(0xFFC3423F);

  static const background = Color(0xFFF4F1E9);
  static const secondaryBackground = Color(0xFFFCFAF4);
  static const groupedBackground = Color(0xFFECE6D8);
  static const tabBarBackground = Color(0xFFF9F4EA);
  static const cardBackground = Color(0xFFFFFEFB);
  static const elevatedCard = Color(0xFFF5F8F1);
  static const border = Color(0xFFD7D0C0);
  static const divider = Color(0xFFE6E0D2);

  static const textPrimary = Color(0xFF1E2A32);
  static const textSecondary = Color(0xFF5C6770);
  static const textTertiary = Color(0xFF8A949C);
  static const textOnPrimary = Color(0xFFFCFFFD);
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
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 26.0;
}

class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const bodyMuted = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  // iOS style aliases
  static const TextStyle largeTitle = titleLarge;
  static const TextStyle title1 = title;
  static const TextStyle title2 = heading;
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static const TextStyle subhead = TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
  );
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    color: AppColors.textTertiary,
  );
}

class AppDecorations {
  static const page = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF9F5EC),
        AppColors.background,
      ],
      stops: [0.0, 0.45],
    ),
  );

  static BoxDecoration card({
    bool emphasized = false,
    Color? color,
  }) {
    final background = color ?? (emphasized ? AppColors.elevatedCard : AppColors.cardBackground);
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: emphasized ? AppColors.primarySoft : AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x17000000),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}

/// iOS风格阴影样式
class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.textPrimary.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.textPrimary.withOpacity(0.14),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: AppColors.textPrimary.withOpacity(0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
}



class AppTheme {
  static CupertinoThemeData light() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.secondaryBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: AppTextStyles.body,
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        navLargeTitleTextStyle: AppTextStyles.titleLarge,
        navActionTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        actionTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        dateTimePickerTextStyle: AppTextStyles.body,
        tabLabelTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
