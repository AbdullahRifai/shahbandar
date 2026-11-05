import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/order_model.dart';

/// متتبّع مراحل الطلب الفرعي: بانتظار الرد ← مقبول ← قيد التجهيز ← مكتمل.
/// الطلب المرفوض أو الملغى لا يُرسم له مسار، بل تظهر حالته النهائية فقط.
class OrderTracker extends StatelessWidget {
  const OrderTracker({super.key, required this.status});

  final SubOrderStatus status;

  static const _steps = [
    SubOrderStatus.awaiting,
    SubOrderStatus.accepted,
    SubOrderStatus.preparing,
    SubOrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final current = _steps.indexOf(status);
    if (current < 0) return const SizedBox.shrink();

    return Semantics(
      label: 'trackerLabel'.trParams({'s': 'st_${status.name}'.tr}),
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _steps.length; i++)
              Expanded(child: _Step(step: _steps[i], index: i, current: current)),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.step, required this.index, required this.current});

  final SubOrderStatus step;
  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index <= current;
    // لون المسار كله يتبع المرحلة الحالية.
    final (color, _, _) = subOrderStyle(OrderTracker._steps[current]);
    final active = done ? color : AppColor.border;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 3, color: index == 0 ? Colors.transparent : (done ? active : AppColor.border))),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: done ? active : AppColor.surface,
                shape: BoxShape.circle,
                border: Border.all(color: active, width: 2),
              ),
              child: done ? const Icon(Icons.check_rounded, size: 14, color: AppColor.surface) : null,
            ),
            Expanded(child: Container(height: 3, color: index == 3 ? Colors.transparent : (index < current ? active : AppColor.border))),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'st_${step.name}'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: index == current ? FontWeight.w700 : FontWeight.w400,
            color: done ? AppColor.ink : AppColor.textSecondary,
          ),
        ),
      ],
    );
  }
}
