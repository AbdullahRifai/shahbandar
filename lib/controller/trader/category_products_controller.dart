import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../data/datasource/catalog_data.dart';
import '../../data/model/option_model.dart';
import '../../data/model/product_filter.dart';
import '../../data/model/product_model.dart';
import '../../view/widget/trader/filter_sheet.dart';
import '../../view/widget/trader/sort_sheet.dart';

/// B5 — منتجات تصنيف واحد (FR-23)، مع الفلترة والترتيب.
/// يُنشأ لكل صفحة على حدة (لا يُسجَّل عاماً)، لذلك يأخذ التصنيف في الإنشاء.
class CategoryProductsController extends GetxController {
  CategoryProductsController(this.category)
      : filter = ProductFilter(categoryId: category.id);

  final OptionModel category;
  final CatalogData _catalog = Get.find();

  StatusRequest status = StatusRequest.none;
  ProductFilter filter;
  List<ProductModel> products = [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      products = await _catalog.search(filter);
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  /// عدد الفلاتر المفعّلة غير التصنيف نفسه.
  int get activeFilters => filter.activeCount - 1;

  Future<void> openFilter() async {
    final next = await showFilterSheet(current: filter, categories: const [], lockCategory: true);
    if (next == null) return;
    filter = next;
    load();
  }

  Future<void> openSort() async {
    final next = await showSortSheet(filter.sort);
    if (next == null || next == filter.sort) return;
    filter = filter.copyWith(sort: next);
    load();
  }
}
