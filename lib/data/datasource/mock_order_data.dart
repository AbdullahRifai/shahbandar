import 'dart:async';

import '../../core/functions/format_money.dart';
import '../model/activity_model.dart';
import '../model/cart_item_model.dart';
import '../model/notification_model.dart';
import '../model/order_model.dart';
import '../model/product_model.dart';
import '../model/request_failure.dart';
import '../model/user_model.dart';
import 'mock_account_data.dart';
import 'mock_catalog_data.dart';
import 'order_data.dart';

/// طلبات وهمية في الذاكرة (تُمسح عند إغلاق التطبيق).
///
/// للتجربة:
///   - فتح السلة وفيها المعكرونة ← يتغير سعرها مرة واحدة (B9).
///   - طلب الرز البسمتي ← مخزونه ينخفض إلى 5 عند التحقق (B10).
///   - أي سطر كميته 13 بالضبط ← يفشل الإرسال كأن الاتصال انقطع (B13).
///   - بعد 20 ثانية من الإرسال يقبل أول مورد طلبه، لترى تغيّر الحالة.
class MockOrderData implements OrderData {
  MockOrderData(this._catalog, this._account);

  final MockCatalogData _catalog;

  /// لإضافة الإشعارات وسجل النشاط عند كل حدث.
  final MockAccountData _account;
  static const Duration _latency = Duration(milliseconds: 800);

  final List<Purchase> _purchases = _seed();
  final Map<String, Purchase> _byRequest = {};
  bool _pastaPriceChanged = false;
  int _nextId = 1043;

  @override
  Future<CartValidation> validateCart(List<CartItemModel> items) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final issues = <CartIssue>[];
    final changes = <PriceChange>[];

