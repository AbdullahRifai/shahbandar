import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/supplier_data.dart';
import '../../data/model/product_model.dart';
import 'supplier_shell_controller.dart';

/// تبويبات "منتجاتي".
enum ProductsTab { all, published, paused, outOfStock }

/// C7 — منتجاتي، وC10 حين لا توجد منتجات.
/// مفتاح النشر بجانب كل منتج يوقفه أو ينشره فوراً (FR-22).
class SupplierProductsController extends GetxController {
  final SupplierData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  List<ProductModel> products = [];
  ProductsTab tab = ProductsTab.all;

  /// المنتجات التي يتغير نشرها الآن، لتعطيل مفتاحها.
  final Set<String> toggling = {};

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (status != StatusRequest.success) {
      status = StatusRequest.loading;
      update();
    }
    try {
      products = await _data.myProducts();
      status = StatusRequest.success;
    } catch (_) {
      if (products.isEmpty) status = StatusRequest.failure;
    }
    update();
  }

  static bool _matches(ProductModel p, ProductsTab t) => switch (t) {
        ProductsTab.all => true,
        ProductsTab.published => p.active,
        ProductsTab.paused => !p.active,
        ProductsTab.outOfStock => p.active && !p.inStock,
      };

  int countOf(ProductsTab t) => products.where((p) => _matches(p, t)).length;
  List<ProductModel> get visible => products.where((p) => _matches(p, tab)).toList();

  void setTab(ProductsTab t) {
    tab = t;
    update();
  }

  Future<void> toggle(ProductModel p) async {
    if (toggling.contains(p.id)) return;
    toggling.add(p.id);
    // نغيّر الشكل فوراً، ونرجعه إن فشل الطلب.
    _replace(p.copyWith(active: !p.active));
    try {
      final saved = await _data.setActive(p.id, !p.active);
      _replace(saved);
      showMessage(saved.active ? 'productPublished'.tr : 'productPaused'.tr);
    } catch (_) {
      _replace(p);
      showMessage('errorGeneric'.tr);
    }
    toggling.remove(p.id);
    update();
  }

  void _replace(ProductModel p) {
    final i = products.indexWhere((x) => x.id == p.id);
    if (i >= 0) products[i] = p;
    update();
  }

  Future<void> openAdd() async {
    await Get.toNamed(AppRoute.productForm);
    Get.find<SupplierShellController>().refreshAll();
  }

  Future<void> openEdit(ProductModel p) async {
    await Get.toNamed(AppRoute.productForm, arguments: p.id);
    Get.find<SupplierShellController>().refreshAll();
  }
}
