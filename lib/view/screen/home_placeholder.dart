import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_placeholder_controller.dart';
import '../../core/constant/app_color.dart';
import '../../core/shared/app_button.dart';
import '../widget/auth/auth_body.dart';
import '../widget/auth/auth_title.dart';

/// شاشة مؤقتة للوحتي التاجر والمورد حتى نبنيهما.
/// زر تسجيل الخروج يسمح بتجربة رحلة الحساب من جديد.
class HomePlaceholderScreen extends GetView<HomePlaceholderController> {
  const HomePlaceholderScreen({super.key, required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AuthBody(
          top: 120,
          centered: true,
          children: [
            AuthTitle(title: titleKey.tr, subtitle: 'homeComingNext'.tr, centered: true),
            const SizedBox(height: 12),
            Text(
              controller.email,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 15, color: AppColor.textSecondary),
            ),
          ],
          bottom: [
            SizedBox(
              width: double.infinity,
              child: AppButton(
                style: AppButtonStyle.secondary,
                label: 'logout'.tr,
                onPressed: controller.logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
