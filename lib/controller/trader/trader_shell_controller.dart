import 'package:get/get.dart';

import '../../core/constant/app_routes.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/compare_service.dart';
import '../../core/services/session_service.dart';
import 'cart_controller.dart';
import 'orders_controller.dart';
import 'trader_home_controller.dart';
import 'trader_search_controller.dart';

/// تبويبات لوحة التاجر.
enum TraderTab { home, search, cart, orders, account }

/// هيكل لوحة التاجر: التبويب الحالي، والتنقل بين التبويبات، وتسجيل الخروج.
class TraderShellController extends GetxController {
  final SessionService _session = Get.find();

  TraderTab tab = TraderTab.home;

  String get email => _session.currentUser?.email ?? '';

  void select(TraderTab next) {
    if (next == tab) return;
    tab = next;
    update();
    // كل مرة تُفتح السلة نتحقق من الأسعار والمخزون (FR-38).
    if (next == TraderTab.cart) Get.find<CartController>().validate();
    if (next == TraderTab.orders) Get.find<OrdersController>().load();
    if (next == TraderTab.home) Get.find<TraderHomeController>().load();
  }

  /// من حقل البحث في الرئيسية: الانتقال لتبويب البحث مع فتح لوحة المفاتيح.
  void openSearch() {
    select(TraderTab.search);
    Get.find<TraderSearchController>().focusSearch();
  }

  void openOrders() => select(TraderTab.orders);

  /// العودة للرئيسية من شاشة نجاح الطلب.
  void goHome() {
    Get.until((route) => route.settings.name == AppRoute.traderHome);
    if (tab == TraderTab.home) {
      Get.find<TraderHomeController>().load(); // لإظهار الطلب الجديد
    } else {
      select(TraderTab.home);
    }
  }

  Future<void> logout() async {
    Get.find<CartService>().clear();
    Get.find<CompareService>().clear();
    await _session.clear();
    Get.offAllNamed(AppRoute.login);
  }
}
