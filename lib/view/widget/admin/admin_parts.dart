import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';

/// أجزاء تتكرر في صفحات الإدارة.

/// عنوان الصفحة، مع نص فرعي أو عدّاد على الجهة الأخرى.
class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          runSpacing: 4,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3)),
            ),
            if (trailing != null)
              Text(trailing!, style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColor.textSecondary)),
        ],
      ],
    );
  }
}

/// زر فلتر دائري: أبيض، أو كحلي حين يكون مختاراً.
class FilterPill extends StatelessWidget {
  const FilterPill({super.key, required this.label, required this.selected, required this.onTap, this.count});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColor.ink : AppColor.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? AppColor.ink : AppColor.border, width: 1.5)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColor.surface : AppColor.ink)),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(color: AppColor.orange, borderRadius: BorderRadius.circular(10)),
                    child: Text('$count',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.ink)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// حقل البحث في رأس الجداول.
class AdminSearchField extends StatelessWidget {
  const AdminSearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c, double w) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380, minWidth: 220),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColor.textSecondary, fontSize: 14),
          isDense: true,
          filled: true,
          fillColor: AppColor.surface,
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColor.textSecondary),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: b(AppColor.border, 1.5),
          focusedBorder: b(AppColor.ink, 2),
        ),
      ),
    );
  }
}

/// شارة حالة صغيرة بلون ونص.
class AdminChip extends StatelessWidget {
  const AdminChip({super.key, required this.label, required this.fg, required this.bg});

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

/// بطاقة بيضاء بعنوان اختياري.
class AdminBox extends StatelessWidget {
  const AdminBox({super.key, required this.child, this.title, this.border});

  final Widget child;
  final String? title;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: border == null ? null : Border.all(color: border!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

/// قائمة "مفتاح: قيمة" بعمودين.
class KeyValueList extends StatelessWidget {
  const KeyValueList({super.key, required this.items, this.keyWidth = 130});

  final List<(String, Widget)> items;
  final double keyWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (k, v) in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: keyWidth,
                  child: Text(k, style: const TextStyle(fontSize: 15, color: AppColor.textSecondary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    child: v,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// نص لاتيني (بريد، هاتف) يبقى ملاصقاً لبداية الخلية في الاتجاهين.
class LtrText extends StatelessWidget {
  const LtrText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 1,
        child: Text(text, textDirection: TextDirection.ltr, style: style, overflow: TextOverflow.ellipsis),
      );
}

/// صف فلاتر يلتف على الشاشات الضيقة.
class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

/// تأكيد إجراء إداري. يرجع true عند التأكيد.
Future<bool> confirmAdminAction({
  required String title,
  required String body,
  required String confirmLabel,
  bool danger = false,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: AppColor.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Text(body, style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary)),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        SizedBox(
          width: 140,
          child: AppButton(
            label: 'undo'.tr,
            style: AppButtonStyle.secondary,
            onPressed: () => Get.back(result: false),
          ),
        ),
        SizedBox(
          width: 180,
          child: AppButton(
            label: confirmLabel,
            style: danger ? AppButtonStyle.danger : AppButtonStyle.primary,
            onPressed: () => Get.back(result: true),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// صفحة قسم: قائمة قابلة للتمرير بهوامش تتسع مع الشاشة، ومسافة 18 بين الأجزاء.
class AdminPage extends StatelessWidget {
  const AdminPage({super.key, required this.children, this.onRefresh});

  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final side = (width * 0.03).clamp(16.0, 40.0).toDouble();
    final list = ListView(
      padding: EdgeInsets.fromLTRB(side, 28, side, 40),
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 18),
          children[i],
        ],
      ],
    );
    return onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, color: AppColor.ink, child: list);
  }
}

/// لوحة جانبية بجانب الجدول على الشاشات العريضة، وتحته على الضيقة.
class TableWithPanel extends StatelessWidget {
  const TableWithPanel({super.key, required this.table, required this.panel});

  final Widget table;
  final Widget? panel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (panel == null) return table;
        if (box.maxWidth < 900) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [table, const SizedBox(height: 18), panel!]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: table),
            const SizedBox(width: 18),
            Expanded(child: panel!),
          ],
        );
      },
    );
  }
}
