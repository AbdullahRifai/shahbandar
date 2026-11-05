import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/order_data.dart';
import '../../data/model/order_model.dart';
import '../../data/model/request_failure.dart';
import '../../view/widget/trader/cancel_dialog.dart';

/// B15 — تفاصيل عملية الشراء وطلباتها الفرعية، وB17 حين يكون الطلب مرفوضاً أو ملغى.
/// B16 — تأكيد الإلغاء.
class PurchaseController extends GetxController {
  PurchaseController(this.purchaseId);

  final String purchaseId;
  final OrderData _orders = Get.find();

  StatusRequest status = StatusRequest.none;
  Purchase? purchase;

  /// الطلب الفرعي الجاري إلغاؤه، لإظهار التحميل على زره فقط.
  String? cancellingId;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (purchase == null) {
      status = StatusRequest.loading;
      update();
    }
    try {
      purchase = await _orders.purchase(purchaseId);
      status = StatusRequest.success;
    } catch (_) {
      if (purchase == null) status = StatusRequest.failure;
    }
    update();
  }

  Future<void> cancel(SubOrder sub) async {
    final confirmed = await showCancelDialog(sub.supplierName);
    if (!confirmed) return;
    cancellingId = sub.id;
    update();
    try {
      purchase = await _orders.cancelSubOrder(purchaseId, sub.id);
      showMessage('cancelDone'.tr);
    } on RequestFailure catch (e) {
      // قد يكون المورد قبل الطلب أثناء ظهور نافذة التأكيد.
      showMessage(e.type == RequestFailureType.notAllowed ? 'cancelTooLate'.tr : 'errorOffline'.tr);
      await load();
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    cancellingId = null;
    update();
  }
}
