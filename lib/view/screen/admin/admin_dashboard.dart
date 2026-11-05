import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_section_controllers.dart';
import '../../../controller/admin/admin_shell_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/state_views.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/admin_models.dart';
import '../../../data/model/order_model.dart';
import '../../widget/admin/admin_chips.dart';
import '../../widget/admin/admin_parts.dart';
import '../../widget/admin/admin_table.dart';
import 'admin_audit.dart';

/// E2 — المؤشرات: ثلاث بطاقات أرقام، توزيع الطلبات على الحالات، وأحدث الأحداث.
/// كل بطاقة تفتح قسمها.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<AdminShellController>();
    return GetBuilder<AdminDashboardController>(
      init: AdminDashboardController(),
      global: false,
      builder: (c) => switch (c.status) {
        StatusRequest.failure => ErrorView(onRetry: c.load),
        StatusRequest.success => AdminPage(
            onRefresh: c.load,
            children: [
              AdminPageHeader(
                title: 'as_dashboard'.tr,
                trailing: 'adminUpdatedAt'.trParams({'t': shortDateTime(c.stats!.updatedAt)}),
              ),
              _Kpis(s: c.stats!, shell: shell),
              _OrdersBar(s: c.stats!, onTap: () => shell.go(AdminSection.orders)),
              Row(
                children: [
                  Expanded(
                    child: Text('adminRecentEvents'.tr,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () => shell.go(AdminSection.audit),
                    style: TextButton.styleFrom(foregroundColor: AppColor.orangeDeep, minimumSize: const Size(48, 44)),
                    child: Text('adminFullAudit'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              AuditTable(entries: c.recent),
            ],
          ),
        _ => const LoadingView(),
      },
    );
  }
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.s, required this.shell});

  final AdminStats s;
  final AdminShellController shell;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'adminKpiUsers'.tr,
        '${s.users}',
        'adminKpiUsersSub'.trParams({'t': '${s.traders}', 's': '${s.suppliers}', 'b': '${s.both}'}),
        AdminSection.users,
      ),
      (
        'adminKpiProducts'.tr,
        '${s.products}',
        'adminKpiProductsSub'.trParams({'a': '${s.activeProducts}', 'h': '${s.hiddenProducts}'}),
        AdminSection.products,
      ),
      (
        'adminKpiDeletions'.tr,
        '${s.pendingDeletions}',
        'adminKpiDeletionsSub'.trParams({'n': '${s.disabledUsers}'}),
        AdminSection.deletions,
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 720 ? 3 : (box.maxWidth >= 460 ? 2 : 1);
        final w = (box.maxWidth - (cols - 1) * 16) / cols;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (label, value, sub, target) in cards)
              SizedBox(
                width: w,
                child: Material(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => shell.go(target),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
                          const SizedBox(height: 4),
                          Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, height: 1.25)),
                          const SizedBox(height: 4),
                          Text(sub, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
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

/// شريط أفقي مقسّم بنسبة كل حالة، مع مفتاح ألوان بالأرقام (المعنى لا يعتمد على اللون وحده).
class _OrdersBar extends StatelessWidget {
  const _OrdersBar({required this.s, required this.onTap});

  final AdminStats s;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final entries = SubOrderStatus.values.where((st) => (s.ordersByStatus[st] ?? 0) > 0).toList();
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('adminOrdersByStatus'.tr,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  Text('adminOrdersCount'.trParams({'n': '${s.orders}'}),
                      style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'adminOrdersCount'.trParams({'n': '${s.orders}'}),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 16,
                    child: Row(
                      children: [
                        for (var i = 0; i < entries.length; i++) ...[
                          if (i > 0) const SizedBox(width: 2),
                          Expanded(
                            flex: s.ordersByStatus[entries[i]]!,
                            child: ColoredBox(color: subOrderStyle(entries[i]).$1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 10,
                children: [
                  for (final st in SubOrderStatus.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: subOrderStyle(st).$1, borderRadius: BorderRadius.circular(3)),
                        ),
                        const SizedBox(width: 8),
                        Text('ast_${st.name}'.tr, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text('${s.ordersByStatus[st] ?? 0}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// يُستخدم هنا وفي سجل التدقيق.
class AuditTableColumns {
  static List<AdminColumn> get columns => [
        AdminColumn('adminColTime'.tr, flex: 2),
        AdminColumn('adminColActor'.tr, flex: 3),
        AdminColumn('adminColAction'.tr, flex: 3),
        AdminColumn('adminColEntity'.tr, flex: 3),
        AdminColumn('adminColResult'.tr, flex: 2),
      ];
}

/// نتيجة العملية بلون وأيقونة.
Widget auditResult(AuditEntry e) {
  final (color, key) = switch (e.result) {
    AuditResult.ok => (AppColor.success, 'au_ok'),
    AuditResult.failed => (AppColor.danger, 'au_failed'),
    AuditResult.blocked => (AppColor.danger, 'au_blockedShort'),
  };
  return Text((e.resultKey ?? key).tr, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14));
}
