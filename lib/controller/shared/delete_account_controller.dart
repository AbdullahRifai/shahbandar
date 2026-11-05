import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/show_message.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/account_data.dart';
import '../../data/datasource/order_data.dart';
import '../../data/datasource/supplier_data.dart';
import '../../data/model/activity_model.dart';
import '../../data/model/order_model.dart';
import '../../data/model/user_model.dart';

/// D6 — طلب حذف الحساب (FR-60).
/// لا يُحذف شيء فوراً: يُرسل طلب يراجعه الأدمن، ويبقى الحساب يعمل حتى الموافقة.
/// إن كانت هناك طلبات مفتوحة نُنبّه أن الحذف يتأجل حتى تُغلق.
/// الإرسال يحتاج تأكيد "أفهم أن الحذف نهائي".
class DeleteAccountController extends GetxController {
  final AccountData _data = Get.find();
  final SessionService _session = Get.find();

  StatusRequest status = StatusRequest.none;
  DeletionRequest? request;

  /// أرقام الطلبات الفرعية المفتوحة (كتاجر أو كمورد).
  List<String> openOrders = [];

  final reason = TextEditingController();
  bool understood = false;
  bool busy = false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      request = await _data.deletionRequest();
      openOrders = await _openOrders();
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  Future<List<String>> _openOrders() async {
    final roles = _session.currentUser?.roles ?? {};
    final ids = <String>[];
    const open = {SubOrderStatus.awaiting, SubOrderStatus.accepted, SubOrderStatus.preparing};
    if (roles.contains(UserRole.trader)) {
      for (final p in await Get.find<OrderData>().purchases()) {
        ids.addAll(p.subOrders.where((s) => open.contains(s.status)).map((s) => s.id));
      }
    }
    if (roles.contains(UserRole.supplier)) {
      for (final o in await Get.find<SupplierData>().orders()) {
        if (open.contains(o.status)) ids.add(o.id);
      }
    }
    return ids;
  }

  void setUnderstood(bool? v) {
    understood = v ?? false;
    update();
  }

  bool get canSubmit => understood && !busy;

  Future<void> submit() async {
    if (!canSubmit) return;
    busy = true;
    update();
    try {
      request = await _data.requestDeletion(reason.text.trim());
      showMessage('deletionSent'.tr);
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    busy = false;
    update();
  }

  Future<void> cancelRequest() async {
    busy = true;
    update();
    try {
      await _data.cancelDeletion();
      request = null;
      understood = false;
      showMessage('deletionCancelled'.tr);
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    busy = false;
    update();
  }

  @override
  void onClose() {
    reason.dispose();
    super.onClose();
  }
}
