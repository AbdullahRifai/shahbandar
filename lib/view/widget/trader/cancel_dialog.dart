import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';

/// B16 — تأكيد إلغاء طلب فرعي (FR-50).
/// يوضّح أن الإلغاء يخص هذا المورد فقط، وأنه لا يُعكس.
/// يرجع true عند التأكيد.
Future<bool> showCancelDialog(String supplierName) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: AppColor.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(color: AppColor.dangerSoft, shape: BoxShape.circle),
        child: const Icon(Icons.do_not_disturb_on_outlined, color: AppColor.danger, size: 28),
      ),
      title: Text(
        'cancelTitle'.tr,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Text(
          'cancelBody'.trParams({'s': supplierName}),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: 'cancelConfirm'.tr,
              style: AppButtonStyle.danger,
              onPressed: () => Get.back(result: true),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'cancelKeep'.tr,
              style: AppButtonStyle.secondary,
              onPressed: () => Get.back(result: false),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}
