import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/supplier/incoming_order_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/order_slip.dart';
import '../../../core/shared/state_views.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/incoming_order_model.dart';
import '../../../data/model/order_model.dart';
import '../../widget/supplier/order_timeline.dart';
import '../../widget/trader/trader_parts.dart';

/// C3 — طلب وارد (بانتظار القرار): التاجر، الأصناف مع المخزون المتوفر لكل صنف،
///      القيمة، ملاحظة التاجر، وزرّا "رفض" و"قبول الطلب".
/// C6 — بعد القبول: مراحل الطلب، الأصناف، التواصل، وزر الخطوة التالية.
/// المرفوض والمكتمل: للعرض فقط.
class IncomingOrderScreen extends StatelessWidget {
  const IncomingOrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IncomingOrderController>(
      init: IncomingOrderController(orderId),
      global: false,
      builder: (c) {
        final o = c.order;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.isAwaiting ? 'incomingOrderNo'.trParams({'n': orderId}) : 'orderNo'.trParams({'n': orderId}),
                    style: const TextStyle(fontSize: 18)),
                if (o != null)
                  Text(formatDateTime(o.createdAt),
                      style: const TextStyle(fontSize: 13, color: AppColor.textSecondary, fontWeight: FontWeight.w400)),
              ],
            ),
            actions: [
              if (o != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Center(child: StatusChip(status: o.status, supplierView: true)),
                ),
            ],
          ),
          body: switch (c.status) {
            StatusRequest.failure => ErrorView(onRetry: c.load),
            StatusRequest.success => MaxWidth(maxWidth: 640, child: _Body(c: c, o: o!)),
            _ => const LoadingView(),
          },
          bottomNavigationBar: o == null ? null : _Actions(c: c, o: o),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.c, required this.o});

  final IncomingOrderController c;
  final IncomingOrder o;

  @override
  Widget build(BuildContext context) {
    final awaiting = c.isAwaiting;
    return RefreshIndicator(
      onRefresh: c.load,
      color: AppColor.ink,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (!awaiting) ...[
            SurfaceCard(child: OrderTimeline(order: o)),
            if (o.status == SubOrderStatus.rejected && (o.sub.rejectReason?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              _Note(title: 'yourRejectReason'.tr, text: o.sub.rejectReason!),
            ],
            const SizedBox(height: 12),
          ],
          _TraderCard(c: c, o: o),
          const SizedBox(height: 12),
          OrderSlip(
            header: Text('requestedItems'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            footer: Row(
              children: [
                Expanded(child: Text('orderValue'.tr, style: const TextStyle(color: AppColor.textSecondary))),
                Text(formatMoney(o.total, o.currency),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < o.lines.length; i++) ...[
                  if (i > 0) const Divider(height: 16, color: AppColor.divider),
                  _Line(o: o, line: o.lines[i], showStock: awaiting),
                ],
              ],
            ),
          ),
          if (o.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Note(title: 'traderNote'.tr, text: o.note),
          ],
          if (awaiting) ...[
            const SizedBox(height: 12),
            Text('acceptHint'.tr, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColor.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _TraderCard extends StatelessWidget {
  const _TraderCard({required this.c, required this.o});

  final IncomingOrderController c;
  final IncomingOrder o;

  @override
  Widget build(BuildContext context) {
    final initial = o.traderName.isEmpty ? '?' : String.fromCharCode(o.traderName.runes.first);
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColor.neutralSoft, borderRadius: BorderRadius.circular(12)),
              child: Text(initial, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.traderName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(o.traderArea, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                if (o.traderPhone.isNotEmpty)
                  Text(o.traderPhone,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
              ],
            ),
          ),
          if (o.traderPhone.isNotEmpty)
            IconButton(
              onPressed: c.copyPhone,
              tooltip: 'copyPhone'.tr,
              icon: const Icon(Icons.copy_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.o, required this.line, required this.showStock});

  final IncomingOrder o;
  final OrderLine line;
  final bool showStock;

  @override
  Widget build(BuildContext context) {
    final enough = o.hasStock(line);
    final available = o.available[line.productId];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
              // C3: هل يكفي المخزون؟ أخضر بعلامة صح، أو أحمر بعلامة تنبيه.
              if (showStock && enough != null && available != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(enough ? Icons.check_rounded : Icons.error_outline_rounded,
                          size: 15, color: enough ? AppColor.success : AppColor.danger),
                      const SizedBox(width: 4),
                      Text(
                        enough
                            ? 'stockAvailable'.trParams({'n': formatCount(available)})
                            : 'stockShort'.trParams({'n': formatCount(available)}),
                        style: TextStyle(fontSize: 12.5, color: enough ? AppColor.success : AppColor.danger),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text('${formatCount(line.quantity)} × ${formatMoney(line.unitPrice, o.currency)}',
            style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
          ],
        ),
      );
}

/// الشريط السفلي حسب الحالة:
///   بانتظار القرار: رفض + قبول الطلب.
///   مقبول/قيد التجهيز: الخطوة التالية + تلميح.
///   غير ذلك: لا شيء.
class _Actions extends StatelessWidget {
  const _Actions({required this.c, required this.o});

  final IncomingOrderController c;
  final IncomingOrder o;

  @override
  Widget build(BuildContext context) {
    if (c.isAwaiting) {
      return BottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: c.busy ? null : c.openReject,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColor.danger,
                  side: const BorderSide(color: AppColor.border, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: Text('reject'.tr),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(label: 'acceptOrder'.tr, isLoading: c.busy, onPressed: c.accept),
            ),
          ],
        ),
      );
    }
    final key = c.advanceLabelKey;
    if (key == null) return const SizedBox.shrink();
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(label: key.tr, isLoading: c.busy, onPressed: c.advance),
          const SizedBox(height: 6),
          Text(
            o.status == SubOrderStatus.accepted ? 'preparingHint'.tr : 'deliveredHint'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }
}
