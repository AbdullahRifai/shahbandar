import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../data/datasource/supplier_data.dart';
import '../../data/model/incoming_order_model.dart';
import 'supplier_shell_controller.dart';
import '../../core/services/notification_center.dart';
import '../../data/model/user_model.dart';

/// C1 — لوحة المورد: الطلبات المنتظرة، الأعداد حسب الحالة، ملخص المنتجات، آخر الطلبات.
class SupplierHomeController extends GetxController {
  final SupplierData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  SupplierDashboard? dashboard;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    // التحديث بصمت إن كانت اللوحة معروضة.
    if (status != StatusRequest.success) {
      status = StatusRequest.loading;
      update();
    }
    try {
      dashboard = await _data.dashboard();
      status = StatusRequest.success;
      Get.find<NotificationCenter>().refreshFor(UserRole.supplier);
      Get.find<SupplierShellController>().setAwaiting(dashboard!.awaiting.length);
    } catch (_) {
      if (dashboard == null) status = StatusRequest.failure;
    }
    update();
  }
}
