import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_routes.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/services/compare_service.dart';
import '../../../core/shared/info_note.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/product_model.dart';
import '../../widget/trader/product_thumb.dart';

/// B8 — المقارنة (FR-31): أعمدة بعرض ثابت، والصفوف متطابقة (السعر، المورد، المدينة،
/// المخزون، الحد الأدنى). تمرير أفقي على الهاتف حين لا تتسع الأعمدة.
/// شارة "الأقل سعراً" فقط حين تكون كل المنتجات بعملة واحدة.
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  static const double _col = 168;
  static const double _labelCol = 96;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompareService>(
      builder: (cmp) => Scaffold(
        appBar: AppBar(
          title: Text('compareTitle'.tr),
          actions: [
            if (cmp.items.isNotEmpty)
              TextButton(
                onPressed: cmp.clear,
                style: TextButton.styleFrom(foregroundColor: AppColor.orangeDeep, minimumSize: const Size(48, 48)),
                child: Text('clearAll'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: cmp.items.length < 2
            ? EmptyView(
                icon: Icons.compare_arrows_rounded,
                title: 'compareNeedTwo'.tr,
                message: 'compareNeedTwoHint'.tr,
                actionLabel: 'back'.tr,
                onAction: () => Get.back(),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  if (cmp.mixedCurrencies) ...[
                    InfoNote(text: 'compareMixedCurrency'.tr),
                    const SizedBox(height: 12),
                  ],
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _Table(cmp: cmp),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.cmp});

  final CompareService cmp;

  @override
  Widget build(BuildContext context) {
    final items = cmp.items;
    final cheapest = cmp.cheapestId;

    Widget row(String label, Widget Function(ProductModel p) cell, {bool shaded = false}) => Container(
          color: shaded ? AppColor.surface : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: CompareScreen._labelCol,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(label, style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                ),
              ),
              for (final p in items)
                SizedBox(width: CompareScreen._col, child: Padding(padding: const EdgeInsets.all(10), child: cell(p))),
            ],
          ),
        );

    const value = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // رأس الأعمدة: الصورة والاسم وزر الإزالة.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: CompareScreen._labelCol),
            for (final p in items)
              SizedBox(
                width: CompareScreen._col,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          InkWell(
                            onTap: () => Get.toNamed(AppRoute.product, arguments: p.id),
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(aspectRatio: 1.2, child: ProductThumb(visual: p.visual, imageUrl: p.coverImage)),
                          ),
                          PositionedDirectional(
                            top: 0,
                            end: 0,
                            child: IconButton(
                              onPressed: () => cmp.remove(p.id),
                              tooltip: 'removeFromCompare'.tr,
                              icon: const Icon(Icons.close_rounded, size: 18),
                              style: IconButton.styleFrom(backgroundColor: AppColor.surface),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        row('price'.tr, shaded: true, (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatMoney(p.price, p.currency), style: value.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                if (p.id == cheapest)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColor.successSoft, borderRadius: BorderRadius.circular(8)),
                    child: Text('cheapest'.tr,
                        style: const TextStyle(color: AppColor.success, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
              ],
            )),
        row('supplier'.tr, (p) => Text(p.supplierName, style: value)),
        row('city'.tr, shaded: true, (p) => Text(p.supplierCity, style: value)),
        row('stock'.tr, (p) => Text(
              p.inStock ? formatCount(p.stock) : 'outOfStock'.tr,
              style: value.copyWith(color: p.inStock ? AppColor.ink : AppColor.dangerText),
            )),
        row('moq'.tr, shaded: true, (p) => Text(formatCount(p.moq), style: value)),
      ],
    );
  }
}
