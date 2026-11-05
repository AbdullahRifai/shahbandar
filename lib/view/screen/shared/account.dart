import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shared/account_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/services/notification_center.dart';
import '../../../core/shared/app_image.dart';
import '../../../core/shared/language_sheet.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/user_model.dart';

/// D2 — حسابي، نفسها في لوحتي التاجر والمورد.
/// الرأس (الشعار، الاسم، البريد، الأدوار)، ثم بطاقة الدور الآخر (تفعيل أو تبديل)،
/// ثم ثلاث مجموعات: الملف والإشعارات والسجل / اللغة وكلمة المرور / الخروج،
/// وأخيراً رابط طلب الحذف بالأحمر بعيداً عن الاستخدام اليومي.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountController>(
      init: AccountController(role),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('tabAccount'.tr)),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => MaxWidth(
              child: RefreshIndicator(
                onRefresh: c.load,
                color: AppColor.ink,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _Header(c: c),
                    const SizedBox(height: 12),
                    _RoleCard(c: c),
                    const SizedBox(height: 12),
                    _Group(children: [
                      _Item(label: 'businessProfileTitle'.tr, onTap: c.openProfile),
                      GetBuilder<NotificationCenter>(
                        builder: (n) => _Item(
                          label: 'notifications'.tr,
                          value: n.unread > 0 ? 'newCount'.trParams({'n': '${n.unread}'}) : null,
                          onTap: c.openNotifications,
                        ),
                      ),
                      _Item(label: 'activityLog'.tr, onTap: c.openActivity),
                    ]),
                    const SizedBox(height: 12),
                    _Group(children: [
                      _Item(label: 'language'.tr, value: c.languageName, onTap: () => showLanguageSheet(context)),
                      _Item(label: 'changePassword'.tr, onTap: c.openChangePassword),
                    ]),
                    const SizedBox(height: 12),
                    _Group(children: [
                      _Item(label: 'logout'.tr, bold: true, chevron: false, onTap: c.logout),
                    ]),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: c.openDeleteAccount,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.danger,
                          minimumSize: const Size(48, 48),
                        ),
                        child: Text(
                          c.deletionPending ? 'deletionPendingLink'.tr : 'deleteAccount'.tr,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
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

class _Header extends StatelessWidget {
  const _Header({required this.c});

  final AccountController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ExcludeSemantics(
            // شعار النشاط إن رفعه المستخدم، وإلا أول حرف من الاسم.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox.square(
                dimension: 64,
                child: AppImage(
                  url: c.profile?.logoUrl,
                  placeholder: Container(
                    color: AppColor.ink,
                    alignment: Alignment.center,
                    child: Text(c.initial,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColor.orangeOnInk)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.displayName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, height: 1.35)),
                Text(c.email,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final r in UserRole.values.where(c.roles.contains))
                      Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: r == c.role ? AppColor.ink : AppColor.note,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'role_${r.name}'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: r == c.role ? AppColor.surface : AppColor.ink,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة برتقالية الإطار: تفعيل الدور الآخر (D4)، أو التبديل إليه إن كان مفعّلاً.
class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.c});

  final AccountController c;

  @override
  Widget build(BuildContext context) {
    final toSupplier = c.otherRole == UserRole.supplier;
    final switching = c.hasOtherRole;
    final title = switching
        ? (toSupplier ? 'switchToSupplier'.tr : 'switchToTrader'.tr)
        : (toSupplier ? 'startSelling'.tr : 'startBuying'.tr);
    final subtitle = switching
        ? (toSupplier ? 'switchToSupplierHint'.tr : 'switchToTraderHint'.tr)
        : (toSupplier ? 'activateSupplierHint'.tr : 'activateTraderHint'.tr);

    return Material(
      color: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColor.orange, width: 1.5),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: c.activating ? null : (switching ? c.switchMode : c.activateOther),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColor.orangeSoft, borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  switching
                      ? Icons.swap_horiz_rounded
                      : (toSupplier ? Icons.storefront_outlined : Icons.shopping_basket_outlined),
                  color: AppColor.orangeDeep,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                  ],
                ),
              ),
              c.activating
                  ? const SizedBox.square(
                      dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.ink))
                  : const Icon(Icons.chevron_right_rounded, color: AppColor.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColor.divider, indent: 16, endIndent: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.label, required this.onTap, this.value, this.bold = false, this.chevron = true});

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool bold;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
              ),
              if (value != null)
                Text(value!, style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
              if (chevron) ...[
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, size: 20, color: AppColor.textSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
