import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_shell_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../data/model/admin_models.dart';
import '../../widget/admin/admin_brand.dart';
import 'admin_audit.dart';
import 'admin_categories.dart';
import 'admin_dashboard.dart';
import 'admin_deletion.dart';
import 'admin_orders.dart';
import 'admin_products.dart';
import 'admin_users.dart';

/// هيكل لوحة الإدارة: شريط جانبي كحلي ثابت والمحتوى بجانبه (E2 إلى E10).
/// على الشاشات الضيقة يصبح الشريط قائمة منزلقة من زر في الأعلى.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  static const double wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminShellController>(
      builder: (c) {
        // المفتاح يجعل كل قسم يُنشأ من جديد عند فتحه، فيحمّل بيانات حديثة.
        final content = KeyedSubtree(
          key: ValueKey('${c.section}-${c.openUserId}'),
          child: _section(c),
        );
        return LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth >= wideBreakpoint) {
              return Scaffold(
                body: Row(
                  children: [
                    SizedBox(width: 248, child: _Sidebar(c: c)),
                    Expanded(child: content),
                  ],
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColor.ink,
                foregroundColor: AppColor.surface,
                title: Text('as_${c.section.name}'.tr, style: const TextStyle(color: AppColor.surface)),
              ),
              drawer: Drawer(
                backgroundColor: AppColor.ink,
                width: 280,
                child: _Sidebar(c: c, closeOnTap: true),
              ),
              body: content,
            );
          },
        );
      },
    );
  }

  Widget _section(AdminShellController c) => switch (c.section) {
        AdminSection.dashboard => const AdminDashboardScreen(),
        AdminSection.users =>
          c.openUserId == null ? const AdminUsersScreen() : AdminUserDetailScreen(userId: c.openUserId!),
        AdminSection.products => const AdminProductsScreen(),
        AdminSection.orders => const AdminOrdersScreen(),
        AdminSection.productCategories => const AdminCategoriesScreen(kind: CategoryKind.product),
        AdminSection.bizCategories => const AdminCategoriesScreen(kind: CategoryKind.business),
        AdminSection.deletions => const AdminDeletionScreen(),
        AdminSection.audit => const AdminAuditScreen(),
      };
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.c, this.closeOnTap = false});

  final AdminShellController c;
  final bool closeOnTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.ink,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 24, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, bottom: 20),
                child: AdminBrand(label: 'adminSidebarTitle'.tr),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final s in AdminSection.values)
                      _NavItem(
                        label: 'as_${s.name}'.tr,
                        selected: c.section == s,
                        badge: s == AdminSection.deletions ? c.pendingDeletions : 0,
                        onTap: () {
                          if (closeOnTap) Navigator.of(context).pop();
                          c.go(s);
                        },
                      ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF26303F)),
              if (c.email.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(c.email,
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColor.textOnInkSecondary, fontSize: 13)),
                ),
              _NavItem(label: 'adminLanguageToggle'.tr, icon: Icons.language_rounded, onTap: c.toggleLanguage),
              _NavItem(label: 'logout'.tr, icon: Icons.logout_rounded, onTap: c.logout),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.onTap, this.selected = false, this.badge = 0, this.icon});

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final int badge;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? const Color(0xFF26303F) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // شريط برتقالي على جهة البداية للقسم الحالي.
                border: BorderDirectional(
                  start: BorderSide(color: selected ? AppColor.orange : Colors.transparent, width: 3),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppColor.textOnInkSecondary),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? AppColor.surface : const Color(0xFFC9D0DB),
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (badge > 0)
                    Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColor.orange, borderRadius: BorderRadius.circular(11)),
                      child: Text('$badge',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.ink)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
