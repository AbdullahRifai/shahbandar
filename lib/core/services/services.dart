import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasource/account_data.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/datasource/catalog_data.dart';
import '../../data/datasource/mock_account_data.dart';
import '../../data/datasource/mock_auth_data.dart';
import '../../data/datasource/media_data.dart';
import '../../data/datasource/mock_catalog_data.dart';
import '../../data/datasource/mock_media_data.dart';
import '../../data/datasource/mock_order_data.dart';
import '../../data/datasource/mock_supplier_data.dart';
import '../../data/datasource/order_data.dart';
import '../../data/datasource/supplier_data.dart';
import '../localization/locale_controller.dart';
import 'cart_service.dart';
import 'compare_service.dart';
import 'notification_center.dart';
import 'session_service.dart';

/// الإعدادات العامة غير الحساسة (اللغة...).
class MyServices extends GetxService {
  late final SharedPreferences prefs;

  Future<MyServices> init() async {
    prefs = await SharedPreferences.getInstance();
    return this;
  }
}

/// تُستدعى مرة واحدة في main قبل تشغيل التطبيق. الترتيب مهم.
Future<void> initialServices() async {
  final services = await Get.putAsync(() => MyServices().init(), permanent: true);
  Get.put(LocaleController(), permanent: true);
  Get.put(SessionService(services.prefs), permanent: true);

  // ─── مصادر البيانات ───
  // الآن: بيانات وهمية. عند ربط الخادم يتغير هذا السطر فقط.
  Get.put<AuthData>(MockAuthData(services.prefs), permanent: true);
  final catalog = MockCatalogData();
  Get.put<CatalogData>(catalog, permanent: true);
  Get.put<MediaData>(MockMediaData(), permanent: true);
  final account = MockAccountData();
  Get.put<AccountData>(account, permanent: true);
  final orders = MockOrderData(catalog, account);
  Get.put<OrderData>(orders, permanent: true);
  Get.put<SupplierData>(MockSupplierData(catalog, orders, account), permanent: true);

  // ─── حالة مشتركة بين شاشات التاجر ───
  Get.put(CartService(), permanent: true);
  Get.put(CompareService(), permanent: true);
  Get.put(NotificationCenter(), permanent: true);
}
