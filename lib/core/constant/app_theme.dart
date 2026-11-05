import 'package:flutter/material.dart';

import 'app_color.dart';

/// سمة التطبيق: الخط والألوان الأساسية.
/// أشكال الحقول والأزرار في core/shared حتى تبقى موحّدة.
abstract final class AppTheme {
  /// اسم العائلة كما هو مسجّل في pubspec.yaml.
  static const String fontFamily = 'IBMPlexSansArabic';

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColor.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.orange,
        primary: AppColor.orange,
        onPrimary: AppColor.ink,
        surface: AppColor.surface,
        onSurface: AppColor.ink,
        error: AppColor.danger,
      ),
      // شريط العنوان: بلون الخلفية بلا ظل، والعنوان عريض (لوحات التاجر والمورد).
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColor.ink,
        ),
      ),
      // لون التحديد ومؤشر الكتابة في الحقول.
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColor.ink,
        selectionColor: AppColor.orangeSoft,
        selectionHandleColor: AppColor.orange,
      ),
    );
  }
}
