import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/order_model.dart';
import '../constant/app_color.dart';

/// شارة حالة الطلب الفرعي: لون + أيقونة + نص، حتى لا يعتمد المعنى على اللون وحده.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.supplierView = false});

  final SubOrderStatus status;

  /// عند المورد: "بانتظار قرارك" بدل "بانتظار الرد".
  final bool supplierView;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, icon) = subOrderStyle(status);
    final key = supplierView && status == SubOrderStatus.awaiting ? 'st_awaitingYou' : 'st_${status.name}';
    return _Chip(label: key.tr, fg: fg, bg: bg, icon: icon);
  }
}

/// شارة الحالة العامة لعملية الشراء (FR-54).
class PurchaseStatusChip extends StatelessWidget {
  const PurchaseStatusChip({super.key, required this.status});

  final PurchaseStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, icon) = switch (status) {
      PurchaseStatus.awaiting => subOrderStyle(SubOrderStatus.awaiting),
      PurchaseStatus.inProgress => (AppColor.info, AppColor.infoSoft, Icons.sync_rounded),
      PurchaseStatus.completed => subOrderStyle(SubOrderStatus.completed),
      PurchaseStatus.closed => subOrderStyle(SubOrderStatus.cancelled),
    };
    return _Chip(label: 'pst_${status.name}'.tr, fg: fg, bg: bg, icon: icon);
  }
}

/// (لون النص، الخلفية، الأيقونة) لكل حالة. يُستخدم أيضاً في متتبّع الطلب.
(Color, Color, IconData) subOrderStyle(SubOrderStatus status) => switch (status) {
      SubOrderStatus.awaiting => (AppColor.warning, AppColor.warningSoft, Icons.schedule_rounded),
      SubOrderStatus.accepted => (AppColor.info, AppColor.infoSoft, Icons.thumb_up_alt_outlined),
      SubOrderStatus.preparing =>
        (AppColor.preparing, AppColor.preparingSoft, Icons.inventory_2_outlined),
      SubOrderStatus.completed => (AppColor.success, AppColor.successSoft, Icons.check_circle_outline_rounded),
      SubOrderStatus.rejected => (AppColor.danger, AppColor.dangerSoft, Icons.block_rounded),
      SubOrderStatus.cancelled => (AppColor.textNote, AppColor.neutralSoft, Icons.do_not_disturb_on_outlined),
    };

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.fg, required this.bg, required this.icon});

  final String label;
  final Color fg;
  final Color bg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 10, 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
