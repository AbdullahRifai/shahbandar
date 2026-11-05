import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_section_controllers.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/admin_models.dart';
import '../../../data/model/order_model.dart';
import '../../widget/admin/admin_chips.dart';
import '../../widget/admin/admin_parts.dart';
import '../../widget/admin/admin_table.dart';

/// E6 — مراجعة الطلبات (FR-65): جدول الطلبات الفرعية، وبجانبه مراحل الطلب المحدد وأصنافه.
/// للعرض فقط: الإدارة لا تغيّر حالة الطلب.
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminOrdersController>(
      init: AdminOrdersController(),
      global: false,
      builder: (c) {
        if (c.status == StatusRequest.failure) return ErrorView(onRetry: c.load);
        if (c.status != StatusRequest.success) return const LoadingView();
        final list = c.filtered;
        return AdminPage(
          onRefresh: c.load,
          children: [
            AdminPageHeader(title: 'as_orders'.tr, trailing: 'adminSubOrdersCount'.trParams({'n': '${c.items.length}'})),
            FilterBar(children: [
              AdminSearchField(hint: 'adminOrdersSearch'.tr, onChanged: c.search),
              for (final f in AdminOrderFilter.values)
                FilterPill(label: 'aof_${f.name}'.tr, selected: c.filter == f, onTap: () => c.setFilter(f)),
            ]),
            TableWithPanel(
              table: AdminTable(
                columns: [
                  AdminColumn('adminColOrder'.tr, flex: 2),
                  AdminColumn('role_trader'.tr, flex: 3),
                  AdminColumn('supplier'.tr, flex: 3),
                  AdminColumn('adminColAmount'.tr, flex: 3, end: true),
                  AdminColumn('adminColStatus'.tr, flex: 3),
                  AdminColumn('adminColDate'.tr, flex: 2),
                ],
                emptyText: 'adminNoResults'.tr,
                selected: list.indexWhere((o) => o.id == c.selectedId),
                onTap: (i) => c.select(list[i].id),
                rows: [
                  for (final o in list)
                    [
                      Text('#${o.id}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(o.trader, style: const TextStyle(fontSize: 14)),
                      Text(o.supplier, style: const TextStyle(fontSize: 14)),
                      Text(formatMoney(o.total, o.currency),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      OrderStatusChip(status: o.status),
                      Text(shortDate(o.createdAt), style: const TextStyle(fontSize: 14)),
                    ],
                ],
              ),
              panel: c.selected == null ? null : _Panel(o: c.selected!),
            ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.o});

  final AdminOrder o;

  @override
  Widget build(BuildContext context) {
    final closed = o.status == SubOrderStatus.rejected || o.status == SubOrderStatus.cancelled;
    final steps = closed
        ? [SubOrderStatus.awaiting, o.status]
        : const [SubOrderStatus.awaiting, SubOrderStatus.accepted, SubOrderStatus.preparing, SubOrderStatus.completed];
    return AdminBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('#${o.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('adminInPurchase'.trParams({'p': o.purchaseId, 'n': '${o.purchaseSize}'}),
              style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
          const SizedBox(height: 14),
          for (final s in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: o.timeline.containsKey(s) ? AppColor.ink : null,
                      border: o.timeline.containsKey(s) ? null : Border.all(color: AppColor.border, width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('aot_${s.name}'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: o.timeline.containsKey(s) ? AppColor.ink : AppColor.textSecondary,
                        )),
                  ),
                  if (o.timeline[s] != null)
                    Text(shortDateTime(o.timeline[s]!),
                        style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                ],
              ),
            ),
          const Divider(height: 20, color: AppColor.divider),
          for (final l in o.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: Text(l.name, style: const TextStyle(fontSize: 14))),
                  Text('${formatCount(l.quantity)} × ${formatMoney(l.unitPrice, o.currency)}',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text('adminOrdersReadOnly'.tr,
              style: const TextStyle(fontSize: 13, height: 1.5, color: AppColor.textSecondary)),
        ],
      ),
    );
  }
}
