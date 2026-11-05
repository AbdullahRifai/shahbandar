import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_color.dart';
import '../localization/locale_controller.dart';
import 'app_select_field.dart';

/// A12 نافذة اللغة. تُفتح من تسجيل الدخول، ولاحقاً من "حسابي".
/// اسم كل لغة مكتوب بلغته، والاختيار يقلب الواجهة واتجاهها فوراً.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // على الشاشات العريضة لا تمتد النافذة على كامل العرض.
    constraints: const BoxConstraints(maxWidth: 560),
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final controller = Get.find<LocaleController>();

      void choose(String code) {
        Navigator.pop(sheetContext);
        controller.changeLanguage(code);
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'languageTitle'.tr,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColor.ink),
                ),
              ),
              const SizedBox(height: 12),
              OptionTile(label: 'العربية', selected: controller.isArabic, onTap: () => choose('ar')),
              OptionTile(
                label: 'English',
                textDirection: TextDirection.ltr,
                selected: !controller.isArabic,
                onTap: () => choose('en'),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'languageNote'.tr,
                  style: const TextStyle(fontSize: 13, height: 1.5, color: AppColor.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
