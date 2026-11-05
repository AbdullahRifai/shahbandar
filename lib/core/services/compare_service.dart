import 'package:get/get.dart';

import '../../data/model/product_model.dart';

enum CompareAddResult { added, full, otherCategory }

/// قائمة المقارنة (FR-31): من 2 إلى 4 منتجات من التصنيف نفسه.
class CompareService extends GetxController {
  static const int max = 4;

  final List<ProductModel> items = [];

  bool contains(String productId) => items.any((p) => p.id == productId);

  String? get categoryId => items.isEmpty ? null : items.first.categoryId;

  CompareAddResult add(ProductModel product) {
    if (contains(product.id)) return CompareAddResult.added;
    if (items.length >= max) return CompareAddResult.full;
    if (categoryId != null && categoryId != product.categoryId) {
      return CompareAddResult.otherCategory;
    }
    items.add(product);
    update();
    return CompareAddResult.added;
  }

  void remove(String productId) {
    items.removeWhere((p) => p.id == productId);
    update();
  }

  void clear() {
    items.clear();
    update();
  }

  /// "الأقل سعراً" يظهر فقط حين تكون كل المنتجات بعملة واحدة،
  /// لأننا لا نحوّل بين الدولار والليرة.
  String? get cheapestId {
    if (items.length < 2) return null;
    if (items.map((p) => p.currency).toSet().length > 1) return null;
    final sorted = [...items]..sort((a, b) => a.price.compareTo(b.price));
    if (sorted[0].price == sorted[1].price) return null;
    return sorted.first.id;
  }

  bool get mixedCurrencies => items.map((p) => p.currency).toSet().length > 1;
}
