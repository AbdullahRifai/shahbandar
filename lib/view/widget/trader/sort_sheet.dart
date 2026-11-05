import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_select_field.dart';
import '../../../data/model/product_filter.dart';

/// B4 — الترتيب: نافذة سفلية بأربعة خيارات، والاختيار يطبَّق فوراً ويغلقها.
Future<ProductSort?> showSortSheet(ProductSort current) {
  return Get.bottomSheet<ProductSort>(
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Handle(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text('sortTitle'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            for (final sort in ProductSort.values)
              OptionTile(
                label: 'sort_${sort.name}'.tr,
                selected: sort == current,
                onTap: () => Get.back(result: sort),
              ),
          ],
        ),
      ),
    ),
    backgroundColor: AppColor.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: AppColor.border, borderRadius: BorderRadius.circular(2)),
        ),
      );
}
