import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../data/model/user_model.dart';

/// D4 — تفعيل دور على نفس الحساب (FR-10).
/// يشرح ما سيحصل، ويطمئن أن الطلبات الحالية تبقى، وأن التفعيل لا يمنح صلاحيات إدارية.
/// يرجع true عند "تفعيل".
Future<bool> showActivateRoleSheet(UserRole role) async {
  final supplier = role == UserRole.supplier;
  final points = supplier
      ? ['arSupplierPoint1', 'arSupplierPoint2', 'arSwitchPoint']
      : ['arTraderPoint1', 'arTraderPoint2', 'arSwitchPoint'];

  final result = await Get.bottomSheet<bool>(
    SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColor.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColor.orangeSoft, borderRadius: BorderRadius.circular(16)),
                child: Icon(supplier ? Icons.storefront_outlined : Icons.shopping_basket_outlined,
                    color: AppColor.orangeDeep, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(supplier ? 'startSelling'.tr : 'startBuying'.tr,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 4),
            Text(supplier ? 'arSupplierBody'.tr : 'arTraderBody'.tr,
                style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary)),
            const SizedBox(height: 18),
            for (final p in points)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_rounded, color: AppColor.success, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Text(p.tr, style: const TextStyle(fontSize: 15, height: 1.5))),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(14)),
              child: Text('arNote'.tr, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColor.textNote)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'notNow'.tr,
                    style: AppButtonStyle.secondary,
                    onPressed: () => Get.back(result: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: supplier ? 'activateSupplier'.tr : 'activateTrader'.tr,
                    onPressed: () => Get.back(result: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    backgroundColor: AppColor.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  );
  return result ?? false;
}
