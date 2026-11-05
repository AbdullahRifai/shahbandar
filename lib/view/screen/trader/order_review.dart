import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/cart_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/info_note.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/order_slip.dart';
import '../../../data/model/cart_item_model.dart';
import '../../widget/trader/trader_parts.dart';

/// B11 — مراجعة الطلب قبل الإرسال.
/// قراءة فقط: قسيمة لكل مورد بأصنافها، المجاميع لكل عملة، وتنبيه أن كل مورد يقرر وحده.
/// التعديل يكون بالرجوع للسلة.
class OrderReviewScreen extends StatelessWidget {
  const OrderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (c) {
        final groups = c.cart.bySupplier.values.toList();
        return PopScope(
          canPop: !c.placing, // لا رجوع أثناء الإرسال
          child: Scaffold(
            appBar: AppBar(title: Text('reviewTitle'.tr)),
            body: MaxWidth(
              maxWidth: 640,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  InfoNote(
                    icon: Icons.call_split_rounded,
                    text: 'reviewSplit'.trParams({'n': '${groups.length}'}),
                  ),
                  const SizedBox(height: 14),
                  for (final items in groups) ...[
                    _ReviewSlip(items: items),
                    const SizedBox(height: 14),
                  ],
                  SurfaceCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('grandTotal'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              if (c.cart.totals.length > 1)
                                Text('perCurrencyNote'.tr,
                                    style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        CurrencyTotals(totals: c.cart.totals, large: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('reviewPayment'.tr,
                      style: const TextStyle(color: AppColor.textSecondary, fontSize: 13.5, height: 1.6)),
                ],
              ),
            ),
            bottomNavigationBar: BottomActionBar(
              child: AppButton(
                label: 'sendOrder'.tr,
                isLoading: c.placing,
                onPressed: c.placeOrder,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReviewSlip extends StatelessWidget {
  const _ReviewSlip({required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    final first = items.first.product;
    final subtotal = items.fold<double>(0, (s, i) => s + i.total);
    return OrderSlip(
      header: Row(
        children: [
          const Icon(Icons.storefront_outlined, size: 20, color: AppColor.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(first.supplierName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(child: Text('supplierSubtotal'.tr, style: const TextStyle(color: AppColor.textSecondary))),
          Text(formatMoney(subtotal, first.currency), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
      child: Column(
        children: [
          for (final i in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.product.name, style: const TextStyle(fontSize: 14.5, height: 1.4)),
                        Text(
                          '${formatCount(i.quantity)} × ${formatMoney(i.product.price, i.product.currency)}',
                          style: const TextStyle(color: AppColor.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(formatMoney(i.total, i.product.currency),
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
