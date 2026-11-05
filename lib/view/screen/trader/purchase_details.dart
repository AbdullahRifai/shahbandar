import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/purchase_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/order_slip.dart';
import '../../../core/shared/state_views.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/order_model.dart';
import '../../widget/trader/product_thumb.dart';
import '../../widget/trader/order_tracker.dart';
import '../../widget/trader/trader_parts.dart';

/// B15 — تفاصيل عملية الشراء: قسيمة لكل مورد مع متتبّع المراحل وأصنافه.
/// B17 — حين يُرفض طلب أو يُلغى: تظهر حالته النهائية وسبب الرفض (إن كتبه المورد)،
/// ويبقى في السجل بلا إجراءات (FR-51).
/// إلغاء الطلب (B16) متاح فقط وهو "بانتظار الرد".
class PurchaseDetailsScreen extends StatelessWidget {
  const PurchaseDetailsScreen({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseController>(
      init: PurchaseController(purchaseId),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('purchaseNo'.trParams({'n': purchaseId}))),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => RefreshIndicator(
              onRefresh: c.load,
              color: AppColor.ink,
              child: MaxWidth(
                maxWidth: 640,
                child: _Body(c: c, p: c.purchase!),
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.c, required this.p});

  final PurchaseController c;
  final Purchase p;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(formatDateTime(p.createdAt),
                        style: const TextStyle(color: AppColor.textSecondary, fontSize: 14)),
                  ),
                  PurchaseStatusChip(status: p.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('suppliersCount'.trParams({'n': '${p.subOrders.length}'}),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  if (p.totals.isNotEmpty) CurrencyTotals(totals: p.totals, large: true),
                ],
              ),
              if (p.subOrders.any((s) => s.isClosed))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('totalExcludesClosed'.tr,
                      style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final s in p.subOrders) ...[
          _SubOrderSlip(c: c, s: s),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _SubOrderSlip extends StatelessWidget {
  const _SubOrderSlip({required this.c, required this.s});

  final PurchaseController c;
  final SubOrder s;

  @override
  Widget build(BuildContext context) {
    final closed = s.isClosed;
    return OrderSlip(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.supplierName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('subOrderNo'.trParams({'n': s.id}),
                          style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                StatusChip(status: s.status),
              ],
            ),
            if (!closed) ...[
              const SizedBox(height: 14),
              OrderTracker(status: s.status),
            ],
            if (closed) ...[
              const SizedBox(height: 12),
              _ClosedNote(s: s),
            ],
          ],
        ),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text('supplierSubtotal'.tr, style: const TextStyle(color: AppColor.textSecondary))),
                Text(
                  formatMoney(s.total, s.currency),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    decoration: closed ? TextDecoration.lineThrough : null,
                    color: closed ? AppColor.textSecondary : AppColor.ink,
                  ),
                ),
              ],
            ),
            if (s.canCancel) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'cancelThisOrder'.tr,
                style: AppButtonStyle.secondary,
                isLoading: c.cancellingId == s.id,
                onPressed: c.cancellingId == null ? () => c.cancel(s) : null,
              ),
              const SizedBox(height: 4),
              Text('cancelHint'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColor.textSecondary, fontSize: 12.5)),
            ],
          ],
        ),
        child: Column(
          children: [
            for (final l in s.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ProductThumb(visual: l.visual, size: 44, radius: 10),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.name, style: const TextStyle(fontSize: 14.5, height: 1.4)),
                          Text('${formatCount(l.quantity)} × ${formatMoney(l.unitPrice, s.currency)}',
                              style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(formatMoney(l.total, s.currency), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
    );
  }
}

/// B17: سبب الرفض أو تاريخ الإلغاء، بخلفية الحالة.
class _ClosedNote extends StatelessWidget {
  const _ClosedNote({required this.s});

  final SubOrder s;

  @override
  Widget build(BuildContext context) {
    final rejected = s.status == SubOrderStatus.rejected;
    final (fg, bg, icon) = subOrderStyle(s.status);
    final when = s.updatedAt == null ? '' : formatDateTime(s.updatedAt!);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: rejected ? AppColor.dangerText : fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rejected ? 'rejectedOn'.trParams({'d': when}) : 'cancelledOn'.trParams({'d': when}),
                  style: TextStyle(
                    color: rejected ? AppColor.dangerText : fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (rejected) ...[
                  const SizedBox(height: 4),
                  Text(
                    (s.rejectReason?.isNotEmpty ?? false) ? s.rejectReason! : 'noReasonGiven'.tr,
                    style: const TextStyle(color: AppColor.dangerText, fontSize: 14, height: 1.6),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
