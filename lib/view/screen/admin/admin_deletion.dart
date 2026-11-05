import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_section_controllers.dart';
import '../../../controller/admin/admin_shell_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/admin_models.dart';
import '../../widget/admin/admin_chips.dart';
import '../../widget/admin/admin_parts.dart';
import '../../widget/admin/admin_table.dart';

/// E9 — طلبات حذف الحسابات (FR-68).
/// "موافقة وحذف" معطّلة ما دام للمستخدم طلب مفتوح، مع السبب تحت الزر.
class AdminDeletionScreen extends StatelessWidget {
  const AdminDeletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<AdminShellController>();
    return GetBuilder<AdminDeletionController>(
      init: AdminDeletionController(),
      global: false,
      builder: (c) {
        if (c.status == StatusRequest.failure) return ErrorView(onRetry: c.load);
        if (c.status != StatusRequest.success) return const LoadingView();
        final list = c.visible;
        final pending = c.tab == DeletionState.pending || c.tab == DeletionState.postponed;
        return AdminPage(
          onRefresh: c.load,
          children: [
            AdminPageHeader(title: 'as_deletions'.tr, subtitle: 'adminDeletionHint'.tr),
            FilterBar(children: [
              for (final s in DeletionState.values)
                FilterPill(
                  label: 'ads_${s.name}'.tr,
                  selected: c.tab == s,
                  count: s == DeletionState.pending ? c.countOf(s) : null,
                  onTap: () => c.setTab(s),
                ),
            ]),
            AdminTable(
              columns: [
                AdminColumn('adminColUser'.tr, flex: 4),
                AdminColumn('adminColRequestDate'.tr, flex: 2),
                AdminColumn('adminColReason'.tr, flex: 3),
                AdminColumn('adminColOpenOrders'.tr, flex: 2),
                if (pending) AdminColumn('adminColDecision'.tr, flex: 5),
              ],
              minWidth: 820,
              emptyText: 'adminNoDeletions'.tr,
              rows: [
                for (final d in list)
                  [
                    InkWell(
                      onTap: () => shell.openUser(d.userId),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.orangeDeep)),
                          Text('${d.business} · ${'role_${d.role.name}'.tr}',
                              style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                        ],
                      ),
                    ),
                    Text(shortDate(d.requestedAt), style: const TextStyle(fontSize: 14)),
                    Text(d.reason.isEmpty ? 'adminNoReason'.tr : d.reason,
                        style: TextStyle(
                            fontSize: 14, color: d.reason.isEmpty ? AppColor.textSecondary : AppColor.ink)),
                    d.openOrders.isEmpty
                        ? Text('adminNone'.tr, style: const TextStyle(fontSize: 14, color: AppColor.textSecondary))
                        : Text('${d.openOrders.length} · ${d.openOrders.map((id) => '#$id').join('، ')}',
                            style: const TextStyle(fontSize: 14, color: AppColor.warning, fontWeight: FontWeight.w600)),
                    if (pending) _Decision(c: c, d: d),
                  ],
              ],
            ),
            Text('adminDeletionNote'.tr, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColor.textSecondary)),
          ],
        );
      },
    );
  }
}

class _Decision extends StatelessWidget {
  const _Decision({required this.c, required this.d});

  final AdminDeletionController c;
  final AdminDeletion d;

  @override
  Widget build(BuildContext context) {
    final busy = c.busyId == d.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            // سبب التعطيل يظهر أيضاً كنص تحت الزر، لا في التلميح فقط.
            FilledButton(
                onPressed: d.canApprove && !busy ? () => c.approve(d) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColor.danger,
                  foregroundColor: AppColor.surface,
                  disabledBackgroundColor: AppColor.divider,
                  disabledForegroundColor: AppColor.textSecondary,
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('adminApprove'.tr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            if (d.state == DeletionState.pending)
              OutlinedButton(
                onPressed: busy ? null : () => c.postpone(d),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.ink,
                  side: const BorderSide(color: AppColor.border, width: 1.5),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('adminPostpone'.tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
          ],
        ),
        if (!d.canApprove)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('adminApproveAfter'.tr, style: const TextStyle(fontSize: 12, color: AppColor.textSecondary)),
          ),
      ],
    );
  }
}
