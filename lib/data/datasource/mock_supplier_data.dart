import 'dart:async';

import 'package:get/get.dart';

import '../../core/services/session_service.dart';
import '../model/activity_model.dart';
import '../model/incoming_order_model.dart';
import '../model/notification_model.dart';
import '../model/option_model.dart';
import '../model/order_model.dart';
import '../model/product_draft.dart';
import '../model/product_model.dart';
import '../model/request_failure.dart';
import '../model/user_model.dart';
import 'mock_account_data.dart';
import 'mock_catalog_data.dart';
import 'mock_order_data.dart';
import 'supplier_data.dart';

/// لوحة مورد وهمية، مربوطة بكتالوج التاجر وطلباته:
///   - المنتجات هي نفسها في كتالوج التاجر: أي تعديل أو إيقاف يظهر عنده فوراً.
///   - الطلبات التي يرسلها التاجر لـ"الأفق" تصل هنا، وقرار المورد يظهر عند التاجر.
///
/// الحسابات:
///   supplier@shahbandar.test ← شركة الأفق (منتجات وطلبات جاهزة)
///   أي حساب آخر بدور مورد (both@shahbandar.test، أو تاجر فعّل دور المورد من D4)
///                      ← مؤسسة النخيل (بلا منتجات، لتجربة C10)
///
/// للتجربة: طلب "مطعم بيت الشام" يطلب 220 كيس سكر خشن والمتوفر 200،
/// فيفشل قبوله (C5). حدّث المخزون من "تحديث المخزون" ثم اقبله.
class MockSupplierData implements SupplierData {
  MockSupplierData(this._catalog, this._orders, this._account);

  final MockCatalogData _catalog;
  final MockOrderData _orders;

  /// لإضافة سجل النشاط، وإشعار التاجر بقرار المورد.
  final MockAccountData _account;
  static const Duration _latency = Duration(milliseconds: 500);

  /// الطلبات الجاهزة لكل مورد، تُنشأ عند أول طلب.
  final Map<String, List<IncomingOrder>> _seeded = {};

  /// طلبات التاجر بعد تغليفها ببيانات التاجر، حتى يبقى سجل مراحلها.
  final Map<String, IncomingOrder> _fromTrader = {};

  /// supplier@shahbandar.test ← الأفق. أي حساب آخر فعّل دور المورد ← النخيل (بلا منتجات).
  String get _sid =>
      Get.find<SessionService>().currentUser?.email == MockAccountData.ofuqEmail ? 'ofuq' : 'nakheel';

