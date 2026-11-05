import 'order_model.dart';
import 'product_model.dart';

/// طلب وارد كما يراه المورد: الطلب الفرعي نفسه + بيانات التاجر + سجل المراحل.
/// [sub] هو نفس كائن الطلب الفرعي عند التاجر، فأي تغيير هنا يظهر عنده.
class IncomingOrder {
  IncomingOrder({
    required this.sub,
    required this.traderName,
    required this.traderArea,
    this.traderPhone = '',
    this.note = '',
    Map<SubOrderStatus, DateTime>? timeline,
  }) : timeline = timeline ?? {SubOrderStatus.awaiting: sub.createdAt};

  final SubOrder sub;
  final String traderName;
  final String traderArea;
  final String traderPhone;

  /// ملاحظة التاجر مع الطلب (اختيارية).
  final String note;

  /// وقت الوصول لكل مرحلة (C6).
  final Map<SubOrderStatus, DateTime> timeline;

  /// المخزون الحالي لكل منتج في الطلب، يُملأ عند فتح الطلب (C3: "المتوفر 340").
  Map<String, int> available = {};

  String get id => sub.id;
  SubOrderStatus get status => sub.status;
  DateTime get createdAt => sub.createdAt;
  Currency get currency => sub.currency;
  List<OrderLine> get lines => sub.lines;
  double get total => sub.total;

  /// هل يكفي المخزون لهذا السطر؟ (null = لم يُحمَّل بعد)
  bool? hasStock(OrderLine line) {
    final a = available[line.productId];
    return a == null ? null : a >= line.quantity;
  }

  void moveTo(SubOrderStatus status, {String? rejectReason}) {
    final now = DateTime.now();
    sub
      ..status = status
      ..updatedAt = now
      ..rejectReason = rejectReason ?? sub.rejectReason;
    timeline[status] = now;
  }
}

/// صنف لا يكفي مخزونه لقبول الطلب (C5).
class StockShortage {
  const StockShortage({
    required this.productId,
    required this.name,
    required this.available,
    required this.requested,
  });

  final String productId;
  final String name;
  final int available;
  final int requested;
}

/// يُرمى من accept() حين لا يكفي المخزون. لا يُخصم شيء (FR-47).
class AcceptFailure implements Exception {
  const AcceptFailure(this.shortages);

  final List<StockShortage> shortages;
}

/// ملخص لوحة المورد (C1).
class SupplierDashboard {
  const SupplierDashboard({
    required this.supplierName,
    required this.awaiting,
    required this.counts,
    required this.published,
    required this.paused,
    required this.outOfStock,
    required this.recent,
  });

  final String supplierName;

  /// الطلبات بانتظار القرار، الأقدم أولاً.
  final List<IncomingOrder> awaiting;
  final Map<SubOrderStatus, int> counts;
  final int published;
  final int paused;
  final int outOfStock;
  final List<IncomingOrder> recent;

  int countOf(SubOrderStatus s) => counts[s] ?? 0;
}