    for (final item in items) {
      var live = _catalog.products[item.product.id];
      if (live == null || !live.active) {
        issues.add(CartIssue(productId: item.product.id, type: CartIssueType.inactive));
        continue;
      }

      // محاكاة: المورد رفع سعر المعكرونة بعد أن أضافها التاجر.
      if (live.id == 'pasta' && !_pastaPriceChanged) {
        _pastaPriceChanged = true;
        live = live.copyWith(price: 14.80);
        _catalog.products[live.id] = live;
      }
      // محاكاة: مخزون الرز انخفض لأن تاجراً آخر سبقك.
      if (live.id == 'rice' && live.stock > 5) {
        live = live.copyWith(stock: 5);
        _catalog.products[live.id] = live;
      }

      if (live.price != item.product.price) {
        changes.add(PriceChange(
          productId: live.id,
          productName: live.name,
          oldPrice: item.product.price,
          newPrice: live.price,
          currency: live.currency,
        ));
        _account.notify(
          role: UserRole.trader,
          kind: NotificationKind.priceChanged,
          titleKey: 'n_priceTitle',
          bodyKey: 'n_priceBody',
          params: {
            'name': live.name,
            'old': formatMoney(item.product.price, live.currency),
            'new': formatMoney(live.price, live.currency),
          },
          target: NotificationTarget.cart,
        );
      }
      if (!live.inStock) {
        issues.add(CartIssue(productId: live.id, type: CartIssueType.outOfStock));
      } else if (live.stock < live.moq || live.stock < item.quantity) {
        issues.add(CartIssue(
          productId: live.id,
          type: CartIssueType.belowMinimum,
          available: live.stock,
        ));
      }
      item.product = live; // السلة تعرض القيم الحالية دائماً.
    }
    return CartValidation(issues: issues, priceChanges: changes);
  }

  @override
  Future<Purchase> placeOrder(List<CartItemModel> items, {required String requestId}) async {
    await Future<void>.delayed(_latency);

    // FR-55: نفس الطلب مرة ثانية ← نعيد العملية الموجودة بدل إنشاء جديدة.
    final existing = _byRequest[requestId];
    if (existing != null) return existing;
    if (items.any((i) => i.quantity == 13)) {
      throw const RequestFailure(RequestFailureType.offline);
    }

    final now = DateTime.now();
    final id = '${_nextId++}';
    final bySupplier = <String, List<CartItemModel>>{};
    for (final item in items) {
      bySupplier.putIfAbsent(item.product.supplierId, () => []).add(item);
    }

    var letter = 'A'.codeUnitAt(0);
    final purchase = Purchase(
      id: id,
      createdAt: now,
      subOrders: [
        for (final entry in bySupplier.entries)
          SubOrder(
            id: '$id-${String.fromCharCode(letter++)}',
            supplierId: entry.key,
            supplierName: entry.value.first.product.supplierName,
            currency: entry.value.first.product.currency,
            createdAt: now,
            lines: [
              for (final i in entry.value)
                OrderLine(
                  productId: i.product.id,
                  name: i.product.name,
                  visual: i.product.visual,
                  quantity: i.quantity,
                  unitPrice: i.product.price,
                ),
            ],
          ),
      ],
    );
    _purchases.insert(0, purchase);
    _byRequest[requestId] = purchase;
    _account.log(ActivityType.order, ActivityIcon.order, 'act_orderSent',
        {'n': purchase.id, 'k': '${purchase.subOrders.length}'});
    // طلبات "الأفق" تصل للوحة المورد الوهمية مع إشعار.
    for (final sub in purchase.subOrders.where((s) => s.supplierId == 'ofuq')) {
      _account.notify(
        role: UserRole.supplier,
        kind: NotificationKind.newOrder,
        titleKey: 'n_newOrderTitle',
        bodyKey: 'n_newOrderBody',
        params: {'t': 'متجرك التجريبي', 'n': sub.id},
        target: NotificationTarget.incomingOrder,
        targetId: sub.id,
      );
    }

    // محاكاة قرار مورد بعد 20 ثانية. طلبات "الأفق" لا تُقبل تلقائياً،
    // لأنها تصل للوحة المورد (supplier@shahbandar.test) ليقرر فيها بنفسه.
    Timer(const Duration(seconds: 20), () {
      for (final sub in purchase.subOrders) {
        if (sub.supplierId != 'ofuq' && sub.status == SubOrderStatus.awaiting) {
          sub.status = SubOrderStatus.accepted;
          sub.updatedAt = DateTime.now();
          _account.notify(
            role: UserRole.trader,
            kind: NotificationKind.accepted,
            titleKey: 'n_acceptedTitle',
            bodyKey: 'n_acceptedBody',
            params: {'s': sub.supplierName, 'n': sub.id},
            target: NotificationTarget.purchase,
            targetId: purchase.id,
          );
          break;
        }
      }
    });
    return purchase;
  }

  @override
  Future<List<Purchase>> purchases() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_purchases);
  }

  @override
  Future<Purchase> purchase(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _find(id);
  }

  @override
  Future<Purchase> cancelSubOrder(String purchaseId, String subOrderId) async {
    await Future<void>.delayed(_latency);
    final purchase = _find(purchaseId);
    final sub = purchase.subOrders.firstWhere(
      (s) => s.id == subOrderId,
      orElse: () => throw const RequestFailure(RequestFailureType.notFound),
    );
    // قد يكون المورد قبل أثناء ظهور نافذة التأكيد.
    if (!sub.canCancel) throw const RequestFailure(RequestFailureType.notAllowed);
    sub.status = SubOrderStatus.cancelled;
    _account.log(ActivityType.order, ActivityIcon.cancel, 'act_orderCancelled', {'n': sub.id});
    sub.updatedAt = DateTime.now();
    return purchase;
  }

  /// للوحة المورد الوهمية: الطلبات الفرعية التي أرسلها التاجر لهذا المورد.
  /// الكائن نفسه مشترك، فقبول المورد أو رفضه يظهر فوراً عند التاجر.
  List<SubOrder> subOrdersFor(String supplierId) => [
        for (final p in _purchases)
          for (final s in p.subOrders)
            if (s.supplierId == supplierId) s,
      ];

  Purchase _find(String id) => _purchases.firstWhere(
        (p) => p.id == id,
        orElse: () => throw const RequestFailure(RequestFailureType.notFound),
      );

  static List<Purchase> _seed() {
    final d1038 = DateTime(2026, 10, 22, 10, 30);
    final d1031 = DateTime(2026, 10, 15, 9, 10);
    return [
      Purchase(id: '1038', createdAt: d1038, subOrders: [
        SubOrder(
          id: '1038-A',
          supplierId: 'sham',
          supplierName: 'مجموعة الشام للتوريدات',
          currency: Currency.usd,
          createdAt: d1038,
          updatedAt: DateTime(2026, 10, 25, 14, 0),
          status: SubOrderStatus.completed,
          lines: const [
            OrderLine(productId: 'sugar_sham', name: 'سكر أبيض ناعم، كيس 50 كغ', visual: 'sugar', quantity: 15, unitPrice: 28.50),
            OrderLine(productId: 'bags', name: 'أكياس تغليف، 10 كغ', visual: 'bag', quantity: 3, unitPrice: 15.00),
          ],
        ),
      ]),
      Purchase(id: '1031', createdAt: d1031, subOrders: [
        SubOrder(
          id: '1031-A',
          supplierId: 'noor',
          supplierName: 'مؤسسة النور للتجارة',
          currency: Currency.usd,
          createdAt: d1031,
          updatedAt: DateTime(2026, 10, 15, 14, 5),
          status: SubOrderStatus.rejected,
          rejectReason: 'الكمية المطلوبة غير متوفرة حالياً. نتوقع وصول شحنة جديدة بعد أسبوع.',
          lines: const [
            OrderLine(productId: 'sugar_noor', name: 'سكر أبيض ناعم، كيس 50 كغ', visual: 'sugar', quantity: 20, unitPrice: 27.00),
          ],
        ),
        SubOrder(
          id: '1031-B',
          supplierId: 'ofuq',
          supplierName: 'شركة الأفق للمواد الغذائية',
          currency: Currency.usd,
          createdAt: d1031,
          updatedAt: DateTime(2026, 10, 15, 10, 20),
          status: SubOrderStatus.cancelled,
          lines: const [
            OrderLine(productId: 'tahini', name: 'طحينة سمسم، عبوة 1 كغ', visual: 'tahini', quantity: 24, unitPrice: 9.60),
          ],
        ),
      ]),
    ];
  }
}
