import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../data/datasource/catalog_data.dart';
import '../../data/model/option_model.dart';
import '../../data/model/product_filter.dart';
import '../../data/model/product_model.dart';
import '../../view/widget/trader/filter_sheet.dart';
import '../../view/widget/trader/sort_sheet.dart';
import '../../core/functions/first_where_or_null.dart';

/// B2 — البحث، مع B3 الفلترة وB4 الترتيب (FR-26 إلى FR-29).
/// البحث يبدأ بعد توقف الكتابة 350ms، حتى لا يُرسل طلب مع كل حرف.
class TraderSearchController extends GetxController {
  final CatalogData _catalog = Get.find();

  final TextEditingController query = TextEditingController();
  final FocusNode focus = FocusNode();
  Timer? _debounce;

  StatusRequest status = StatusRequest.none;
  ProductFilter filter = const ProductFilter();
  List<ProductModel> results = [];
  List<OptionModel> categories = [];

  @override
  void onInit() {
    super.onInit();
    _catalog.categories().then((c) => categories = c).catchError((_) => <OptionModel>[]);
    search();
  }

  void focusSearch() => Future.delayed(const Duration(milliseconds: 150), focus.requestFocus);

  void onQueryChanged(String text) {
    _debounce?.cancel();
    update(); // لإظهار زر المسح أو إخفائه
    _debounce = Timer(const Duration(milliseconds: 350), () {
      filter = filter.copyWith(query: text);
      search();
    });
  }

  void clearQuery() {
    query.clear();
    onQueryChanged('');
  }

  Future<void> search() async {
    status = StatusRequest.loading;
    update();
    try {
      results = await _catalog.search(filter);
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  Future<void> openFilter() async {
    final next = await showFilterSheet(current: filter, categories: categories);
    if (next == null) return;
    filter = next;
    search();
  }

  Future<void> openSort() async {
    final next = await showSortSheet(filter.sort);
    if (next == null || next == filter.sort) return;
    filter = filter.copyWith(sort: next);
    search();
  }

  /// إزالة فلتر واحد من شرائح الفلاتر المفعّلة.
  void apply(ProductFilter next) {
    filter = next;
    search();
  }

  void clearFilters() {
    filter = filter.cleared();
    search();
  }

  String? categoryLabel(String? id) => firstWhereOrNull(categories, (c) => c.id == id)?.label;

  @override
  void onClose() {
    _debounce?.cancel();
    query.dispose();
    focus.dispose();
    super.onClose();
  }
}
