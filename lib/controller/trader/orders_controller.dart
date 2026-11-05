import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../data/datasource/order_data.dart';
import '../../data/model/order_model.dart';

/// فلاتر قائمة الطلبات.
enum OrdersFilter { all, active, completed, closed }

/// B14 — طلباتي (FR-52): كل عمليات الشراء، الأحدث أولاً.
class OrdersController extends GetxController {
  final OrderData _orders = Get.find();

  StatusRequest status = StatusRequest.none;
  List<Purchase> purchases = [];
  OrdersFilter filter = OrdersFilter.all;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    // التحديث بصمت إن كانت القائمة معروضة أصلاً، بلا وميض تحميل.
    if (purchases.isEmpty) {
      status = StatusRequest.loading;
      update();
    }
    try {
      purchases = await _orders.purchases();
      status = StatusRequest.success;
    } catch (_) {
      if (purchases.isEmpty) status = StatusRequest.failure;
    }
    update();
  }

  void setFilter(OrdersFilter value) {
    filter = value;
    update();
  }

  List<Purchase> get visible => purchases.where((p) {
        return switch (filter) {
          OrdersFilter.all => true,
          OrdersFilter.active =>
            p.status == PurchaseStatus.awaiting || p.status == PurchaseStatus.inProgress,
          OrdersFilter.completed => p.status == PurchaseStatus.completed,
          OrdersFilter.closed => p.status == PurchaseStatus.closed,
        };
      }).toList();

  Future<void> open(Purchase p) async {
    await Get.toNamed(AppRoute.purchase, arguments: p.id);
    load(); // قد يكون ألغى طلباً فرعياً
  }
}
