import 'package:flutter/material.dart';

import '../constant/app_color.dart';
import '../constant/app_theme.dart';

/// primary: البرتقالي، لإجراء رئيسي واحد في الشاشة.
/// secondary: أبيض بحدّ رمادي، للإجراء البديل.
/// danger: أحمر، للإجراءات التي لا تُعكس.
enum AppButtonStyle { primary, secondary, danger }

/// الزر الموحّد: ارتفاع 52، زوايا 16، حالة تحميل تمنع الضغط المزدوج.
/// onPressed = null ← الزر معطّل (رمادي).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, side) = switch (style) {
      AppButtonStyle.primary => (AppColor.orange, AppColor.ink, BorderSide.none),
      AppButtonStyle.secondary => (
          AppColor.surface,
          AppColor.ink,
          const BorderSide(color: AppColor.border, width: 1.5)
        ),
      AppButtonStyle.danger => (AppColor.danger, AppColor.surface, BorderSide.none),
    };

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: bg,
        foregroundColor: fg,
        side: side,
        // أثناء التحميل يبقى اللون كما هو حتى لا يبدو الزر معطّلاً.
        disabledBackgroundColor: isLoading ? bg : AppColor.divider,
        disabledForegroundColor: isLoading ? fg : AppColor.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: isLoading
          ? Semantics(
              label: label,
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
              ),
            )
          : Text(label, textAlign: TextAlign.center),
    );
  }
}

/// رابط نصي بالبرتقالي العميق، مساحة لمسه 48.
class AppTextLink extends StatelessWidget {
  const AppTextLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColor.orangeDeep,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        textStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}
