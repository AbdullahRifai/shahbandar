import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/supplier/supplier_orders_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../widget/supplier/supplier_parts.dart';

/// C2 — الطلبات الواردة: شرائح الحالات مع أعدادها، ثم القائمة.
/// في "بانتظار قرارك" الأقدم أولاً، ومدة الانتظار ملوّنة حسب طولها.
class SupplierOrdersScreen extends StatelessWidget {
  const SupplierOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SupplierOrdersController>(
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('incomingOrders'.tr)),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
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
                    ..._list(c),
                  ],
                ),
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }

  List<Widget> _list(SupplierOrdersController c) {
    final items = c.visible;
    if (items.isEmpty) {
      return [
        // ارتفاع ثابت: EmptyView قابل للتمرير، ولا يوضع داخل قائمة بلا حدود.
        SizedBox(
          height: 380,
          child: EmptyView(
            icon: c.filter == SupplierOrdersFilter.awaiting ? Icons.inbox_outlined : Icons.assignment_outlined,
            title: c.filter == SupplierOrdersFilter.awaiting ? 'noAwaitingTitle'.tr : 'noOrdersInFilter'.tr,
            message: c.filter == SupplierOrdersFilter.awaiting ? 'noAwaitingBody'.tr : null,
          ),
        ),
      ];
    }
    final awaiting = c.filter == SupplierOrdersFilter.awaiting;
    return [
      if (awaiting)
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
          child: Text('oldestFirst'.tr, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
        ),
      RowsCard(children: [
        for (final o in items) IncomingOrderRow(order: o, showAge: awaiting, onTap: () => c.open(o)),
      ]),
      if (awaiting)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
          child: Text('ageHint'.tr, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColor.textSecondary)),
        ),
    ];
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.c});

  final SupplierOrdersController c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in SupplierOrdersFilter.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _FilterChip(
                label: 'sof_${f.name}'.tr,
                count: c.countOf(f),
                selected: c.filter == f,
                highlightCount: f == SupplierOrdersFilter.awaiting,
                onTap: () => c.setFilter(f),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.highlightCount = false,
  });

  final String label;
  final int count;
  final bool selected;
  final bool highlightCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColor.ink : AppColor.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? AppColor.ink : AppColor.border, width: 1.5)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColor.surface : AppColor.ink,
                    )),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  highlightCount
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: AppColor.orange, borderRadius: BorderRadius.circular(10)),
                          child: Text('$count',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.ink)),
                        )
                      : Text('$count',
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? AppColor.textOnInkSecondary : AppColor.textSecondary,
                          )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
