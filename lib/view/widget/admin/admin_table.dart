import 'package:flutter/material.dart';

import '../../../core/constant/app_color.dart';

/// عمود في جدول الإدارة: العنوان ونسبة العرض.
class AdminColumn {
  const AdminColumn(this.label, {this.flex = 2, this.end = false});

  final String label;
  final int flex;

  /// محاذاة لنهاية الخلية (للمبالغ).
  final bool end;
}

/// جدول الإدارة: رأس رمادي فاتح، صفوف بفاصل، تمرير أفقي حين يضيق العرض.
/// الصف المحدد بخلفية دافئة، والضغط على الصف يستدعي [onTap].
class AdminTable extends StatelessWidget {
  const AdminTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onTap,
    this.selected,
    this.minWidth = 720,
    this.emptyText,
  });

  final List<AdminColumn> columns;
  final List<List<Widget>> rows;
  final ValueChanged<int>? onTap;
  final int? selected;

  /// أقل عرض قبل أن يبدأ التمرير الأفقي.
  final double minWidth;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth < minWidth ? minWidth : box.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: const Color(0xFFFAFBFC),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        for (final c in columns)
                          Expanded(
                            flex: c.flex,
                            child: Text(
                              c.label,
                              textAlign: c.end ? TextAlign.end : TextAlign.start,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColor.divider),
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(emptyText ?? '',
                          textAlign: TextAlign.center, style: const TextStyle(color: AppColor.textSecondary)),
                    ),
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColor.divider),
                    InkWell(
                      onTap: onTap == null ? null : () => onTap!(i),
                      child: Container(
                        color: i == selected ? const Color(0xFFFFF8F2) : null,
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            for (var c = 0; c < columns.length; c++)
                              Expanded(
                                flex: columns[c].flex,
                                child: Align(
                                  alignment: columns[c].end
                                      ? AlignmentDirectional.centerEnd
                                      : AlignmentDirectional.centerStart,
                                  child: c < rows[i].length ? rows[i][c] : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
