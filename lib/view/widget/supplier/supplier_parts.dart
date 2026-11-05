import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/incoming_order_model.dart';
import '../../../data/model/order_model.dart';

/// أجزاء تتكرر في شاشات المورد.

/// منذ متى ينتظر التاجر. اللون يشتد كلما طال الانتظار:
/// أقل من 30 دقيقة رمادي، حتى 90 دقيقة أصفر، وبعدها أحمر.
class AgeChip extends StatelessWidget {
  const AgeChip({super.key, required this.since});

  final DateTime since;

  @override
  Widget build(BuildContext context) {
    final minutes = DateTime.now().difference(since).inMinutes;
    final (fg, bg) = minutes < 30
        ? (AppColor.textNote, AppColor.neutralSoft)
        : minutes < 90
            ? (AppColor.warning, AppColor.warningSoft)
            : (AppColor.danger, AppColor.dangerSoft);
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
      child: Text(formatAgo(since), style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// صف طلب في القوائم: اسم التاجر، الرقم وعدد الأصناف والقيمة، والحالة أو مدة الانتظار.
class IncomingOrderRow extends StatelessWidget {
  const IncomingOrderRow({super.key, required this.order, required this.onTap, this.showAge = false});

  final IncomingOrder order;
  final VoidCallback onTap;

  /// في قائمة "بانتظار قرارك" نعرض مدة الانتظار بدل الحالة.
  final bool showAge;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.traderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(
                      '#${o.id} · ${'itemsShort'.trParams({'n': '${o.lines.length}'})} · ${formatMoney(o.total, o.currency)}',
                      style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              showAge && o.status == SubOrderStatus.awaiting
                  ? AgeChip(since: o.createdAt)
                  : StatusChip(status: o.status, supplierView: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// قائمة صفوف داخل بطاقة بيضاء واحدة بفواصل.
class RowsCard extends StatelessWidget {
  const RowsCard({super.key, required this.children});

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
            if (i > 0) const Divider(height: 1, thickness: 1, color: AppColor.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}
