import 'product_model.dart';

/// حالات الطلب الفرعي (FR-45).
enum SubOrderStatus { awaiting, accepted, preparing, completed, rejected, cancelled }

/// سطر في الطلب: نسخة ثابتة من المنتج والسعر لحظة الطلب (FR-44).
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.visual,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String name;
  final String visual;
  final int quantity;
  final double unitPrice;

  double get total => unitPrice * quantity;
}

/// طلب فرعي لمورد واحد (FR-42).
class SubOrder {
  SubOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.currency,
    required this.lines,
    required this.createdAt,
    this.status = SubOrderStatus.awaiting,
    this.updatedAt,
    this.rejectReason,
  });

  final String id;
  final String supplierId;
  final String supplierName;
  final Currency currency;
  final List<OrderLine> lines;
  final DateTime createdAt;
  SubOrderStatus status;
  DateTime? updatedAt;
  String? rejectReason;

  double get total => lines.fold(0, (sum, l) => sum + l.total);

  /// FR-50: الإلغاء قبل قرار المورد فقط.
  bool get canCancel => status == SubOrderStatus.awaiting;

  /// انتهى بلا تنفيذ (FR-51: يبقى في السجل ولا يُعاد فتحه).
  bool get isClosed =>
      status == SubOrderStatus.rejected || status == SubOrderStatus.cancelled;
}

/// الحالة العامة لعملية الشراء، محسوبة من طلباتها الفرعية (FR-54).
enum PurchaseStatus { awaiting, inProgress, completed, closed }

/// عملية الشراء الرئيسية (FR-42).
class Purchase {
  Purchase({required this.id, required this.createdAt, required this.subOrders});

  final String id;
  final DateTime createdAt;
  final List<SubOrder> subOrders;

  PurchaseStatus get status {
    final open = subOrders.where((s) => !s.isClosed).toList();
    if (open.isEmpty) return PurchaseStatus.closed;
    if (open.every((s) => s.status == SubOrderStatus.completed)) {
      return PurchaseStatus.completed;
    }
    if (open.every((s) => s.status == SubOrderStatus.awaiting)) {
      return PurchaseStatus.awaiting;
    }
    return PurchaseStatus.inProgress;
  }

  /// المجموع لكل عملة على حدة، دون الطلبات المرفوضة والملغاة.
  Map<Currency, double> get totals {
    final result = <Currency, double>{};
    for (final s in subOrders.where((s) => !s.isClosed)) {
      result[s.currency] = (result[s.currency] ?? 0) + s.total;
    }
    return result;
  }

  bool hasStatus(SubOrderStatus status) => subOrders.any((s) => s.status == status);
}
