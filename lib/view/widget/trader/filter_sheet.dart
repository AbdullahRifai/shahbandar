import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../data/model/option_model.dart';
import '../../../data/model/product_filter.dart';
import '../../../data/model/product_model.dart';

/// B3 — الفلترة (FR-27، FR-28).
/// التعديلات هنا مؤقتة، ولا تُطبَّق إلا عند "عرض النتائج". الإغلاق بالسحب يلغيها.
/// [lockCategory]: في صفحة التصنيف (B5) يبقى التصنيف ثابتاً فلا نعرض اختياره.
Future<ProductFilter?> showFilterSheet({
  required ProductFilter current,
  required List<OptionModel> categories,
  bool lockCategory = false,
}) {
  return Get.bottomSheet<ProductFilter>(
    _FilterSheet(current: current, categories: categories, lockCategory: lockCategory),
    backgroundColor: AppColor.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.categories, required this.lockCategory});

  final ProductFilter current;
  final List<OptionModel> categories;
  final bool lockCategory;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ProductFilter _f = widget.current;
  late final _min = TextEditingController(text: _num(widget.current.minPrice));
  late final _max = TextEditingController(text: _num(widget.current.maxPrice));

  static String _num(double? v) => v == null ? '' : (v == v.roundToDouble() ? '${v.toInt()}' : '$v');

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _f = widget.lockCategory ? _f.cleared().copyWith(categoryId: () => _f.categoryId) : _f.cleared();
      _min.clear();
      _max.clear();
    });
  }

  void _apply() {
    var min = double.tryParse(_min.text);
    var max = double.tryParse(_max.text);
    // إن كتب الحد الأدنى أكبر من الأعلى نبدّلهما بدل إظهار خطأ.
    if (min != null && max != null && min > max) (min, max) = (max, min);
    Get.back(result: _f.copyWith(minPrice: () => min, maxPrice: () => max));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('filterTitle'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    AppTextLink(label: 'clearAll'.tr, onPressed: _clear),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  children: [
                    if (!widget.lockCategory) ...[
                      _label('category'.tr),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip('all'.tr, _f.categoryId == null, () => setState(() => _f = _f.copyWith(categoryId: () => null))),
                          for (final c in widget.categories)
                            _chip(c.label, _f.categoryId == c.id,
                                () => setState(() => _f = _f.copyWith(categoryId: () => c.id))),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    _label('priceRange'.tr),
                    SegmentedButton<Currency>(
                      segments: [
                        for (final c in Currency.values)
                          ButtonSegment(value: c, label: Text(currencyName(c))),
                      ],
                      selected: {_f.priceCurrency},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => setState(() => _f = _f.copyWith(priceCurrency: s.first)),
                      style: SegmentedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        selectedBackgroundColor: AppColor.orangeSoft,
                        selectedForegroundColor: AppColor.ink,
                        side: const BorderSide(color: AppColor.border, width: 1.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _priceField(_min, 'priceFrom'.tr)),
                        const SizedBox(width: 10),
                        Expanded(child: _priceField(_max, 'priceTo'.tr)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'priceRangeNote'.tr,
                      style: const TextStyle(fontSize: 13, color: AppColor.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      value: _f.availableOnly,
                      onChanged: (v) => setState(() => _f = _f.copyWith(availableOnly: v)),
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColor.success,
                      title: Text('availableOnly'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: AppButton(label: 'showResults'.tr, onPressed: _apply),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColor.orangeSoft,
        backgroundColor: AppColor.surface,
        side: BorderSide(color: selected ? AppColor.orange : AppColor.border, width: 1.5),
        labelStyle: TextStyle(
          color: AppColor.ink,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _priceField(TextEditingController c, String hint) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textDirection: TextDirection.ltr,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColor.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColor.ink, width: 2),
          ),
        ),
      );
}
