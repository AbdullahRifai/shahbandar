import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/trader_search_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/services/compare_service.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/product_filter.dart';
import '../../widget/trader/product_card.dart';
import '../../widget/trader/trader_parts.dart';

/// B2 — البحث (FR-26) مع شريط الفلترة (B3) والترتيب (B4).
/// الفلاتر المفعّلة تظهر شرائح يمكن إزالتها بضغطة، وعدد النتائج ظاهر دائماً.
class TraderSearchScreen extends StatelessWidget {
  const TraderSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TraderSearchController>(
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('tabSearch'.tr)),
        floatingActionButton: GetBuilder<CompareService>(
          builder: (cmp) => cmp.items.length >= 2 ? CompareShortcut(count: cmp.items.length) : const SizedBox.shrink(),
        ),
        body: MaxWidth(
          maxWidth: AppLayout.contentMaxWidth,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverList.list(
                  children: [
                    _SearchField(c: c),
                    const SizedBox(height: 10),
                    _ToolsRow(c: c),
                    if (c.filter.activeCount > 0) ...[
                      const SizedBox(height: 8),
                      _ActiveFilters(c: c),
                    ],
                  ],
                ),
              ),
              ..._results(c),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _results(TraderSearchController c) {
    switch (c.status) {
      case StatusRequest.failure:
        return [SliverFillRemaining(hasScrollBody: false, child: ErrorView(onRetry: c.search))];
      case StatusRequest.success when c.results.isEmpty:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              icon: Icons.search_off_rounded,
              title: 'noResults'.tr,
              message: c.filter.activeCount > 0 ? 'noResultsFiltered'.tr : 'noResultsHint'.tr,
              actionLabel: c.filter.activeCount > 0 ? 'clearFilters'.tr : null,
              onAction: c.clearFilters,
            ),
          ),
        ];
      case StatusRequest.success:
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  'resultsCount'.trParams({'n': '${c.results.length}'}),
                  style: const TextStyle(color: AppColor.textSecondary, fontSize: 14),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            sliver: ProductSliverGrid(products: c.results),
          ),
        ];
      default:
        return const [SliverFillRemaining(hasScrollBody: false, child: LoadingView())];
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.c});

  final TraderSearchController c;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: w),
        );
    return TextField(
      controller: c.query,
      focusNode: c.focus,
      onChanged: c.onQueryChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'searchHint'.tr,
        hintStyle: const TextStyle(color: AppColor.textSecondary),
        filled: true,
        fillColor: AppColor.surface,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColor.textSecondary),
        suffixIcon: c.query.text.isEmpty
            ? null
            : IconButton(
                onPressed: c.clearQuery,
                tooltip: 'clearSearch'.tr,
                icon: const Icon(Icons.close_rounded),
              ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: border(AppColor.border, 1.5),
        focusedBorder: border(AppColor.ink, 2),
      ),
    );
  }
}

/// زرّا الفلترة والترتيب، مع عدد الفلاتر المفعّلة على زر الفلترة.
class _ToolsRow extends StatelessWidget {
  const _ToolsRow({required this.c});

  final TraderSearchController c;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToolButton(
          icon: Icons.tune_rounded,
          label: c.filter.activeCount > 0
              ? 'filterWithCount'.trParams({'n': '${c.filter.activeCount}'})
              : 'filter'.tr,
          highlighted: c.filter.activeCount > 0,
          onTap: c.openFilter,
        ),
        const SizedBox(width: 8),
        _ToolButton(
          icon: Icons.swap_vert_rounded,
          label: 'sort_${c.filter.sort.name}'.tr,
          highlighted: c.filter.sort != ProductSort.newest,
          onTap: c.openSort,
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.label, required this.onTap, this.highlighted = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 44),
        foregroundColor: AppColor.ink,
        backgroundColor: highlighted ? AppColor.orangeSoft : AppColor.surface,
        side: BorderSide(color: highlighted ? AppColor.orange : AppColor.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

/// الفلاتر المفعّلة كشرائح قابلة للإزالة.
class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.c});

  final TraderSearchController c;

  @override
  Widget build(BuildContext context) {
    final f = c.filter;
    String price() {
      final cur = currencyName(f.priceCurrency);
      if (f.minPrice != null && f.maxPrice != null) {
        return '${formatMoney(f.minPrice!, f.priceCurrency)} – ${formatMoney(f.maxPrice!, f.priceCurrency)}';
      }
      if (f.minPrice != null) return 'priceFromChip'.trParams({'v': formatMoney(f.minPrice!, f.priceCurrency)});
      if (f.maxPrice != null) return 'priceToChip'.trParams({'v': formatMoney(f.maxPrice!, f.priceCurrency)});
      return cur;
    }

    final apply = c.apply;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (f.categoryId != null)
          _chip(c.categoryLabel(f.categoryId) ?? '', () => apply(f.copyWith(categoryId: () => null))),
        if (f.hasPriceRange)
          _chip(price(), () => apply(f.copyWith(minPrice: () => null, maxPrice: () => null))),
        if (f.availableOnly) _chip('availableOnly'.tr, () => apply(f.copyWith(availableOnly: false))),
      ],
    );
  }

  Widget _chip(String label, VoidCallback onRemove) => InputChip(
        label: Text(label),
        onDeleted: onRemove,
        deleteButtonTooltipMessage: 'removeFilter'.tr,
        deleteIcon: const Icon(Icons.close_rounded, size: 18),
        backgroundColor: AppColor.surface,
        side: const BorderSide(color: AppColor.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      );
}
