import 'package:flutter/material.dart';

// Apple Health 风格配色
class AppColors {
  // 各指标主题色
  static const heartRate = Color(0xFFFF2D55); // 红色-心率
  static const steps = Color(0xFFFF9500); // 橙色-步数
  static const sleep = Color(0xFF6C47FF); // 紫色-睡眠
  static const weight = Color(0xFF30B0C7); // 青蓝-体重
  static const bloodPressure = Color(0xFFFF3B30); // 红色-血压
  static const nutrition = Color(0xFF30D158); // 绿色-营养
  static const mindfulness = Color(0xFF64D2FF); // 蓝色-正念
  static const water = Color(0xFF32ADE6); // 浅蓝-饮水

  // 背景色
  static const background = Color(0xFFF2F2F7); // iOS systemGroupedBackground
  static const cardBackground = Color(0xFFFFFFFF);
  static const groupedBackground = Color(0xFFF2F2F7);

  // 文字色
  static const primaryText = Color(0xFF1C1C1E);
  static const secondaryText = Color(0xFF8E8E93);
  static const tertiaryText = Color(0xFFC7C7CC);

  // 分隔线
  static const separator = Color(0xFFC6C6C8);
  static const opaqueSeparator = Color(0xFF3A3A3C);
}

class AppTypography {
  static const largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: 0.37,
  );

  static const title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: 0.36,
  );

  static const title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: 0.35,
  );

  static const title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: 0.38,
  );

  static const headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: -0.41,
  );

  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    letterSpacing: -0.41,
  );

  static const callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    letterSpacing: -0.32,
  );

  static const subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    letterSpacing: -0.24,
  );

  static const metricValue = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: 0.37,
  );

  static const metricUnit = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
    letterSpacing: -0.32,
  );

  static const footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    letterSpacing: -0.08,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    letterSpacing: 0,
  );
}

// Apple 风格卡片圆角
class AppRadius {
  static const card = BorderRadius.all(Radius.circular(14));
  static const small = BorderRadius.all(Radius.circular(10));
  static const large = BorderRadius.all(Radius.circular(20));
}

// Apple 风格间距
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const section = 32.0;
}

// 生成 Apple Health 风格的 ThemeData
class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007AFF),
      secondary: AppColors.heartRate,
      surface: AppColors.cardBackground,
      onPrimary: Colors.white,
      onSurface: AppColors.primaryText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.title3,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 0.33,
      color: AppColors.separator,
      indent: 56,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      selectedItemColor: Color(0xFF007AFF),
      unselectedItemColor: AppColors.secondaryText,
      type: BottomNavigationBarType.fixed,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF007AFF);
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF007AFF).withOpacity(0.3);
        }
        return null;
      }),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Color(0xFF007AFF),
      unselectedLabelColor: AppColors.secondaryText,
      indicatorColor: Color(0xFF007AFF),
    ),
    useMaterial3: true,
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0A84FF),
      secondary: AppColors.heartRate,
      surface: Color(0xFF1C1C1E),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000000),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: const Color(0xFF1C1C1E),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 0.33,
      color: AppColors.opaqueSeparator,
      indent: 56,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1C1C1E),
      elevation: 0,
      selectedItemColor: Color(0xFF0A84FF),
      unselectedItemColor: AppColors.secondaryText,
      type: BottomNavigationBarType.fixed,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF0A84FF);
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF0A84FF).withOpacity(0.3);
        }
        return null;
      }),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Color(0xFF0A84FF),
      unselectedLabelColor: AppColors.secondaryText,
      indicatorColor: Color(0xFF0A84FF),
    ),
    useMaterial3: true,
  );
}
