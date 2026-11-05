import 'package:get/get.dart';

import '../../data/datasource/admin_data.dart';
import '../../data/datasource/mock_admin_data.dart';
import '../localization/locale_controller.dart';
import 'services.dart';

/// خدمات لوحة الإدارة فقط (تُستدعى من main_admin.dart).
/// لا تحتاج سلة ولا كتالوج التطبيق.
Future<void> initialAdminServices() async {
  final services = await Get.putAsync(() => MyServices().init(), permanent: true);
  Get.put(LocaleController(), permanent: true);

  // الآن: بيانات وهمية. عند ربط الخادم يتغير هذا السطر فقط.
  Get.put<AdminData>(MockAdminData(services.prefs), permanent: true);
}
