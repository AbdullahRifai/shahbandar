import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../data/model/incoming_order_model.dart';

enum AcceptFailedChoice { updateStock, reject }

/// C5 — تعذّر قبول الطلب لأن المخزون لا يكفي.
/// يطمئن المورد أن شيئاً لم يُخصم، ويعرض الحلّين: تحديث المخزون أو الرفض.
Future<AcceptFailedChoice?> showAcceptFailedDialog(String orderId, List<StockShortage> shortages) {
  return Get.dialog<AcceptFailedChoice>(
    AlertDialog(
      backgroundColor: AppColor.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      icon: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(color: AppColor.warningSoft, shape: BoxShape.circle),
        child: const Icon(Icons.warning_amber_rounded, color: AppColor.warning),
      ),
      title: Text(
        'acceptFailedTitle'.trParams({'n': orderId}),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'acceptFailedBody'.trParams({'n': '${shortages.length}'}),
              style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary),
            ),
            const SizedBox(height: 16),
            for (final s in shortages)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: formatCount(s.available),
                          style: const TextStyle(color: AppColor.danger, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' ${'availableOfRequested'.trParams({'n': formatCount(s.requested)})}'),
                      ]),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: 'updateStock'.tr,
              onPressed: () => Get.back(result: AcceptFailedChoice.updateStock),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Get.back(result: AcceptFailedChoice.reject),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.danger,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text('rejectOrder'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    ),
  );
}
