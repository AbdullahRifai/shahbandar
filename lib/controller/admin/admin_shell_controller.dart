import 'package:get/get.dart';

import '../../core/constant/app_routes.dart';
import '../../core/localization/locale_controller.dart';
import '../../data/datasource/admin_data.dart';
import '../../data/model/admin_models.dart';

/// أقسام الإدارة بترتيب الشريط الجانبي.
enum AdminSection { dashboard, users, products, orders, productCategories, bizCategories, deletions, audit }

/// هيكل لوحة الإدارة: القسم الحالي، المستخدم المفتوح (E4)، وعدّاد طلبات الحذف.
class AdminShellController extends GetxController {
  final AdminData _data = Get.find();

  AdminSection section = AdminSection.dashboard;

  /// عند فتح مستخدم من أي مكان يظهر E4 داخل قسم المستخدمين.
  String? openUserId;

  int pendingDeletions = 0;
  String email = '';

  @override
  void onInit() {
    super.onInit();
    _data.restoreSession().then((e) {
      email = e ?? '';
      update();
    });
    refreshBadge();
  }

  void go(AdminSection s) {
    section = s;
    openUserId = null;
    update();
  }

  void openUser(String id) {
    section = AdminSection.users;
    openUserId = id;
    update();
  }

  void closeUser() {
    openUserId = null;
    update();
  }

  Future<void> refreshBadge() async {
    try {
      final list = await _data.deletions();
      pendingDeletions = list.where((d) => d.state == DeletionState.pending).length;
      update();
    } catch (_) {}
  }

  void toggleLanguage() {
    final l = Get.find<LocaleController>();
    l.changeLanguage(l.isArabic ? 'en' : 'ar');
  }

  Future<void> logout() async {
    await _data.logout();
    Get.offAllNamed(AppRoute.adminLogin);
  }
}
