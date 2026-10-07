import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    primary: AppColors.blue,
    secondary: AppColors.pink,
    error: AppColors.error,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.navy,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.navy,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.blueTint,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
      border: _border(AppColors.border),
      enabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.blue, 1.4),
      errorBorder: _border(AppColors.error),
      focusedErrorBorder: _border(AppColors.error, 1.4),
    ),
  );
}

OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );