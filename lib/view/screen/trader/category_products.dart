import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/category_products_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/services/compare_service.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/option_model.dart';
import '../../widget/trader/product_card.dart';
import '../../widget/trader/trader_parts.dart';

/// B5 — منتجات تصنيف: شبكة مع الفلترة والترتيب في شريط العنوان.
/// المتحكم محلي لهذه الصفحة (global: false)، فيمكن فتح أكثر من تصنيف فوق بعضها.
class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final OptionModel category;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryProductsController>(
      init: CategoryProductsController(category),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text(category.label),
          actions: [
            IconButton(
              onPressed: c.openSort,
              tooltip: 'sortTitle'.tr,
              icon: const Icon(Icons.swap_vert_rounded),
            ),
            IconButton(
              onPressed: c.openFilter,
              tooltip: 'filter'.tr,
              icon: Badge(
                isLabelVisible: c.activeFilters > 0,
                label: Text('${c.activeFilters}'),
                backgroundColor: AppColor.orange,
                textColor: AppColor.ink,
                child: const Icon(Icons.tune_rounded),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: GetBuilder<CompareService>(
          builder: (cmp) => cmp.items.length >= 2 ? CompareShortcut(count: cmp.items.length) : const SizedBox.shrink(),
        ),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success when c.products.isEmpty => EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'noResults'.tr,
              message: c.activeFilters > 0 ? 'noResultsFiltered'.tr : 'categoryEmpty'.tr,
            ),
          StatusRequest.success => MaxWidth(
              maxWidth: AppLayout.contentMaxWidth,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '${'resultsCount'.trParams({'n': '${c.products.length}'})} · ${'sort_${c.filter.sort.name}'.tr}',
                        style: const TextStyle(color: AppColor.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: ProductSliverGrid(products: c.products),
                  ),
                ],
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}
