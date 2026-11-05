import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/orders_controller.dart';
import '../../../controller/trader/trader_shell_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/order_model.dart';
import '../../widget/trader/trader_parts.dart';

/// B14 — طلباتي: عمليات الشراء مع حالة كل مورد بنظرة واحدة.
class TraderOrdersScreen extends StatelessWidget {
  const TraderOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrdersController>(
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('tabOrders'.tr)),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success when c.purchases.isEmpty => EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'noOrders'.tr,
              message: 'noOrdersHint'.tr,
              actionLabel: 'browseProducts'.tr,
              onAction: Get.find<TraderShellController>().openSearch,
            ),
          StatusRequest.success => RefreshIndicator(
              onRefresh: c.load,
              color: AppColor.ink,
              child: MaxWidth(
                maxWidth: AppLayout.contentMaxWidth,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _Filters(c: c),
                    const SizedBox(height: 12),
                    if (c.visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Text('noOrdersInFilter'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColor.textSecondary, fontSize: 15)),
                      ),
                    for (final p in c.visible) ...[
                      _PurchaseCard(purchase: p, onTap: () => c.open(p)),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.c});

  final OrdersController c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in OrdersFilter.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text('of_${f.name}'.tr),
                selected: c.filter == f,
                onSelected: (_) => c.setFilter(f),
                showCheckmark: false,
                selectedColor: AppColor.ink,
                backgroundColor: AppColor.surface,
                side: BorderSide(color: c.filter == f ? AppColor.ink : AppColor.border, width: 1.5),
                labelStyle: TextStyle(
                  color: c.filter == f ? AppColor.surface : AppColor.ink,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
        ],
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase, required this.onTap});

  final Purchase purchase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = purchase;
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('purchaseNo'.trParams({'n': p.id}),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(formatDate(p.createdAt),
                            style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  PurchaseStatusChip(status: p.status),
                ],
              ),
              const Divider(height: 24, color: AppColor.divider),
              for (final s in p.subOrders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(s.supplierName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14.5)),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: s.status),
                    ],
                  ),
                ),
              if (p.totals.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text('total'.tr, style: const TextStyle(color: AppColor.textSecondary))),
                    CurrencyTotals(totals: p.totals),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
