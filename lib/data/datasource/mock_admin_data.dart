import 'package:shared_preferences/shared_preferences.dart';

import '../model/admin_models.dart';
import '../model/auth_failure.dart';
import '../model/order_model.dart';
import '../model/product_model.dart';
import '../model/request_failure.dart';
import '../model/user_model.dart';
import 'admin_data.dart';

/// بيانات وهمية للوحة الإدارة، مستقلة عن بيانات التطبيق
/// (لوحة الويب تعمل كبرنامج منفصل، فلا تشارك ذاكرة الهاتف).
///
/// الدخول: admin@shahbandar.test بأي كلمة مرور ما عدا "wrong".
/// أي بريد آخر يُرفض، فلا تسجيل ذاتي للإدارة.
///
/// للتجربة:
///   - "رامي سليمان" عنده طلب مفتوح، فزر "موافقة وحذف" معطّل (E9).
///   - كل إيقاف أو إخفاء أو تعديل تصنيف يظهر فوراً في سجل التدقيق (E10).
class MockAdminData implements AdminData {
  MockAdminData(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'admin_email';
  static const String adminEmail = 'admin@shahbandar.test';
  static const Duration _latency = Duration(milliseconds: 450);

  final List<AdminUser> _users = _seedUsers();
  final List<AdminProduct> _products = _seedProducts();
  final List<AdminOrder> _orders = _seedOrders();
  final Map<CategoryKind, List<AdminCategory>> _categories = {
    CategoryKind.product: _seedProductCategories(),
    CategoryKind.business: _seedBusinessCategories(),
  };
  final List<AdminDeletion> _deletions = _seedDeletions();
  final List<AuditEntry> _audit = _seedAudit();
  int _ids = 500;

  String get _actor => _prefs.getString(_key) ?? adminEmail;

  void _log(String actionKey, String entity, {AuditType type = AuditType.admin}) {
    _audit.insert(0, AuditEntry(at: DateTime.now(), actor: _actor, actionKey: actionKey, entity: entity, type: type));
  }

  // ─── E1 ───

  @override
  Future<String> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final mail = email.trim().toLowerCase();
    if (mail != adminEmail || password == 'wrong') {
      _audit.insert(
        0,
        AuditEntry(
          at: DateTime.now(),
          actor: mail.isEmpty ? '—' : mail,
          actionKey: 'au_adminLoginFailed',
          entity: 'au_adminPanel',
          type: AuditType.login,
          result: AuditResult.failed,
        ),
      );
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    await _prefs.setString(_key, mail);
    _log('au_adminLogin', 'au_adminPanel', type: AuditType.login);
    return mail;
  }

  @override
  Future<String?> restoreSession() async => _prefs.getString(_key);

  @override
  Future<void> logout() async {
    _log('au_adminLogout', 'au_adminPanel', type: AuditType.login);
    await _prefs.remove(_key);
  }

  // ─── E2 ───

  @override
  Future<AdminStats> stats() async {
    await Future<void>.delayed(_latency);
    final byStatus = <SubOrderStatus, int>{for (final s in SubOrderStatus.values) s: 0};
    for (final o in _orders) {
      byStatus[o.status] = byStatus[o.status]! + 1;
    }
    return AdminStats(
      traders: _users.where((u) => !u.bothRoles && u.roles.contains(UserRole.trader)).length,
      suppliers: _users.where((u) => !u.bothRoles && u.roles.contains(UserRole.supplier)).length,
      both: _users.where((u) => u.bothRoles).length,
      activeProducts: _products.where((p) => p.status == AdminProductStatus.published).length,
      hiddenProducts: _products.where((p) => p.status != AdminProductStatus.published).length,
      pendingDeletions: _deletions.where((d) => d.state == DeletionState.pending).length,
      disabledUsers: _users.where((u) => u.status == AdminUserStatus.disabled).length,
      ordersByStatus: byStatus,
      updatedAt: DateTime.now(),
    );
  }

  // ─── E3 / E4 ───

  @override
  Future<List<AdminUser>> users() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_users);
  }

  @override
  Future<AdminUser> user(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _users.firstWhere((u) => u.id == id,
        orElse: () => throw const RequestFailure(RequestFailureType.notFound));
  }

  @override
  Future<AdminUser> setUserStatus(String id, AdminUserStatus status, {String reason = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final u = await user(id);
    u
      ..status = status
      ..disableReason = status == AdminUserStatus.disabled ? reason : '';
    _log(status == AdminUserStatus.disabled ? 'au_disableUser' : 'au_enableUser', u.name);
    return u;
  }

  // ─── E5 ───

  @override
  Future<List<AdminProduct>> products() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_products);
  }

  @override
  Future<AdminProduct> setProductHidden(String id, bool hidden) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final p = _products.firstWhere((p) => p.id == id,
        orElse: () => throw const RequestFailure(RequestFailureType.notFound));
    p.status = hidden ? AdminProductStatus.hiddenByAdmin : AdminProductStatus.published;
    _log(hidden ? 'au_hideProduct' : 'au_showProduct', p.name);
    return p;
  }

  // ─── E6 ───

  @override
  Future<List<AdminOrder>> orders() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_orders);
  }

  // ─── E7 / E8 ───

  @override
  Future<List<AdminCategory>> categories(CategoryKind kind) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_categories[kind]!);
  }

  @override
  Future<AdminCategory> saveCategory(CategoryKind kind, AdminCategory c) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final list = _categories[kind]!;
    final i = list.indexWhere((x) => x.id == c.id);
    final AdminCategory saved;
    if (i >= 0) {
      list[i]
        ..ar = c.ar
        ..en = c.en
        ..parentId = c.parentId;
      saved = list[i];
      _log(kind == CategoryKind.product ? 'au_editProductCategory' : 'au_editBizCategory', c.ar);
    } else {
      saved = AdminCategory(id: 'c${_ids++}', ar: c.ar, en: c.en, parentId: c.parentId);
      list.add(saved);
      _log(kind == CategoryKind.product ? 'au_addProductCategory' : 'au_addBizCategory', c.ar);
    }
    return saved;
  }

  @override
  Future<AdminCategory> setCategoryActive(CategoryKind kind, String id, bool active) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final c = _categories[kind]!.firstWhere((x) => x.id == id,
        orElse: () => throw const RequestFailure(RequestFailureType.notFound));
    c.active = active;
    _log(active ? 'au_enableCategory' : 'au_disableCategory', c.ar);
    return c;
  }

  // ─── E9 ───

  @override
  Future<List<AdminDeletion>> deletions() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_deletions);
  }

  AdminDeletion _deletion(String id) => _deletions.firstWhere((d) => d.id == id,
      orElse: () => throw const RequestFailure(RequestFailureType.notFound));

  @override
  Future<AdminDeletion> approveDeletion(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final d = _deletion(id);
    if (!d.canApprove) throw const RequestFailure(RequestFailureType.notAllowed);
    d.state = DeletionState.done;
    for (final u in _users.where((u) => u.id == d.userId)) {
      u.deletionRequested = false;
      u.status = AdminUserStatus.disabled;
    }
    _log('au_approveDeletion', d.name);
    return d;
  }

  @override
  Future<AdminDeletion> postponeDeletion(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final d = _deletion(id)..state = DeletionState.postponed;
    _log('au_postponeDeletion', d.name);
    return d;
  }

  // ─── E10 ───

  @override
  Future<List<AuditEntry>> audit() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_audit);
  }

  // ─── البيانات الجاهزة ───

  static DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) =>
      DateTime.now().subtract(Duration(days: days, hours: hours, minutes: minutes));

  static List<AdminUser> _seedUsers() {
    const t = {UserRole.trader}, s = {UserRole.supplier}, b = {UserRole.trader, UserRole.supplier};
    AdminUser u(String id, String name, String biz, String email, Set<UserRole> roles, DateTime joined,
            {AdminUserStatus status = AdminUserStatus.active,
            bool deletion = false,
            String type = 'بقالة ومواد غذائية',
            String city = 'دمشق',
            int purchases = 0,
            int open = 0,
            String reason = ''}) =>
        AdminUser(
          id: id,
          name: name,
          businessName: biz,
          email: email,
          roles: roles,
          joinedAt: joined,
          status: status,
          deletionRequested: deletion,
          emailVerifiedAt: joined.add(const Duration(minutes: 12)),
          lastLoginAt: _ago(hours: id.length + 3),
          businessType: type,
          city: city,
          phone: '+963 944 ${id.hashCode.abs() % 900 + 100} 456',
          purchases: purchases,
          openOrders: open,
          disableReason: reason,
          recent: [
            ('أرسل عملية الشراء #1042', _ago(hours: 5)),
            ('عدّل الملف التجاري', _ago(days: 1, hours: 2)),
            ('ألغى الطلب #1031-B', _ago(days: 1, hours: 10)),
          ],
        );

    return [
      u('u1', 'أحمد الخطيب', 'متجر الياسمين للمواد الغذائية', 'yasmeen.store@example.com', t, DateTime(2026, 10, 29),
          city: 'دمشق، المزة', purchases: 3, open: 1),
      u('u2', 'سارة المصري', 'شركة الأفق للمواد الغذائية', 'alofuq.foods@example.com', s, DateTime(2024, 3, 3),
          type: 'توزيع بالجملة'),
      u('u3', 'محمد العلي', 'مؤسسة النور للتجارة', 'm.ali@example.com', b, DateTime(2025, 6, 17),
          status: AdminUserStatus.disabled, type: 'توزيع بالجملة', reason: 'بلاغات متكررة عن طلبات وهمية.'),
      u('u4', 'ليلى حداد', 'مخبز السنابل', 'layla.h@example.com', t, DateTime(2026, 9, 2),
          deletion: true, type: 'مخبز وحلويات', purchases: 7),
      u('u5', 'خالد الحمصي', 'شركة الواحة للورقيات', 'alwaha.paper@example.com', s, DateTime(2026, 10, 27),
          type: 'توزيع بالجملة', city: 'حمص'),
      u('u6', 'رامي سليمان', 'مطعم بيت الشام', 'beit.alsham@example.com', t, DateTime(2025, 1, 11),
          deletion: true, type: 'مطعم أو مقهى', purchases: 12, open: 1),
      u('u7', 'نور الدين قاسم', 'سوبرماركت الرضا', 'alrida.market@example.com', t, DateTime(2025, 11, 4),
          city: 'دمشق، المالكي', purchases: 9),
      u('u8', 'هبة الشامي', 'مجموعة الشام للتوريدات', 'alsham.supply@example.com', s, DateTime(2024, 8, 20),
          type: 'توزيع بالجملة', city: 'حلب'),
      u('u9', 'باسل يوسف', 'محمصة النخيل', 'nakheel.roast@example.com', b, DateTime(2026, 2, 14),
          type: 'محمصة ومكسرات', city: 'ريف دمشق', purchases: 4),
      u('u10', 'ريم عيسى', 'صيدلية الشفاء', 'shifa.pharma@example.com', t, DateTime(2026, 5, 30),
          type: 'صيدلية', city: 'حماة', purchases: 2),
      u('u11', 'عمر درويش', 'بقالية السلام', 'salam.grocery@example.com', t, DateTime(2026, 7, 8),
          city: 'حمص، الوعر', purchases: 1),
    ];
  }

  static List<AdminProduct> _seedProducts() {
    AdminProduct p(String id, String name, String sup, String supId, String cat, double price, Currency cur,
            int stock, int moq, String visual,
            {AdminProductStatus status = AdminProductStatus.published, int images = 3, String desc = ''}) =>
        AdminProduct(
          id: id,
          name: name,
          supplier: sup,
          supplierUserId: supId,
          category: cat,
          price: price,
          currency: cur,
          stock: stock,
          moq: moq,
          images: images,
          updatedAt: _ago(days: id.length + 2),
          description: desc,
          visual: visual,
          status: status,
        );
    return [
      p('274', 'زيت زيتون بكر ممتاز، 5 لتر', 'شركة الأفق', 'u2', 'زيوت وسمون', 38.50, Currency.usd, 340, 20, 'oil',
          desc: 'زيت زيتون بكر ممتاز معصور على البارد، حموضة منخفضة.'),
      p('275', 'سكر أبيض ناعم، 50 كغ', 'مؤسسة النور', 'u3', 'مواد غذائية', 27.00, Currency.usd, 350, 10, 'sugar'),
      p('276', 'رز بسمتي، 25 كغ', 'مجموعة الشام', 'u8', 'حبوب وبقوليات', 1150000, Currency.syp, 80, 10, 'rice'),
      p('277', 'معكرونة 500 غ، كرتونة 20', 'شركة الأفق', 'u2', 'مواد غذائية', 14.80, Currency.usd, 120, 30, 'pasta',
          status: AdminProductStatus.pausedBySupplier),
      p('278', 'أكياس تغليف، 10 كغ', 'مؤسسة النور', 'u3', 'تغليف', 12.00, Currency.usd, 150, 10, 'bag',
          status: AdminProductStatus.hiddenByAdmin, images: 1),
      p('279', 'مناديل ورقية، كرتونة 48 علبة', 'شركة الواحة', 'u5', 'ورقيات', 245000, Currency.syp, 400, 25, 'tissue'),
      p('280', 'طحينة سمسم، عبوة 1 كغ', 'شركة الأفق', 'u2', 'مواد غذائية', 9.60, Currency.usd, 240, 24, 'tahini'),
      p('281', 'سائل جلي، عبوة 4 لتر', 'مجموعة الشام', 'u8', 'منظفات', 95000, Currency.syp, 220, 24, 'soap'),
      p('282', 'محارم مطبخ، كرتونة 12 لفة', 'شركة الواحة', 'u5', 'ورقيات', 180000, Currency.syp, 300, 20, 'roll'),
    ];
  }

  static List<AdminOrder> _seedOrders() {
    OrderLine l(String name, int q, double price) =>
        OrderLine(productId: name, name: name, visual: 'box', quantity: q, unitPrice: price);
    AdminOrder o(String id, int size, String trader, String sup, Currency cur, SubOrderStatus st, DateTime at,
        List<OrderLine> lines) {
      final tl = <SubOrderStatus, DateTime>{SubOrderStatus.awaiting: at};
      const path = [SubOrderStatus.accepted, SubOrderStatus.preparing, SubOrderStatus.completed];
      if (st == SubOrderStatus.rejected || st == SubOrderStatus.cancelled) {
        tl[st] = at.add(const Duration(hours: 4));
      } else {
        for (var i = 0; i <= path.indexOf(st); i++) {
          tl[path[i]] = at.add(Duration(hours: 2 + i * 20));
        }
      }
      return AdminOrder(
        id: id,
        purchaseId: id.split('-').first,
        purchaseSize: size,
        trader: trader,
        supplier: sup,
        currency: cur,
        status: st,
        createdAt: at,
        lines: lines,
        timeline: tl,
      );
    }

    return [
      o('1045-A', 1, 'متجر الياسمين', 'شركة الأفق', Currency.usd, SubOrderStatus.awaiting, _ago(minutes: 10),
          [l('زيت زيتون 5 لتر', 20, 38.50), l('معكرونة 500 غ', 30, 14.80), l('طحينة 1 كغ', 24, 9.60)]),
      o('1044-A', 1, 'مطعم بيت الشام', 'شركة الأفق', Currency.usd, SubOrderStatus.awaiting, _ago(hours: 2),
          [l('سكر خشن 25 كغ', 220, 15.20)]),
      o('1042-A', 2, 'متجر الياسمين', 'شركة الأفق', Currency.usd, SubOrderStatus.accepted, _ago(days: 1),
          [l('زيت زيتون 5 لتر', 20, 38.50), l('معكرونة 500 غ', 30, 14.80)]),
      o('1042-B', 2, 'متجر الياسمين', 'شركة الواحة', Currency.syp, SubOrderStatus.awaiting, _ago(days: 1),
          [l('مناديل ورقية', 25, 245000)]),
      o('1041-A', 1, 'سوبرماركت الرضا', 'شركة الأفق', Currency.usd, SubOrderStatus.preparing, _ago(days: 2),
          [l('سكر خشن 25 كغ', 20, 15.20), l('زيت زيتون 5 لتر', 20, 38.50)]),
      o('1038-A', 1, 'متجر الياسمين', 'مجموعة الشام', Currency.usd, SubOrderStatus.completed, _ago(days: 10),
          [l('سكر أبيض 50 كغ', 15, 28.50), l('أكياس تغليف', 3, 15.00)]),
      o('1031-A', 2, 'متجر الياسمين', 'مؤسسة النور', Currency.usd, SubOrderStatus.rejected, _ago(days: 17),
          [l('سكر أبيض 50 كغ', 20, 27.00)]),
      o('1031-B', 2, 'متجر الياسمين', 'شركة الأفق', Currency.usd, SubOrderStatus.cancelled, _ago(days: 17),
          [l('طحينة 1 كغ', 24, 9.60)]),
    ];
  }

  static List<AdminCategory> _seedProductCategories() => [
        AdminCategory(id: 'food', ar: 'مواد غذائية', en: 'Groceries', count: 312),
        AdminCategory(id: 'oils', ar: 'زيوت وسمون', en: 'Oils & fats', parentId: 'food', count: 48),
        AdminCategory(id: 'grains', ar: 'حبوب وبقوليات', en: 'Grains & legumes', parentId: 'food', count: 91),
        AdminCategory(id: 'paper', ar: 'ورقيات', en: 'Paper goods', count: 74),
        AdminCategory(id: 'packaging', ar: 'تغليف', en: 'Packaging', count: 39),
        AdminCategory(id: 'cleaning', ar: 'منظفات', en: 'Cleaning', count: 26),
        AdminCategory(id: 'cans', ar: 'معلبات قديمة', en: 'Old canned', active: false),
      ];

  static List<AdminCategory> _seedBusinessCategories() => [
        AdminCategory(id: 'grocery', ar: 'بقالة ومواد غذائية', en: 'Grocery store', count: 121),
        AdminCategory(id: 'restaurant', ar: 'مطعم أو مقهى', en: 'Restaurant / café', count: 47),
        AdminCategory(id: 'bakery', ar: 'مخبز وحلويات', en: 'Bakery', count: 28),
        AdminCategory(id: 'wholesale', ar: 'توزيع بالجملة', en: 'Wholesale distributor', count: 52),
        AdminCategory(id: 'pharmacy', ar: 'صيدلية', en: 'Pharmacy', count: 6),
      ];

  static List<AdminDeletion> _seedDeletions() => [
        AdminDeletion(
            id: 'd1',
            userId: 'u4',
            name: 'ليلى حداد',
            business: 'مخبز السنابل',
            role: UserRole.trader,
            requestedAt: DateTime(2026, 10, 29),
            reason: 'أغلقت المخبز.'),
        AdminDeletion(
            id: 'd2',
            userId: 'u6',
            name: 'رامي سليمان',
            business: 'مطعم بيت الشام',
            role: UserRole.trader,
            requestedAt: DateTime(2026, 10, 30),
            openOrders: const ['1044-A']),
        AdminDeletion(
            id: 'd3',
            userId: 'u10',
            name: 'ريم عيسى',
            business: 'صيدلية الشفاء',
            role: UserRole.trader,
            requestedAt: DateTime(2026, 10, 12),
            reason: 'نقل النشاط إلى حساب آخر.',
            state: DeletionState.postponed),
        AdminDeletion(
            id: 'd4',
            userId: 'u0',
            name: 'سامر نجار',
            business: 'بقالية الحي',
            role: UserRole.trader,
            requestedAt: DateTime(2026, 9, 20),
            state: DeletionState.done),
      ];

  static List<AuditEntry> _seedAudit() => [
        AuditEntry(at: _ago(minutes: 6), actor: adminEmail, actionKey: 'au_disableUser', entity: 'محمد العلي', type: AuditType.admin),
        AuditEntry(at: _ago(minutes: 30), actor: adminEmail, actionKey: 'au_hideProduct', entity: 'أكياس تغليف، 10 كغ', type: AuditType.admin),
        AuditEntry(at: _ago(hours: 2), actor: 'system', actionKey: 'au_failedLogins', entity: 'sara.m@example.com', type: AuditType.login, result: AuditResult.blocked, resultKey: 'au_blocked15'),
        AuditEntry(at: _ago(hours: 10), actor: 'alofuq.foods@example.com', actionKey: 'au_acceptOrder', entity: '#1042-A', type: AuditType.orders),
        AuditEntry(at: _ago(hours: 13), actor: 'yasmeen.store@example.com', actionKey: 'au_createPurchase', entity: '#1042', type: AuditType.orders),
        AuditEntry(at: _ago(days: 1, hours: 4), actor: adminEmail, actionKey: 'au_addProductCategory', entity: 'منظفات', type: AuditType.admin),
        AuditEntry(at: _ago(days: 1, hours: 8), actor: 'alofuq.foods@example.com', actionKey: 'au_acceptOrder', entity: '#1045-A', type: AuditType.orders, result: AuditResult.failed, resultKey: 'au_stockShort'),
        AuditEntry(at: _ago(days: 9), actor: adminEmail, actionKey: 'au_approveDeletion', entity: 'سامر نجار', type: AuditType.admin),
        AuditEntry(at: _ago(days: 12), actor: 'm.ali@example.com', actionKey: 'au_userLogin', entity: 'Android', type: AuditType.login),
      ];
}
