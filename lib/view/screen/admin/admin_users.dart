import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_section_controllers.dart';
import '../../../controller/admin/admin_shell_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/admin_models.dart';
import '../../widget/admin/admin_chips.dart';
import '../../widget/admin/admin_parts.dart';
import '../../widget/admin/admin_table.dart';

/// E3 — المستخدمون: بحث، فلتر الدور والحالة، جدول بصفحات.
/// الضغط على صف يفتح E4 داخل نفس القسم.
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<AdminShellController>();
    return GetBuilder<AdminUsersController>(
      init: AdminUsersController(),
      global: false,
      builder: (c) {
        if (c.status == StatusRequest.failure) return ErrorView(onRetry: c.load);
        if (c.status != StatusRequest.success) return const LoadingView();
        final list = c.filtered;
        final pageItems = c.pageItems;
        final from = list.isEmpty ? 0 : c.page * AdminUsersController.pageSize + 1;
        final to = c.page * AdminUsersController.pageSize + pageItems.length;
        return AdminPage(
          onRefresh: c.load,
          children: [
            AdminPageHeader(title: 'as_users'.tr, trailing: 'adminAccountsCount'.trParams({'n': '${c.items.length}'})),
            FilterBar(children: [
              AdminSearchField(hint: 'adminUsersSearch'.tr, onChanged: c.search),
              for (final r in UserRoleFilter.values)
                FilterPill(label: 'arf_${r.name}'.tr, selected: c.role == r, onTap: () => c.setRole(r)),
              const SizedBox(width: 8),
              for (final s in UserStatusFilter.values.skip(1))
                FilterPill(label: 'asf_${s.name}'.tr, selected: c.state == s, onTap: () => c.setStatusFilter(s)),
            ]),
            AdminTable(
              columns: [
                AdminColumn('adminColNameBiz'.tr, flex: 4),
                AdminColumn('email'.tr, flex: 4),
                AdminColumn('adminColRoles'.tr, flex: 2),
                AdminColumn('adminColStatus'.tr, flex: 2),
                AdminColumn('adminColJoined'.tr, flex: 2),
              ],
              emptyText: 'adminNoResults'.tr,
              onTap: (i) => shell.openUser(pageItems[i].id),
              rows: [
                for (final u in pageItems)
                  [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(u.businessName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                      ],
                    ),
                    LtrText(u.email, style: const TextStyle(fontSize: 14)),
                    Text(rolesLabel(u.roles), style: const TextStyle(fontSize: 14)),
                    UserStatusChip(user: u),
                    Text(shortDate(u.joinedAt), style: const TextStyle(fontSize: 14)),
                  ],
              ],
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('adminRange'.trParams({'from': '$from', 'to': '$to', 'n': '${list.length}'}),
                    style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 110,
                      child: AppButton(
                        label: 'adminPrev'.tr,
                        style: AppButtonStyle.secondary,
                        onPressed: c.page > 0 ? c.previous : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: AppButton(
                        label: 'adminNext'.tr,
                        style: AppButtonStyle.secondary,
                        onPressed: c.page < c.pageCount - 1 ? c.next : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// E4 — تفاصيل مستخدم: الحساب، الملف التجاري، آخر النشاط،
/// ولوحة الإيقاف (أو إعادة التفعيل) بإطار أحمر وسبب داخلي اختياري.
class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<AdminShellController>();
    return GetBuilder<AdminUserController>(
      init: AdminUserController(userId),
      global: false,
      builder: (c) {
        if (c.status == StatusRequest.failure) return ErrorView(onRetry: c.load);
        if (c.status != StatusRequest.success) return const LoadingView();
        final u = c.user!;
        return AdminPage(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: shell.closeUser,
                  style: TextButton.styleFrom(foregroundColor: AppColor.orangeDeep, minimumSize: const Size(48, 40)),
                  child: Text('as_users'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(' / ${u.name}', style: const TextStyle(color: AppColor.textSecondary, fontSize: 14)),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColor.ink, borderRadius: BorderRadius.circular(16)),
                  child: Text(u.initial,
                      style: const TextStyle(color: AppColor.orangeOnInk, fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                      Text('${u.businessName} · ${rolesLabel(u.roles)}',
                          style: const TextStyle(fontSize: 15, color: AppColor.textSecondary)),
                    ],
                  ),
                ),
                UserStatusChip(user: u),
              ],
            ),
            TableWithPanel(
              table: Column(
                children: [
                  AdminBox(
                    title: 'adminAccountSection'.tr,
                    child: KeyValueList(items: [
                      ('email'.tr, LtrText(u.email)),
                      (
                        'adminEmailVerified'.tr,
                        Text(u.emailVerifiedAt == null
                            ? 'adminNo'.tr
                            : 'adminYesOn'.trParams({'d': shortDate(u.emailVerifiedAt!)}))
                      ),
                      ('adminColRoles'.tr, Text(rolesLabel(u.roles))),
                      ('adminLastLogin'.tr, Text(u.lastLoginAt == null ? '—' : shortDateTime(u.lastLoginAt!))),
                      ('adminColJoined'.tr, Text(shortDate(u.joinedAt))),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  AdminBox(
                    title: 'businessProfileTitle'.tr,
                    child: KeyValueList(items: [
                      ('businessCategory'.tr, Text(u.businessType)),
                      ('city'.tr, Text(u.city)),
                      ('phone'.tr, LtrText(u.phone)),
                      (
                        'adminOrders'.tr,
                        Text('adminOrdersSummary'.trParams({'p': '${u.purchases}', 'o': '${u.openOrders}'}))
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  AdminBox(
                    title: 'adminRecentActivity'.tr,
                    child: Column(
                      children: [
                        for (final (text, at) in u.recent)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColor.divider))),
                            child: Row(
                              children: [
                                Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
                                Text(shortDateTime(at),
                                    style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              panel: _StatusPanel(c: c, u: u),
            ),
          ],
        );
      },
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.c, required this.u});

  final AdminUserController c;
  final AdminUser u;

  @override
  Widget build(BuildContext context) {
    final disabled = u.status == AdminUserStatus.disabled;
    return AdminBox(
      border: disabled ? AppColor.success : AppColor.danger,
      title: disabled ? 'adminEnableTitle'.tr : 'adminDisableTitle'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(disabled ? 'adminEnableHint'.tr : 'adminDisableHint'.tr,
              style: const TextStyle(fontSize: 14, height: 1.6, color: AppColor.textSecondary)),
          const SizedBox(height: 14),
          if (disabled && u.disableReason.isNotEmpty) ...[
            Text('adminInternalReason'.tr, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
            const SizedBox(height: 4),
            Text(u.disableReason, style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 14),
          ],
          if (!disabled) ...[
            Text.rich(
              TextSpan(children: [
                TextSpan(text: 'adminInternalReason'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: ' ${'adminReasonPrivate'.tr}', style: const TextStyle(color: AppColor.textSecondary)),
              ]),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: c.reason,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColor.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColor.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColor.ink, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          AppButton(
            label: disabled ? 'adminConfirmEnable'.tr : 'adminConfirmDisable'.tr,
            style: disabled ? AppButtonStyle.primary : AppButtonStyle.danger,
            isLoading: c.busy,
            onPressed: c.toggleStatus,
          ),
          const SizedBox(height: 8),
          Text('adminLoggedNote'.tr, style: const TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        ],
      ),
    );
  }
}
