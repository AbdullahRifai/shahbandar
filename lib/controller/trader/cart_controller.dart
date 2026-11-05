import 'dart:math';

import 'package:get/get.dart';

import '../../core/constant/app_routes.dart';
import '../../core/services/cart_service.dart';
import '../../data/datasource/order_data.dart';
import '../../data/model/cart_item_model.dart';
import '../../data/model/order_model.dart';
import '../../data/model/request_failure.dart';

/// B9 السلة، B10 الأصناف غير الصالحة، B11 المراجعة، ثم الإرسال إلى B12 أو B13.
///
/// قبل المراجعة وقبل الإرسال نعيد التحقق من السعر والمخزون والحد الأدنى (FR-38، FR-39).
/// أي صنف فيه مشكلة يمنع المتابعة حتى يُعدَّل أو يُحذف (FR-40).
class CartController extends GetxController {
  final CartService cart = Get.find();
  final OrderData _orders = Get.find();

  bool validating = false;
  bool placing = false;
  bool validationFailed = false;

  Map<String, CartIssue> issues = {};
  List<PriceChange> priceChanges = [];

  /// معرّف ثابت لمحاولة الإرسال الحالية، حتى لا يُنشأ الطلب مرتين
  /// إن أعاد التاجر المحاولة بعد انقطاع (FR-55).
  String? _requestId;

  bool get hasIssues => issues.isNotEmpty;
  bool get canContinue => !cart.isEmpty && !hasIssues && !validating && !validationFailed;

  CartIssue? issueFor(String productId) => issues[productId];

  Future<bool> validate() async {
    if (cart.isEmpty) {
      issues = {};
      priceChanges = [];
      update();
      return false;
    }
    validating = true;
    validationFailed = false;
    update();
    try {
      final result = await _orders.validateCart(cart.items);
      issues = {for (final i in result.issues) i.productId: i};
      priceChanges = [...priceChanges, ...result.priceChanges];
      cart.update(); // الأسعار تحدّثت داخل الأصناف
    } catch (_) {
      validationFailed = true;
    }
    validating = false;
    update();
    return !validationFailed && issues.isEmpty;
  }

  void dismissPriceChanges() {
    priceChanges = [];
    update();
  }

  void setQuantity(CartItemModel item, int value) {
    cart.setQuantity(item.product.id, value);
    _resolveIfFixed(item);
  }

  void remove(String productId) {
    cart.remove(productId);
    issues.remove(productId);
    priceChanges.removeWhere((c) => c.productId == productId);
    update();
  }

  /// B10: "تعديل الكمية إلى المتوفر".
  void useAvailable(CartItemModel item) {
    final available = issues[item.product.id]?.available ?? item.product.stock;
    cart.setQuantity(item.product.id, available);
    _resolveIfFixed(item);
  }

  /// الحد الأعلى للكمية في المحدد: المخزون، ولا يقل عن الكمية الحالية حتى لا يتجمد المحدد.
  int maxFor(CartItemModel item) => max(item.product.stock, item.product.moq);

  /// المحدد يسمح بالنزول للحد الأدنى فقط.
  int minFor(CartItemModel item) => item.product.moq;

  void _resolveIfFixed(CartItemModel item) {
    final issue = issues[item.product.id];
    if (issue != null &&
        issue.type == CartIssueType.belowMinimum &&
        item.quantity <= issue.available &&
        item.quantity >= item.product.moq) {
      issues.remove(item.product.id);
    }
    update();
  }

  /// هل يمكن حل المشكلة بتعديل الكمية؟ (المتوفر لا يقل عن الحد الأدنى)
  bool canUseAvailable(CartIssue issue, CartItemModel item) =>
      issue.type == CartIssueType.belowMinimum && issue.available >= item.product.moq;

  /// B9 ← B11
  Future<void> goToReview() async {
    final ok = await validate();
    if (!ok) return;
    _requestId = 'req-${DateTime.now().microsecondsSinceEpoch}';
    Get.toNamed(AppRoute.orderReview);
  }

  /// B11 ← B12 أو B13. وتُستدعى أيضاً من "إعادة المحاولة" في B13.
  Future<void> placeOrder() async {
    if (placing) return;
    placing = true;
    update();
    _requestId ??= 'req-${DateTime.now().microsecondsSinceEpoch}';
    try {
      final Purchase purchase = await _orders.placeOrder(cart.items, requestId: _requestId!);
      cart.clear();
      issues = {};
      priceChanges = [];
      _requestId = null;
      placing = false;
      update();
      Get.offNamed(AppRoute.orderSent, arguments: purchase);
    } on RequestFailure catch (e) {
      placing = false;
      update();
      _toFailed(e.type);
    } catch (_) {
      placing = false;
      update();
      _toFailed(RequestFailureType.unknown);
    }
  }

  void _toFailed(RequestFailureType type) {
    if (Get.currentRoute == AppRoute.orderFailed) return; // نبقى في نفس الشاشة عند فشل إعادة المحاولة
    Get.offNamed(AppRoute.orderFailed, arguments: type);
  }

  /// من B13: الرجوع للسلة دون فقدان شيء.
  void backToCart() => Get.back();
}
