import 'package:get/get.dart';

import '../../core/constant/app_routes.dart';
import '../../core/services/session_service.dart';
import 'supplier_home_controller.dart';
import 'supplier_orders_controller.dart';
import 'supplier_products_controller.dart';

/// تبويبات لوحة المورد.
enum SupplierTab { home, orders, products, account }

/// هيكل لوحة المورد: التبويب الحالي، عدّاد الطلبات المنتظرة، وتسجيل الخروج.
class SupplierShellController extends GetxController {
  final SessionService _session = Get.find();

  SupplierTab tab = SupplierTab.home;

  /// عدد الطلبات بانتظار القرار، يظهر على تبويب "الطلبات".
  int awaitingCount = 0;

  String get email => _session.currentUser?.email ?? '';

  void select(SupplierTab next) {
    if (next == tab) return;
    tab = next;
    update();
    refreshTab(next);
  }

  void refreshTab(SupplierTab t) {
    switch (t) {
      case SupplierTab.home:
        Get.find<SupplierHomeController>().load();
      case SupplierTab.orders:
        Get.find<SupplierOrdersController>().load();
      case SupplierTab.products:
        Get.find<SupplierProductsController>().load();
      case SupplierTab.account:
        break;
    }
  }

  /// بعد الرجوع من شاشة طلب أو منتج: تحديث كل التبويبات بصمت.
  void refreshAll() {
    Get.find<SupplierHomeController>().load();
    Get.find<SupplierOrdersController>().load();
    Get.find<SupplierProductsController>().load();
  }

  void setAwaiting(int count) {
    if (count == awaitingCount) return;
    awaitingCount = count;
    update();
  }

  /// من بطاقات اللوحة: فتح "الطلبات" على حالة معيّنة.
  void openOrders(SupplierOrdersFilter filter) {
    Get.find<SupplierOrdersController>().setFilter(filter);
    select(SupplierTab.orders);
  }

  void openProducts() => select(SupplierTab.products);

  Future<void> openOrder(String id) async {
    await Get.toNamed(AppRoute.incomingOrder, arguments: id);
    refreshAll();
  }

  Future<void> logout() async {
    await _session.clear();
    Get.offAllNamed(AppRoute.login);
  }
}
