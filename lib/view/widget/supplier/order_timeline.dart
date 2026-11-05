import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../data/model/incoming_order_model.dart';
import '../../../data/model/order_model.dart';

/// C6 — مراحل الطلب عمودياً عند المورد:
/// استُلم ← قبلتَه ← قيد التجهيز ← مكتمل، مع وقت كل مرحلة.
/// المرحلة التالية بحلقة برتقالية و"الخطوة التالية". المرفوض والملغى ينتهيان عند حالتهما.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});

  final IncomingOrder order;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final closedAs = switch (status) {
      SubOrderStatus.rejected || SubOrderStatus.cancelled => status,
      _ => null,
    };

    final steps = closedAs != null
        ? [SubOrderStatus.awaiting, closedAs]
        : const [SubOrderStatus.awaiting, SubOrderStatus.accepted, SubOrderStatus.preparing, SubOrderStatus.completed];

    // أول مرحلة لم تُبلغ بعد هي "التالية".
    final nextIndex = steps.indexWhere((s) => !order.timeline.containsKey(s));

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _Step(
            label: 'tl_${steps[i].name}'.tr,
            time: order.timeline[steps[i]],
            state: order.timeline.containsKey(steps[i])
                ? (steps[i] == closedAs ? _State.closed : _State.done)
                : (i == nextIndex ? _State.next : _State.later),
          ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 11),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 2,
                  height: 22,
                  color: order.timeline.containsKey(steps[i + 1]) ? AppColor.ink : AppColor.border,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

enum _State { done, next, later, closed }

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.time, required this.state});

  final String label;
  final DateTime? time;
  final _State state;

  @override
  Widget build(BuildContext context) {
    final dot = switch (state) {
      _State.done => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: AppColor.ink, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 14, color: AppColor.surface),
        ),
      _State.closed => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: AppColor.danger, shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, size: 14, color: AppColor.surface),
        ),
      _State.next => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColor.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.orange, width: 2.5),
          ),
        ),
      _State.later => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColor.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.border, width: 2.5),
          ),
        ),
    };

    final reached = state == _State.done || state == _State.closed;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dot,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: reached || state == _State.next ? FontWeight.w700 : FontWeight.w400,
                  color: state == _State.later ? AppColor.textSecondary : AppColor.ink,
                ),
              ),
              if (state == _State.next)
                Text('nextStep'.tr, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
            ],
          ),
        ),
        if (time != null)
          Text(formatDateTime(time!), style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
      ],
    );
  }
}
