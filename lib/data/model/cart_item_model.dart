import 'product_model.dart';

/// صنف في السلة: المنتج + الكمية (FR-33 إلى FR-37).
class CartItemModel {
  CartItemModel({required this.product, required this.quantity});

  ProductModel product;
  int quantity;

  double get total => product.price * quantity;
}

/// مشكلة في صنف اكتُشفت عند إعادة التحقق قبل الطلب (FR-38 إلى FR-40).
enum CartIssueType { outOfStock, belowMinimum, inactive }

class CartIssue {
  const CartIssue({required this.productId, required this.type, this.available = 0});

  final String productId;
  final CartIssueType type;

  /// الكمية المتوفرة الآن.
  final int available;
}

/// تغيّر سعر منتج في السلة منذ إضافته (FR-39).
class PriceChange {
  const PriceChange({
    required this.productId,
    required this.productName,
    required this.oldPrice,
    required this.newPrice,
    required this.currency,
  });

  final String productId;
  final String productName;
  final double oldPrice;
  final double newPrice;
  final Currency currency;
}

/// نتيجة إعادة التحقق من السلة.
class CartValidation {
  const CartValidation({this.issues = const [], this.priceChanges = const []});

  final List<CartIssue> issues;
  final List<PriceChange> priceChanges;

  bool get isValid => issues.isEmpty;
}
