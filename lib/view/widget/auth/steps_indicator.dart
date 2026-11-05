import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/max_width.dart';

/// مؤشر مراحل التسجيل الأربع (قرارنا أ1 في A3):
/// الحساب ← تأكيد البريد ← الأدوار ← الملف التجاري.
/// المنجزة كحلية، الحالية برتقالية، القادمة رمادية.
class StepsIndicator extends StatelessWidget {
  const StepsIndicator({super.key, required this.current});

  /// رقم المرحلة الحالية من 0 إلى 3.
  final int current;

  static const _keys = ['stepAccount', 'stepEmail', 'stepRoles', 'stepProfile'];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'stepOf'.trParams({'n': '${current + 1}', 't': '${_keys.length}'}),
      child: MaxWidth(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
        child: Row(
          children: [
            for (var i = 0; i < _keys.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _Step(label: _keys[i].tr, index: i, current: current)),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.index, required this.current});

  final String label;
  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final isCurrent = index == current;
    final barColor = index < current
        ? AppColor.ink
        : (isCurrent ? AppColor.orange : AppColor.divider);

    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isCurrent ? AppColor.ink : AppColor.textSecondary,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