  List<IncomingOrder> _all() {
    final sid = _sid;
    final seeded = _seeded.putIfAbsent(sid, () => sid == 'ofuq' ? _seed() : []);
    final live = [
      for (final sub in _orders.subOrdersFor(sid))
        _fromTrader.putIfAbsent(
          sub.id,
          () => IncomingOrder(
            sub: sub,
            traderName: 'متجرك التجريبي',
            traderArea: 'دمشق',
            traderPhone: '+963 944 000 111',
          ),
        ),
    ];
    return [...live, ...seeded]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  IncomingOrder _find(String id) {
    for (final o in _all()) {
      if (o.id == id) return o;
    }
    throw const RequestFailure(RequestFailureType.notFound);
  }

  List<ProductModel> get _mine =>
      _catalog.products.values.where((p) => p.supplierId == _sid).toList()
        ..sort((a, b) => b.addedOrder - a.addedOrder);

  // ─── الطلبات ───

  @override
  Future<SupplierDashboard> dashboard() async {
    await Future<void>.delayed(_latency);
    final all = _all();
    final products = _mine;
    final counts = <SubOrderStatus, int>{};
    for (final o in all) {
      counts[o.status] = (counts[o.status] ?? 0) + 1;
    }
    return SupplierDashboard(
      supplierName: MockCatalogData.supplierById(_sid)?.name ?? '',
      awaiting: all.where((o) => o.status == SubOrderStatus.awaiting).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      counts: counts,
      published: products.where((p) => p.active).length,
      paused: products.where((p) => !p.active).length,
      outOfStock: products.where((p) => p.active && !p.inStock).length,
      recent: all.take(3).toList(),
    );
  }

  @override
  Future<List<IncomingOrder>> orders() async {
    await Future<void>.delayed(_latency);
    return _all();
  }

  @override
  Future<IncomingOrder> order(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final o = _find(id);
    o.available = {
      for (final l in o.lines) l.productId: _catalog.products[l.productId]?.stock ?? 0,
    };
    return o;
  }

  @override
  Future<IncomingOrder> accept(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final o = _find(id);
    // قد يكون التاجر ألغاه أثناء فتح الشاشة.
    if (o.status != SubOrderStatus.awaiting) throw const RequestFailure(RequestFailureType.notAllowed);

    final shortages = <StockShortage>[];
    for (final l in o.lines) {
      final stock = _catalog.products[l.productId]?.stock ?? 0;
      if (stock < l.quantity) {
        shortages.add(StockShortage(productId: l.productId, name: l.name, available: stock, requested: l.quantity));
      }
    }
    if (shortages.isNotEmpty) throw AcceptFailure(shortages);

    // الخصم مرة واحدة لكل الأصناف معاً.
    for (final l in o.lines) {
      final p = _catalog.products[l.productId]!;
      _catalog.products[p.id] = p.copyWith(stock: p.stock - l.quantity);
    }
    o.moveTo(SubOrderStatus.accepted);
    _afterChange(o, 'act_accepted');
    return order(id);
  }

  @override
  Future<IncomingOrder> reject(String id, {String? reason}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final o = _find(id);
    if (o.status != SubOrderStatus.awaiting) throw const RequestFailure(RequestFailureType.notAllowed);
    o.moveTo(SubOrderStatus.rejected, rejectReason: reason);
    _afterChange(o, 'act_rejected');
    return o;
  }

  @override
  Future<IncomingOrder> advance(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final o = _find(id);
    final next = switch (o.status) {
      SubOrderStatus.accepted => SubOrderStatus.preparing,
      SubOrderStatus.preparing => SubOrderStatus.completed,
      _ => throw const RequestFailure(RequestFailureType.notAllowed),
    };
    o.moveTo(next);
    _afterChange(o, 'act_advanced');
    return o;
  }

  /// السجل دائماً، والإشعار للتاجر فقط إن كان الطلب من طلبات التاجر الوهمية.
  void _afterChange(IncomingOrder o, String logKey) {
    _account.log(ActivityType.order, ActivityIcon.order, logKey, {'n': o.id});
    if (!_fromTrader.containsKey(o.id)) return;
    final (kind, key) = switch (o.status) {
      SubOrderStatus.accepted => (NotificationKind.accepted, 'accepted'),
      SubOrderStatus.preparing => (NotificationKind.preparing, 'preparing'),
      SubOrderStatus.completed => (NotificationKind.completed, 'completed'),
      _ => (NotificationKind.rejected, 'rejected'),
    };
    final purchaseId = o.id.split('-').first;
    _account.notify(
      role: UserRole.trader,
      kind: kind,
      titleKey: 'n_${key}Title',
      bodyKey: 'n_${key}Body',
      params: {
        's': o.sub.supplierName,
        'n': o.id,
        'r': (o.sub.rejectReason?.isNotEmpty ?? false) ? o.sub.rejectReason! : 'noReasonGiven'.tr,
      },
      target: NotificationTarget.purchase,
      targetId: purchaseId,
    );
  }

  // ─── المنتجات ───

  @override
  Future<List<ProductModel>> myProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _mine;
  }

  @override
  Future<ProductModel> myProduct(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final p = _catalog.products[id];
    if (p == null || p.supplierId != _sid) throw const RequestFailure(RequestFailureType.notFound);
    return p;
  }

