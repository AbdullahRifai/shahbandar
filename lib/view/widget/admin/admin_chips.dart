import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/admin_models.dart';
import '../../../data/model/order_model.dart';
import '../../../data/model/user_model.dart';
import 'admin_parts.dart';

/// شارات الحالة في جداول الإدارة، بنفس ألوان التطبيق.

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final SubOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, _) = subOrderStyle(status);
    return AdminChip(label: 'ast_${status.name}'.tr, fg: fg, bg: bg);
  }
}

class UserStatusChip extends StatelessWidget {
  const UserStatusChip({super.key, required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    if (user.status == AdminUserStatus.disabled) {
      return AdminChip(label: 'adminDisabled'.tr, fg: AppColor.textNote, bg: AppColor.neutralSoft);
    }
    if (user.deletionRequested) {
      return AdminChip(label: 'adminDeletionRequested'.tr, fg: AppColor.warning, bg: AppColor.warningSoft);
    }
    return AdminChip(label: 'adminActive'.tr, fg: AppColor.success, bg: AppColor.successSoft);
  }
}

class ProductStatusChip extends StatelessWidget {
  const ProductStatusChip({super.key, required this.status});

  final AdminProductStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (status) {
      AdminProductStatus.published => (AppColor.success, AppColor.successSoft),
      AdminProductStatus.pausedBySupplier => (AppColor.textNote, AppColor.neutralSoft),
      AdminProductStatus.hiddenByAdmin => (AppColor.danger, AppColor.dangerSoft),
    };
    return AdminChip(label: 'aps_${status.name}'.tr, fg: fg, bg: bg);
  }
}

/// "تاجر"، "مورد"، أو "تاجر ومورد".
String rolesLabel(Set<UserRole> roles) {
  if (roles.length > 1) return 'adminBothRoles'.tr;
  return roles.contains(UserRole.supplier) ? 'role_supplier'.tr : 'role_trader'.tr;
}

/// تاريخ قصير للجداول: 29/10/2026
String shortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// وقت قصير: 31/10 22:04
String shortDateTime(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
