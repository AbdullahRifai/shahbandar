import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shared/activity_log_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/activity_model.dart';

/// D5 — سجل نشاطي: فلاتر (الكل، الطلبات، الحساب)، ومجموعات حسب اليوم.
/// للعرض فقط، مع تنبيه أمني في الأسفل.
class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivityLogController>(
      init: ActivityLogController(),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('activityLog'.tr)),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => MaxWidth(
              maxWidth: 640,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final f in ActivityFilter.values)
                        ChoiceChip(
                          label: Text('af_${f.name}'.tr),
                          selected: c.filter == f,
                          onSelected: (_) => c.setFilter(f),
                          showCheckmark: false,
                          selectedColor: AppColor.ink,
                          backgroundColor: AppColor.surface,
                          side: BorderSide(color: c.filter == f ? AppColor.ink : AppColor.border, width: 1.5),
                          labelStyle: TextStyle(
                            color: c.filter == f ? AppColor.surface : AppColor.ink,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: const StadiumBorder(),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                    ],
                  ),
                  for (final entry in c.grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                      child: Semantics(
                        header: true,
                        child: Text(_dayLabel(entry.key),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.textSecondary)),
                      ),
                    ),
                    Material(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (var i = 0; i < entry.value.length; i++) ...[
                            if (i > 0) const Divider(height: 1, color: AppColor.divider),
                            _Row(e: entry.value[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (c.grouped.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Text('noActivity'.tr,
                          textAlign: TextAlign.center, style: const TextStyle(color: AppColor.textSecondary)),
                    ),
                  const SizedBox(height: 14),
                  Text('activityNote'.tr,
                      style: const TextStyle(fontSize: 13, height: 1.6, color: AppColor.textSecondary)),
                ],
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'ng_today'.tr;
    if (day == today.subtract(const Duration(days: 1))) return 'ng_yesterday'.tr;
    return formatDate(day);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.e});

  final ActivityEntry e;

  static IconData _icon(ActivityIcon i) => switch (i) {
        ActivityIcon.order => Icons.receipt_long_outlined,
        ActivityIcon.cart => Icons.shopping_cart_outlined,
        ActivityIcon.cancel => Icons.close_rounded,
        ActivityIcon.login => Icons.login_rounded,
        ActivityIcon.profile => Icons.person_outline_rounded,
        ActivityIcon.password => Icons.lock_outline_rounded,
        ActivityIcon.role => Icons.swap_horiz_rounded,
        ActivityIcon.product => Icons.inventory_2_outlined,
        ActivityIcon.delete => Icons.person_remove_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final danger = e.icon == ActivityIcon.cancel || e.icon == ActivityIcon.delete;
    final time = '${e.at.hour.toString().padLeft(2, '0')}:${e.at.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColor.background, borderRadius: BorderRadius.circular(10)),
            child: Icon(_icon(e.icon), size: 18, color: danger ? AppColor.danger : AppColor.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(e.textKey.trParams(e.params), style: const TextStyle(fontSize: 15, height: 1.45)),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(time, style: const TextStyle(fontSize: 12, color: AppColor.textSecondary)),
          ),
        ],
      ),
    );
  }
}
