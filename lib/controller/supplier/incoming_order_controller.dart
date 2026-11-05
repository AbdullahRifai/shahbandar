import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/supplier_data.dart';
import '../../data/model/incoming_order_model.dart';
import '../../data/model/order_model.dart';
import '../../data/model/request_failure.dart';
import '../../view/widget/supplier/accept_failed_dialog.dart';
import '../../view/widget/supplier/reject_sheet.dart';

/// C3 طلب وارد (قبول/رفض)، C4 الرفض، C5 فشل القبول، C6 تحديث الحالة.
/// شاشة واحدة يتغير محتواها حسب حالة الطلب.
class IncomingOrderController extends GetxController {
  IncomingOrderController(this.orderId);

  final String orderId;
  final SupplierData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  IncomingOrder? order;

  /// إجراء جارٍ (قبول، رفض، تقدّم) لإظهار التحميل على الزر ومنع الضغط المزدوج.
  bool busy = false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (order == null) {
      status = StatusRequest.loading;
      update();
    }
    try {
      order = await _data.order(orderId);
      status = StatusRequest.success;
    } catch (_) {
      if (order == null) status = StatusRequest.failure;
    }
    update();
  }

  bool get isAwaiting => order?.status == SubOrderStatus.awaiting;

  /// الخطوة التالية في C6: "بدء التجهيز" ثم "تم التسليم".
  String? get advanceLabelKey => switch (order?.status) {
        SubOrderStatus.accepted => 'startPreparing',
        SubOrderStatus.preparing => 'markDelivered',
        _ => null,
      };

  Future<void> accept() async {
    if (busy) return;
    busy = true;
    update();
    try {
      order = await _data.accept(orderId);
      showMessage('orderAccepted'.tr);
    } on AcceptFailure catch (e) {
      busy = false;
      update();
      await _onShortage(e.shortages);
      return;
    } on RequestFailure catch (e) {
      _showFailure(e);
      await load();
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    busy = false;
    update();
  }

  /// C5: لا يكفي المخزون. "تحديث المخزون" يفتح المنتج، ثم نعيد تحميل الطلب.
  Future<void> _onShortage(List<StockShortage> shortages) async {
    final choice = await showAcceptFailedDialog(orderId, shortages);
    switch (choice) {
      case AcceptFailedChoice.updateStock:
        await Get.toNamed(AppRoute.productForm, arguments: shortages.first.productId);
        await load();
      case AcceptFailedChoice.reject:
        await openReject();
      case null:
        break;
    }
  }

  /// C4
  Future<void> openReject() async {
    final reason = await showRejectSheet(orderId);
    if (reason == null) return; // تراجع
    busy = true;
    update();
    try {
      order = await _data.reject(orderId, reason: reason.isEmpty ? null : reason);
      showMessage('orderRejected'.tr);
    } on RequestFailure catch (e) {
      _showFailure(e);
      await load();
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    busy = false;
    update();
  }

  /// C6
  Future<void> advance() async {
    if (busy) return;
    busy = true;
    update();
    try {
      order = await _data.advance(orderId);
      showMessage('statusUpdated'.tr);
    } on RequestFailure catch (e) {
      _showFailure(e);
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    busy = false;
    update();
  }

  Future<void> copyPhone() async {
    final phone = order?.traderPhone ?? '';
    if (phone.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: phone));
    showMessage('copied'.tr);
  }

  void _showFailure(RequestFailure e) => showMessage(switch (e.type) {
        RequestFailureType.notAllowed => 'orderChangedMeanwhile'.tr,
        RequestFailureType.offline => 'errorOffline'.tr,
        _ => 'errorGeneric'.tr,
      });
}
