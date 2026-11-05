import '../model/cart_item_model.dart';
import '../model/order_model.dart';

/// العقد لطلبات التاجر. الآن MockOrderData، ولاحقاً RemoteOrderData.
/// عند الفشل تُرمى RequestFailure.
abstract class OrderData {
  /// إعادة التحقق من السعر والمخزون والحالة والحد الأدنى (FR-38، FR-39).
  Future<CartValidation> validateCart(List<CartItemModel> items);

  /// إنشاء عملية شراء وطلب فرعي لكل مورد في عملية واحدة (FR-41 إلى FR-43).
  /// [requestId] يمنع إنشاء الطلب مرتين عند إعادة الإرسال (FR-55).
  Future<Purchase> placeOrder(List<CartItemModel> items, {required String requestId});

  /// FR-52
  Future<List<Purchase>> purchases();
  Future<Purchase> purchase(String id);

  /// FR-50
  Future<Purchase> cancelSubOrder(String purchaseId, String subOrderId);
}