  @override
  Future<ProductModel> saveProduct(ProductDraft d) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final ProductModel saved;
    if (d.isNew) {
      final s = MockCatalogData.supplierById(_sid);
      final order = _catalog.products.values.fold<int>(0, (m, p) => p.addedOrder > m ? p.addedOrder : m) + 1;
      saved = ProductModel(
        id: 'p${DateTime.now().microsecondsSinceEpoch}',
        name: d.name,
        description: d.description,
        categoryId: d.categoryId,
        supplierId: _sid,
        supplierName: s?.name ?? '',
        supplierCity: s?.city ?? '',
        price: d.price,
        currency: d.currency,
        stock: d.stock,
        moq: d.moq,
        active: d.active,
        imageUrls: d.imageUrls,
        addedOrder: order,
      );
    } else {
      final current = await myProduct(d.id!);
      saved = current.copyWith(
        name: d.name,
        description: d.description,
        categoryId: d.categoryId,
        price: d.price,
        currency: d.currency,
        stock: d.stock,
        moq: d.moq,
        active: d.active,
        imageUrls: d.imageUrls,
      );
    }
    _catalog.products[saved.id] = saved;
    _account.log(ActivityType.account, ActivityIcon.product, 'act_productSaved', {'name': saved.name});
    return saved;
  }

  @override
  Future<ProductModel> setActive(String productId, bool active) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final p = (await myProduct(productId)).copyWith(active: active);
    _catalog.products[p.id] = p;
    return p;
  }

  @override
  Future<List<OptionModel>> categories() => _catalog.categories();

  // ─── البيانات الجاهزة لـ"الأفق" ───

  List<IncomingOrder> _seed() {
    final now = DateTime.now();
    IncomingOrder make(
      String id,
      String trader,
      String area,
      Duration ago,
      List<OrderLine> lines, {
      SubOrderStatus status = SubOrderStatus.awaiting,
      String note = '',
      String? reason,
    }) {
      final created = now.subtract(ago);
      final sub = SubOrder(
        id: id,
        supplierId: 'ofuq',
        supplierName: 'شركة الأفق للمواد الغذائية',
        currency: Currency.usd,
        lines: lines,
        createdAt: created,
        status: status,
        updatedAt: status == SubOrderStatus.awaiting ? null : created.add(const Duration(minutes: 25)),
        rejectReason: reason,
      );
      // سجل مراحل متسق مع الحالة الحالية.
      final timeline = <SubOrderStatus, DateTime>{SubOrderStatus.awaiting: created};
      const path = [SubOrderStatus.accepted, SubOrderStatus.preparing, SubOrderStatus.completed];
      if (status == SubOrderStatus.rejected) {
        timeline[SubOrderStatus.rejected] = created.add(const Duration(minutes: 25));
      } else {
        for (var i = 0; i <= path.indexOf(status); i++) {
          timeline[path[i]] = created.add(Duration(minutes: 25 + i * 300));
        }
      }
      return IncomingOrder(
        sub: sub,
        traderName: trader,
        traderArea: area,
        traderPhone: '+963 944 555 210',
        note: note,
        timeline: timeline,
      );
    }

    const oil = ('oil', 'زيت زيتون بكر ممتاز، 5 لتر', 'oil');
    const pasta = ('pasta', 'معكرونة 500 غ، كرتونة 20', 'pasta');
    const tahini = ('tahini', 'طحينة سمسم، عبوة 1 كغ', 'tahini');
    const brown = ('sugar_brown', 'سكر خشن، كيس 25 كغ', 'sugar');
    OrderLine line((String, String, String) p, int qty, double price) =>
        OrderLine(productId: p.$1, name: p.$2, visual: p.$3, quantity: qty, unitPrice: price);

    return [
      make('1045-A', 'متجر الياسمين للمواد الغذائية', 'دمشق، المزة', const Duration(minutes: 10),
          [line(oil, 20, 38.50), line(pasta, 30, 14.80), line(tahini, 24, 9.60)],
          note: 'التسليم قبل نهاية الأسبوع، والزيت في تغليف منفصل.'),
      make('1043-C', 'سوبرماركت الرضا', 'دمشق، المالكي', const Duration(minutes: 45),
          [line(oil, 20, 38.50), line(tahini, 24, 9.60)]),
      make('1044-A', 'مطعم بيت الشام', 'دمشق، باب توما', const Duration(hours: 2),
          [line(brown, 220, 15.20)],
          note: 'نحتاج الكمية كاملة لموسم الحلويات.'),
      make('1041-A', 'سوبرماركت الرضا', 'دمشق، المالكي', const Duration(days: 1),
          [line(brown, 20, 15.20), line(oil, 20, 38.50)],
          status: SubOrderStatus.accepted),
      make('1039-B', 'محمصة النخيل', 'ريف دمشق، جرمانا', const Duration(days: 2),
          [line(tahini, 48, 9.60)],
          status: SubOrderStatus.preparing),
      make('1036-B', 'مطعم بيت الشام', 'دمشق، باب توما', const Duration(days: 5),
          [line(oil, 40, 38.50), line(pasta, 30, 14.20)],
          status: SubOrderStatus.completed),
      make('1030-A', 'بقالية السلام', 'حمص، الوعر', const Duration(days: 8),
          [line(pasta, 60, 14.20)],
          status: SubOrderStatus.rejected,
          reason: 'لا نوصل إلى منطقة التاجر.'),
    ];
  }
}
