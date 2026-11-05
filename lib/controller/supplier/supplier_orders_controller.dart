import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../data/datasource/supplier_data.dart';
import '../../data/model/incoming_order_model.dart';
import '../../data/model/order_model.dart';
import 'supplier_shell_controller.dart';

/// فلاتر الطلبات الواردة. "مغلق" = مرفوض أو ألغاه التاجر.
enum SupplierOrdersFilter { awaiting, accepted, preparing, completed, closed }

/// C2 — الطلبات الواردة (FR-45).
/// المنتظرة: الأقدم أولاً، لأن التاجر الذي ينتظر أطول أولى بالرد. البقية: الأحدث أولاً.
class SupplierOrdersController extends GetxController {
  final SupplierData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  List<IncomingOrder> orders = [];
  SupplierOrdersFilter filter = SupplierOrdersFilter.awaiting;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (orders.isEmpty) {
      status = StatusRequest.loading;
      update();
    }
    try {
      orders = await _data.orders();
      status = StatusRequest.success;
      Get.find<SupplierShellController>().setAwaiting(countOf(SupplierOrdersFilter.awaiting));
    } catch (_) {
      if (orders.isEmpty) status = StatusRequest.failure;
    }
    update();
  }

  void setFilter(SupplierOrdersFilter value) {
    filter = value;
    update();
  }

  static bool _matches(IncomingOrder o, SupplierOrdersFilter f) => switch (f) {
        SupplierOrdersFilter.awaiting => o.status == SubOrderStatus.awaiting,
        SupplierOrdersFilter.accepted => o.status == SubOrderStatus.accepted,
        SupplierOrdersFilter.preparing => o.status == SubOrderStatus.preparing,
        SupplierOrdersFilter.completed => o.status == SubOrderStatus.completed,
        SupplierOrdersFilter.closed =>
          o.status == SubOrderStatus.rejected || o.status == SubOrderStatus.cancelled,
      };

  int countOf(SupplierOrdersFilter f) => orders.where((o) => _matches(o, f)).length;

  List<IncomingOrder> get visible {
    final list = orders.where((o) => _matches(o, filter)).toList();
    if (filter == SupplierOrdersFilter.awaiting) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return list;
  }

  void open(IncomingOrder o) => Get.find<SupplierShellController>().openOrder(o.id);
}
