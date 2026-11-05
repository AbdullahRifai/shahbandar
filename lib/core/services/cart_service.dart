import 'package:get/get.dart';

import '../../data/model/cart_item_model.dart';
import '../../data/model/product_model.dart';
import '../functions/first_where_or_null.dart';

/// سلة التاجر (FR-33 إلى FR-37). متاحة من أي شاشة، والعدّاد على أيقونة السلة يتحدث تلقائياً.
///
/// في هذه المرحلة السلة في الذاكرة فقط. عند ربط الخادم تُحفظ في حسابه،
/// ويبقى شكل هذه الخدمة كما هو.
class CartService extends GetxController {
  final List<CartItemModel> items = [];

  bool get isEmpty => items.isEmpty;

  /// عدد الأصناف (لا مجموع الكميات)، لعدّاد الأيقونة.
  int get count => items.length;

  /// الأصناف مجمّعة حسب المورد بترتيب إضافتها، لأن كل مورد يصله طلب منفصل (FR-42).
  Map<String, List<CartItemModel>> get bySupplier {
    final result = <String, List<CartItemModel>>{};
    for (final item in items) {
      result.putIfAbsent(item.product.supplierId, () => []).add(item);
    }
    return result;
  }

  int get supplierCount => bySupplier.length;

  /// المجموع لكل عملة على حدة، بلا تحويل.
  Map<Currency, double> get totals {
    final result = <Currency, double>{};
    for (final item in items) {
      result[item.product.currency] = (result[item.product.currency] ?? 0) + item.total;
    }
    return result;
  }

  CartItemModel? itemFor(String productId) =>
      firstWhereOrNull(items, (i) => i.product.id == productId);

  /// إضافة منتج، أو تعديل كميته إن كان في السلة أصلاً.
  void add(ProductModel product, int quantity) {
    final existing = itemFor(product.id);
    if (existing != null) {
      existing
        ..product = product
        ..quantity = quantity;
    } else {
      items.add(CartItemModel(product: product, quantity: quantity));
    }
    update();
  }

  void setQuantity(String productId, int quantity) {
    itemFor(productId)?.quantity = quantity;
    update();
  }

  void remove(String productId) {
    items.removeWhere((i) => i.product.id == productId);
    update();
  }

  void clear() {
    items.clear();
    update();
  }
}
