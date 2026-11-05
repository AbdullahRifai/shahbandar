import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/max_width.dart';

/// الشريط العلوي البسيط: زر رجوع (اختياري) وعنوان.
/// سهم الرجوع ينعكس تلقائياً مع اتجاه اللغة.
class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key, this.title, this.showBack = true, this.onBack});

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return MaxWidth(
      child: SizedBox(
      height: 64,
      child: Row(
        children: [
          SizedBox(width: showBack ? 8 : 24),
          if (showBack)
            IconButton(
              onPressed: onBack ?? () => Get.back(),
              tooltip: 'back'.tr,
              iconSize: 24,
              color: AppColor.ink,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          if (title != null)
            Text(
              title!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColor.ink),
            ),
        ],
      ),
      ),
    );
  }
}
