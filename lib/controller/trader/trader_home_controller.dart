import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../data/datasource/catalog_data.dart';
import '../../data/datasource/order_data.dart';
import '../../data/model/option_model.dart';
import '../../data/model/order_model.dart';
import '../../data/model/product_filter.dart';
import '../../data/model/product_model.dart';
import '../../core/functions/first_where_or_null.dart';
import '../../core/services/notification_center.dart';
import '../../data/model/user_model.dart';

/// B1 — الرئيسية: التصنيفات، أحدث المنتجات، وآخر طلب مفتوح.
class TraderHomeController extends GetxController {
  final CatalogData _catalog = Get.find();
  final OrderData _orders = Get.find();

  StatusRequest status = StatusRequest.none;
  List<OptionModel> categories = [];
  List<ProductModel> newest = [];

  /// آخر عملية شراء لم تُغلق بعد، لاختصار المتابعة.
  Purchase? activePurchase;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    // عند العودة للرئيسية نحدّث بصمت، بلا مؤشر تحميل فوق محتوى معروض.
    if (status != StatusRequest.success) {
      status = StatusRequest.loading;
      update();
    }
    try {
      final results = await Future.wait([
        _catalog.categories(),
        _catalog.search(const ProductFilter(availableOnly: true)),
        _orders.purchases(),
      ]);
      categories = results[0] as List<OptionModel>;
      newest = (results[1] as List<ProductModel>).take(6).toList();
      activePurchase = firstWhereOrNull(
        results[2] as List<Purchase>,
        (p) => p.status == PurchaseStatus.awaiting || p.status == PurchaseStatus.inProgress,
      );
      status = StatusRequest.success;
      Get.find<NotificationCenter>().refreshFor(UserRole.trader);
    } catch (_) {
      if (status != StatusRequest.success) status = StatusRequest.failure;
    }
    update();
  }

  /// تحية حسب وقت اليوم.
  String get greetingKey => DateTime.now().hour < 12 ? 'goodMorning' : 'goodEvening';
}
