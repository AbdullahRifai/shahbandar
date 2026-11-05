import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/compare_service.dart';
import '../../data/datasource/catalog_data.dart';
import '../../data/model/product_model.dart';
import '../../data/model/request_failure.dart';

/// B6 — تفاصيل المنتج (FR-30): الكمية، الإضافة للسلة (FR-33)، والمقارنة (FR-31).
class ProductController extends GetxController {
  ProductController(this.productId);

  final String productId;
  final CatalogData _catalog = Get.find();
  final CartService cart = Get.find();
  final CompareService compare = Get.find();

  StatusRequest status = StatusRequest.none;
  bool notFound = false;
  ProductModel? product;
  int quantity = 1;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      final p = await _catalog.product(productId);
      product = p;
      // إن كان في السلة نبدأ بكميته هناك، وإلا بالحد الأدنى.
      quantity = cart.itemFor(p.id)?.quantity ?? p.moq;
      status = StatusRequest.success;
    } on RequestFailure catch (e) {
      notFound = e.type == RequestFailureType.notFound;
      status = StatusRequest.failure;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  bool get inCart => cart.itemFor(productId) != null;
  bool get inCompare => compare.contains(productId);

  void setQuantity(int value) {
    quantity = value;
    update();
  }

  void addToCart() {
    final p = product;
    if (p == null || !p.orderable) return;
    final wasInCart = inCart;
    cart.add(p, quantity);
    update();
    showMessage(wasInCart ? 'cartUpdated'.tr : 'addedToCart'.tr);
  }

  void toggleCompare() {
    final p = product;
    if (p == null) return;
    if (inCompare) {
      compare.remove(p.id);
      update();
      return;
    }
    switch (compare.add(p)) {
      case CompareAddResult.added:
        showMessage('addedToCompare'.trParams({'n': '${compare.items.length}'}));
      case CompareAddResult.full:
        showMessage('compareFull'.tr);
      case CompareAddResult.otherCategory:
        showMessage('compareOtherCategory'.tr);
    }
    update();
  }

  void openSupplier() => Get.toNamed(AppRoute.supplierPage, arguments: product?.supplierId);
}
