import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/supplier/supplier_home_controller.dart';
import '../../../controller/supplier/supplier_orders_controller.dart';
import '../../../controller/supplier/supplier_shell_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/incoming_order_model.dart';
import '../../../data/model/order_model.dart';
import '../../widget/supplier/supplier_parts.dart';
import '../../widget/trader/trader_parts.dart';
import '../../../core/shared/notification_bell.dart';
import '../../../data/model/user_model.dart';

/// C1 — لوحة المورد.
/// من الأعلى: الطلبات بانتظار القرار (الأهم)، الأعداد حسب الحالة، ملخص المنتجات، آخر الطلبات.
class SupplierHomeScreen extends StatelessWidget {
  const SupplierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<SupplierShellController>();
    return GetBuilder<SupplierHomeController>(
      builder: (c) {
        final d = c.dashboard;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 72,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (d != null)
                  Text(d.supplierName,
                      style: const TextStyle(fontSize: 14, color: AppColor.textSecondary, fontWeight: FontWeight.w500)),
                Text('supplierDashboard'.tr),
              ],
            ),
            actions: [
              const NotificationBell(role: UserRole.supplier),
              const SizedBox(width: 8),
            ],
          ),
          body: switch (c.status) {
            StatusRequest.failure => ErrorView(onRetry: c.load),
            StatusRequest.success => _Content(c: c, d: d!, shell: shell),
            _ => const LoadingView(),
          },
        );
      },
    );
  }
}

/// محتوى اللوحة بعد التحميل.
class _Content extends StatelessWidget {
  const _Content({required this.c, required this.d, required this.shell});

  final SupplierHomeController c;
  final SupplierDashboard d;
  final SupplierShellController shell;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: c.load,
      color: AppColor.ink,
      child: MaxWidth(
        maxWidth: AppLayout.contentMaxWidth,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _AwaitingCard(d: d, onTap: () => shell.openOrders(SupplierOrdersFilter.awaiting)),
            const SizedBox(height: 12),
            SectionHeader(title: 'ordersByStatus'.tr),
            _StatusGrid(d: d, shell: shell),
            const SizedBox(height: 16),
            _ProductsCard(d: d, onTap: shell.openProducts),
            if (d.recent.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionHeader(title: 'recentOrders'.tr),
              RowsCard(children: [
                for (final o in d.recent)
                  IncomingOrderRow(order: o, onTap: () => shell.openOrder(o.id)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

/// البطاقة الداكنة: عدد الطلبات المنتظرة وعمر أقدمها.
class _AwaitingCard extends StatelessWidget {
  const _AwaitingCard({required this.d, required this.onTap});

  final SupplierDashboard d;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = d.awaiting.length;
    return Material(
      color: count > 0 ? AppColor.ink : AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: count > 0 ? AppColor.orange : AppColor.successSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: count > 0
                    ? Text('$count',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColor.ink))
                    : const Icon(Icons.check_rounded, color: AppColor.success, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count > 0 ? 'awaitingTitle'.tr : 'noAwaitingTitle'.tr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: count > 0 ? AppColor.surface : AppColor.ink,
                      ),
                    ),
                    Text(
                      count > 0
                          ? 'awaitingOldest'.trParams({'t': formatAgo(d.awaiting.first.createdAt)})
                          : 'noAwaitingBody'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: count > 0 ? AppColor.textOnInkSecondary : AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: count > 0 ? AppColor.orangeOnInk : AppColor.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// أعداد الطلبات في أربع خانات، والضغط يفتح القائمة على تلك الحالة.
class _StatusGrid extends StatelessWidget {
  const _StatusGrid({required this.d, required this.shell});

  final SupplierDashboard d;
  final SupplierShellController shell;

  @override
  Widget build(BuildContext context) {
    final cells = [
      (SubOrderStatus.accepted, SupplierOrdersFilter.accepted),
      (SubOrderStatus.preparing, SupplierOrdersFilter.preparing),
      (SubOrderStatus.completed, SupplierOrdersFilter.completed),
      (SubOrderStatus.rejected, SupplierOrdersFilter.closed),
    ];
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(height: 40, child: VerticalDivider(width: 1, color: AppColor.divider)),
            Expanded(
              child: InkWell(
                onTap: () => shell.openOrders(cells[i].$2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        '${d.countOf(cells[i].$1)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: subOrderStyle(cells[i].$1).$1,
                        ),
                      ),
                      Text('st_${cells[i].$1.name}'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColor.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ملخص المنتجات: منشور، موقوف، نفد، مع شريط نسبة المنشور إلى الموقوف.
class _ProductsCard extends StatelessWidget {
  const _ProductsCard({required this.d, required this.onTap});

  final SupplierDashboard d;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = d.published + d.paused;
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('stabProducts'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      total == 0
                          ? 'noProductsYetShort'.tr
                          : 'productsSummary'.trParams({
                              'p': '${d.published}',
                              's': '${d.paused}',
                              'o': '${d.outOfStock}',
                            }),
                      style: const TextStyle(fontSize: 14, color: AppColor.textSecondary),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                ExcludeSemantics(
                  child: SizedBox(
                    width: 96,
                    height: 8,
                    child: Row(
                      children: [
                        if (d.published > 0)
                          Expanded(
                            flex: d.published,
                            child: Container(
                              decoration: BoxDecoration(color: AppColor.ink, borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        if (d.published > 0 && d.paused > 0) const SizedBox(width: 3),
                        if (d.paused > 0)
                          Expanded(
                            flex: d.paused,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColor.borderStrong, borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColor.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
