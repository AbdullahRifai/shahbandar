import 'order_model.dart';
import 'product_model.dart';
import 'user_model.dart';

/// نماذج لوحة الإدارة (E). منفصلة عن نماذج التطبيق لأن الإدارة ترى أكثر:
/// حالة الحساب، السبب الداخلي، من أخفى المنتج، وسجل التدقيق.

// ─── المستخدمون (E3، E4) ───

enum AdminUserStatus { active, disabled }

class AdminUser {
  AdminUser({
    required this.id,
    required this.name,
    required this.businessName,
    required this.email,
    required this.roles,
    required this.joinedAt,
    this.status = AdminUserStatus.active,
    this.deletionRequested = false,
    this.emailVerifiedAt,
    this.lastLoginAt,
    this.businessType = '',
    this.city = '',
    this.phone = '',
    this.purchases = 0,
    this.openOrders = 0,
    this.disableReason = '',
    this.recent = const [],
  });

  final String id;
  final String name;
  final String businessName;
  final String email;
  final Set<UserRole> roles;
  final DateTime joinedAt;
  AdminUserStatus status;
  bool deletionRequested;
  final DateTime? emailVerifiedAt;
  final DateTime? lastLoginAt;
  final String businessType;
  final String city;
  final String phone;
  final int purchases;
  final int openOrders;

  /// سبب داخلي للإيقاف، لا يراه المستخدم.
  String disableReason;

  /// آخر نشاط: (نص، وقت).
  final List<(String, DateTime)> recent;

  bool get bothRoles => roles.length > 1;
  String get initial => businessName.isEmpty ? '?' : String.fromCharCode(businessName.runes.first);
}

// ─── المنتجات (E5) ───

enum AdminProductStatus { published, pausedBySupplier, hiddenByAdmin }

class AdminProduct {
  AdminProduct({
    required this.id,
    required this.name,
    required this.supplier,
    required this.supplierUserId,
    required this.category,
    required this.price,
    required this.currency,
    required this.stock,
    required this.moq,
    required this.images,
    required this.updatedAt,
    this.description = '',
    this.visual = 'box',
    this.status = AdminProductStatus.published,
  });

  final String id;
  final String name;
  final String supplier;
  final String supplierUserId;
  final String category;
  final double price;
  final Currency currency;
  final int stock;
  final int moq;
  final int images;
  final DateTime updatedAt;
  final String description;
  final String visual;
  AdminProductStatus status;
}

// ─── الطلبات (E6) ───

class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.purchaseId,
    required this.purchaseSize,
    required this.trader,
    required this.supplier,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.lines,
    required this.timeline,
  });

  final String id;
  final String purchaseId;

  /// عدد الطلبات الفرعية في نفس عملية الشراء.
  final int purchaseSize;
  final String trader;
  final String supplier;
  final Currency currency;
  final SubOrderStatus status;
  final DateTime createdAt;
  final List<OrderLine> lines;
  final Map<SubOrderStatus, DateTime> timeline;

  double get total => lines.fold(0, (s, l) => s + l.total);
}

// ─── التصنيفات (E7، E8) ───

enum CategoryKind { product, business }

class AdminCategory {
  AdminCategory({
    required this.id,
    required this.ar,
    required this.en,
    this.parentId,
    this.count = 0,
    this.active = true,
  });

  final String id;
  String ar;
  String en;

  /// للتصنيفات الفرعية (منتجات فقط).
  String? parentId;

  /// عدد المنتجات (E7) أو الحسابات (E8).
  final int count;
  bool active;
}

// ─── طلبات الحذف (E9) ───

enum DeletionState { pending, postponed, done }

class AdminDeletion {
  AdminDeletion({
    required this.id,
    required this.userId,
    required this.name,
    required this.business,
    required this.role,
    required this.requestedAt,
    this.reason = '',
    this.openOrders = const [],
    this.state = DeletionState.pending,
  });

  final String id;
  final String userId;
  final String name;
  final String business;
  final UserRole role;
  final DateTime requestedAt;
  final String reason;

  /// لا تُقبل الموافقة ما دام هنا طلب مفتوح.
  final List<String> openOrders;
  DeletionState state;

  bool get canApprove => openOrders.isEmpty && state != DeletionState.done;
}

// ─── سجل التدقيق (E10) ───

enum AuditType { login, orders, admin }

enum AuditResult { ok, failed, blocked }

class AuditEntry {
  const AuditEntry({
    required this.at,
    required this.actor,
    required this.actionKey,
    required this.entity,
    required this.type,
    this.result = AuditResult.ok,
    this.resultKey,
  });

  final DateTime at;

  /// بريد المنفّذ، أو "system".
  final String actor;
  final String actionKey;
  final String entity;
  final AuditType type;
  final AuditResult result;

  /// نص نتيجة خاص (مثل "مخزون غير كافٍ")، وإلا حسب [result].
  final String? resultKey;
}

// ─── المؤشرات (E2) ───

class AdminStats {
  const AdminStats({
    required this.traders,
    required this.suppliers,
    required this.both,
    required this.activeProducts,
    required this.hiddenProducts,
    required this.pendingDeletions,
    required this.disabledUsers,
    required this.ordersByStatus,
    required this.updatedAt,
  });

  final int traders;
  final int suppliers;
  final int both;
  final int activeProducts;
  final int hiddenProducts;
  final int pendingDeletions;
  final int disabledUsers;
  final Map<SubOrderStatus, int> ordersByStatus;
  final DateTime updatedAt;

  int get users => traders + suppliers + both;
  int get products => activeProducts + hiddenProducts;
  int get orders => ordersByStatus.values.fold(0, (a, b) => a + b);
}
