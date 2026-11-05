import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/trader_home_controller.dart';
import '../../../controller/trader/trader_shell_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/constant/app_routes.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/option_model.dart';
import '../../../data/model/order_model.dart';
import '../../widget/trader/product_card.dart';
import '../../widget/trader/trader_parts.dart';
import '../../../core/shared/notification_bell.dart';
import '../../../data/model/user_model.dart';

/// B1 — الرئيسية.
/// من الأعلى: التحية والإشعارات، حقل البحث، الطلب المفتوح (إن وجد)، التصنيفات، وصل حديثاً.
class TraderHomeScreen extends StatelessWidget {
  const TraderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<TraderShellController>();
    return GetBuilder<TraderHomeController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.greetingKey.tr,
                  style: const TextStyle(fontSize: 14, color: AppColor.textSecondary, fontWeight: FontWeight.w500)),
              Text('homeHeadline'.tr),
            ],
          ),
          actions: [
            const NotificationBell(role: UserRole.trader),
            const SizedBox(width: 8),
          ],
        ),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => RefreshIndicator(
              onRefresh: c.load,
              color: AppColor.ink,
              child: MaxWidth(
                maxWidth: AppLayout.contentMaxWidth,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      sliver: SliverList.list(
                        children: [
                          _SearchEntry(onTap: shell.openSearch),
                          if (c.activePurchase case final p?) ...[
                            const SizedBox(height: 16),
                            _ActiveOrderCard(purchase: p),
                          ],
                          const SizedBox(height: 12),
                          SectionHeader(title: 'categories'.tr),
                          _Categories(categories: c.categories),
                          const SizedBox(height: 12),
                          SectionHeader(
                            title: 'newArrivals'.tr,
                            action: 'viewAll'.tr,
                            onAction: shell.openSearch,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: ProductSliverGrid(products: c.newest),
                    ),
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

/// يبدو كحقل بحث، والضغط عليه ينقل لتبويب البحث.
class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'searchHint'.tr,
      child: Material(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.border, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColor.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: ExcludeSemantics(
                    child: Text('searchHint'.tr,
                        style: const TextStyle(color: AppColor.textSecondary, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// اختصار لآخر طلب مفتوح: رقمه، حالته، وعدد الموردين.
class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final p = purchase;
    return Material(
      color: AppColor.ink,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed(AppRoute.purchase, arguments: p.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('activeOrder'.tr,
                        style: const TextStyle(color: AppColor.textOnInkSecondary, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      'purchaseNo'.trParams({'n': p.id}),
                      style: const TextStyle(color: AppColor.surface, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'suppliersCount'.trParams({'n': '${p.subOrders.length}'})} · ${formatDate(p.createdAt)}',
                      style: const TextStyle(color: AppColor.textOnInkSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PurchaseStatusChip(status: p.status),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColor.textOnInkSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// التصنيفات: بطاقات متساوية تلتف حسب عرض الشاشة.
class _Categories extends StatelessWidget {
  const _Categories({required this.categories});

  final List<OptionModel> categories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // عمودان على الهاتف، أربعة على الشاشات الأعرض.
        final columns = box.maxWidth >= 560 ? 4 : 2;
        final width = (box.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final cat in categories)
              SizedBox(
                width: width,
                child: Material(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Get.toNamed(AppRoute.categoryProducts, arguments: cat),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColor.orangeSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(categoryIcon(cat.id), color: AppColor.orangeDeep, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(cat.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
