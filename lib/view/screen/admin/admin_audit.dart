import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_section_controllers.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/admin_models.dart';
import '../../widget/admin/admin_chips.dart';
import '../../widget/admin/admin_parts.dart';
import '../../widget/admin/admin_table.dart';
import 'admin_dashboard.dart';

/// E10 — سجل التدقيق (FR-69): للقراءة فقط.
/// بحث بالمنفّذ أو الكيان، فلتر نوع العملية، وفترة زمنية.
class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminAuditController>(
      init: AdminAuditController(),
      global: false,
      builder: (c) => switch (c.status) {
        StatusRequest.failure => ErrorView(onRetry: c.load),
        StatusRequest.success => AdminPage(
            onRefresh: c.load,
            children: [
              Row(
                children: [
                  Expanded(child: AdminPageHeader(title: 'as_audit'.tr)),
                  AdminChip(label: 'adminReadOnly'.tr, fg: AppColor.textNote, bg: AppColor.neutralSoft),
                ],
              ),
              FilterBar(children: [
                AdminSearchField(hint: 'adminAuditSearch'.tr, onChanged: c.search),
                FilterPill(label: 'adminAllActions'.tr, selected: c.type == null, onTap: () => c.setType(null)),
                for (final t in AuditType.values)
                  FilterPill(label: 'aut_${t.name}'.tr, selected: c.type == t, onTap: () => c.setType(t)),
                const SizedBox(width: 8),
                for (final p in AuditPeriod.values)
                  FilterPill(label: 'aup_${p.name}'.tr, selected: c.period == p, onTap: () => c.setPeriod(p)),
              ]),
              AuditTable(entries: c.filtered),
              Text('adminAuditNote'.tr, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColor.textSecondary)),
            ],
          ),
        _ => const LoadingView(),
      },
    );
  }
}

/// جدول السجل، مشترك مع المؤشرات (E2).
class AuditTable extends StatelessWidget {
  const AuditTable({super.key, required this.entries});

  final List<AuditEntry> entries;

  @override
  Widget build(BuildContext context) {
    return AdminTable(
      columns: AuditTableColumns.columns,
      emptyText: 'adminNoResults'.tr,
      rows: [
        for (final e in entries)
          [
            Text(shortDateTime(e.at), style: const TextStyle(fontSize: 14)),
            e.actor == 'system'
                ? Text('adminSystem'.tr, style: const TextStyle(fontSize: 14))
                : LtrText(e.actor, style: const TextStyle(fontSize: 14)),
            Text(e.actionKey.tr, style: const TextStyle(fontSize: 14)),
            e.entity.contains('@')
                ? LtrText(e.entity, style: const TextStyle(fontSize: 14))
                : Text(e.entity.startsWith('au_') ? e.entity.tr : e.entity, style: const TextStyle(fontSize: 14)),
            auditResult(e),
          ],
      ],
    );
  }
}
