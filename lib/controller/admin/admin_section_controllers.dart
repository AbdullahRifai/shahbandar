import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/admin_data.dart';
import '../../data/model/admin_models.dart';
import '../../data/model/order_model.dart';
import '../../data/model/request_failure.dart';
import '../../data/model/user_model.dart';
import '../../view/widget/admin/admin_parts.dart';
import 'admin_shell_controller.dart';

/// متحكمات أقسام الإدارة. كل قسم يُنشئ متحكمه عند فتحه (GetBuilder محلي)،
/// فيُحمّل بيانات جديدة في كل مرة يعود إليه الأدمن.

/// أساس مشترك: حالة التحميل + بحث نصي.
abstract class _AdminListController<T> extends GetxController {
  final AdminData data = Get.find();

  StatusRequest status = StatusRequest.none;
  List<T> items = [];
  String query = '';

  Future<List<T>> fetch();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (items.isEmpty) {
      status = StatusRequest.loading;
      update();
    }
    try {
      items = await fetch();
      status = StatusRequest.success;
    } catch (_) {
      if (items.isEmpty) status = StatusRequest.failure;
    }
    update();
  }

  void search(String q) {
    query = q.trim().toLowerCase();
    onFilterChanged();
    update();
  }

  /// مثلاً لإعادة الصفحة إلى الأولى.
  void onFilterChanged() {}

  bool matches(String text) => query.isEmpty || text.toLowerCase().contains(query);
}

// ─── E2 المؤشرات ───

class AdminDashboardController extends GetxController {
  final AdminData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  AdminStats? stats;
  List<AuditEntry> recent = [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      stats = await _data.stats();
      recent = (await _data.audit()).take(5).toList();
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }
}

// ─── E3 المستخدمون ───

enum UserRoleFilter { all, trader, supplier, both }

enum UserStatusFilter { all, active, disabled, deletion }

class AdminUsersController extends _AdminListController<AdminUser> {
  static const int pageSize = 8;

  UserRoleFilter role = UserRoleFilter.all;
  UserStatusFilter state = UserStatusFilter.all;
  int page = 0;

  @override
  Future<List<AdminUser>> fetch() => data.users();

  @override
  void onFilterChanged() => page = 0;

  void setRole(UserRoleFilter r) {
    role = r;
    page = 0;
    update();
  }

  void setStatusFilter(UserStatusFilter s) {
    state = state == s ? UserStatusFilter.all : s; // الضغط مرة ثانية يلغي الفلتر
    page = 0;
    update();
  }

  List<AdminUser> get filtered => items.where((u) {
        if (!matches('${u.name} ${u.businessName} ${u.email}')) return false;
        final roleOk = switch (role) {
          UserRoleFilter.all => true,
          UserRoleFilter.trader => !u.bothRoles && u.roles.contains(UserRole.trader),
          UserRoleFilter.supplier => !u.bothRoles && u.roles.contains(UserRole.supplier),
          UserRoleFilter.both => u.bothRoles,
        };
        final stateOk = switch (state) {
          UserStatusFilter.all => true,
          UserStatusFilter.active => u.status == AdminUserStatus.active && !u.deletionRequested,
          UserStatusFilter.disabled => u.status == AdminUserStatus.disabled,
          UserStatusFilter.deletion => u.deletionRequested,
        };
        return roleOk && stateOk;
      }).toList();

  int get pageCount {
    final n = (filtered.length / pageSize).ceil();
    return n < 1 ? 1 : n;
  }

  List<AdminUser> get pageItems => filtered.skip(page * pageSize).take(pageSize).toList();

  void next() {
    if (page < pageCount - 1) page++;
    update();
  }

  void previous() {
    if (page > 0) page--;
    update();
  }
}

// ─── E4 تفاصيل مستخدم ───

class AdminUserController extends GetxController {
  AdminUserController(this.userId);

  final String userId;
  final AdminData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  AdminUser? user;
  final reason = TextEditingController();
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
      user = await _data.user(userId);
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  /// إيقاف أو تفعيل (FR-63). الإيقاف يُخرج المستخدم فوراً ولا يمس طلباته.
  Future<void> toggleStatus() async {
    final u = user;
    if (u == null || busy) return;
    final disabling = u.status == AdminUserStatus.active;
    final ok = await confirmAdminAction(
      title: disabling ? 'adminDisableTitle'.tr : 'adminEnableTitle'.tr,
      body: (disabling ? 'adminDisableBody' : 'adminEnableBody').trParams({'name': u.name}),
      confirmLabel: disabling ? 'adminConfirmDisable'.tr : 'adminConfirmEnable'.tr,
      danger: disabling,
    );
    if (!ok) return;
    busy = true;
    update();
    try {
      user = await _data.setUserStatus(
        userId,
        disabling ? AdminUserStatus.disabled : AdminUserStatus.active,
        reason: reason.text.trim(),
      );
      reason.clear();
      showMessage(disabling ? 'adminUserDisabled'.tr : 'adminUserEnabled'.tr);
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

// ─── E5 المنتجات ───

enum ProductStatusFilter { all, published, pausedBySupplier, hiddenByAdmin }

class AdminProductsController extends _AdminListController<AdminProduct> {
  ProductStatusFilter filter = ProductStatusFilter.all;
  String? selectedId;
  bool busy = false;

  @override
  Future<List<AdminProduct>> fetch() async {
    final list = await data.products();
    selectedId ??= list.isEmpty ? null : list.first.id;
    return list;
  }

  void setFilter(ProductStatusFilter f) {
    filter = f;
    update();
  }

  void select(String id) {
    selectedId = id;
    update();
  }

  List<AdminProduct> get filtered => items.where((p) {
        if (!matches('${p.name} ${p.supplier}')) return false;
        return switch (filter) {
          ProductStatusFilter.all => true,
          ProductStatusFilter.published => p.status == AdminProductStatus.published,
          ProductStatusFilter.pausedBySupplier => p.status == AdminProductStatus.pausedBySupplier,
          ProductStatusFilter.hiddenByAdmin => p.status == AdminProductStatus.hiddenByAdmin,
        };
      }).toList();

  AdminProduct? get selected {
    for (final p in items) {
      if (p.id == selectedId) return p;
    }
    return null;
  }

  /// FR-64: إخفاء منتج مخالف أو إعادته.
  Future<void> toggleHidden() async {
    final p = selected;
    if (p == null || busy) return;
    final hiding = p.status != AdminProductStatus.hiddenByAdmin;
    final ok = await confirmAdminAction(
      title: hiding ? 'adminHideTitle'.tr : 'adminShowTitle'.tr,
      body: (hiding ? 'adminHideBody' : 'adminShowBody').trParams({'name': p.name}),
      confirmLabel: hiding ? 'adminHideProduct'.tr : 'adminShowProduct'.tr,
      danger: hiding,
    );
    if (!ok) return;
    busy = true;
    update();
    try {
      await data.setProductHidden(p.id, hiding);
      showMessage(hiding ? 'adminProductHidden'.tr : 'adminProductShown'.tr);
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    busy = false;
    update();
  }
}

// ─── E6 الطلبات ───

enum AdminOrderFilter { all, awaiting, preparing, rejected }

class AdminOrdersController extends _AdminListController<AdminOrder> {
  AdminOrderFilter filter = AdminOrderFilter.all;
  String? selectedId;

  @override
  Future<List<AdminOrder>> fetch() async {
    final list = await data.orders();
    selectedId ??= list.isEmpty ? null : list.first.id;
    return list;
  }

  void setFilter(AdminOrderFilter f) {
    filter = f;
    update();
  }

  void select(String id) {
    selectedId = id;
    update();
  }

  List<AdminOrder> get filtered => items.where((o) {
        if (!matches('${o.id} ${o.trader} ${o.supplier}')) return false;
        return switch (filter) {
          AdminOrderFilter.all => true,
          AdminOrderFilter.awaiting => o.status == SubOrderStatus.awaiting,
          AdminOrderFilter.preparing =>
            o.status == SubOrderStatus.preparing || o.status == SubOrderStatus.accepted,
          AdminOrderFilter.rejected => o.status == SubOrderStatus.rejected || o.status == SubOrderStatus.cancelled,
        };
      }).toList();

  AdminOrder? get selected {
    for (final o in items) {
      if (o.id == selectedId) return o;
    }
    return null;
  }
}

// ─── E7 / E8 التصنيفات ───

class AdminCategoriesController extends _AdminListController<AdminCategory> {
  AdminCategoriesController(this.kind);

  final CategoryKind kind;
  final ar = TextEditingController();
  final en = TextEditingController();
  String? parentId;

  /// تصنيف قيد التعديل في النموذج أعلى الجدول، أو null للإضافة.
  String? editingId;
  bool saving = false;

  @override
  void onInit() {
    ar.addListener(update);
    en.addListener(update);
    super.onInit();
  }

  @override
  Future<List<AdminCategory>> fetch() => data.categories(kind);

  bool get canSave => ar.text.trim().isNotEmpty && en.text.trim().isNotEmpty && !saving;

  /// الآباء بعد أبنائهم مباشرة، لعرض الشجرة في الجدول.
  List<AdminCategory> get ordered {
    final roots = items.where((c) => c.parentId == null);
    return [
      for (final r in roots) ...[r, ...items.where((c) => c.parentId == r.id)],
    ];
  }

  /// يصلح أباً: تصنيف رئيسي مفعّل، وليس هو نفسه.
  List<AdminCategory> get parentOptions =>
      items.where((c) => c.parentId == null && c.active && c.id != editingId).toList();

  String nameOf(String? id) {
    for (final c in items) {
      if (c.id == id) return c.ar;
    }
    return '—';
  }

  void setParent(String? id) {
    parentId = id;
    update();
  }

  void edit(AdminCategory c) {
    editingId = c.id;
    ar.text = c.ar;
    en.text = c.en;
    parentId = c.parentId;
    update();
  }

  void cancelEdit() {
    editingId = null;
    ar.clear();
    en.clear();
    parentId = null;
    update();
  }

  Future<void> save() async {
    if (!canSave) return;
    final name = ar.text.trim();
    final duplicate = items.any((c) => c.id != editingId && c.ar.trim() == name);
    if (duplicate) {
      showMessage('adminCategoryExists'.tr);
      return;
    }
    saving = true;
    update();
    try {
      await data.saveCategory(
        kind,
        AdminCategory(id: editingId ?? '', ar: name, en: en.text.trim(), parentId: parentId),
      );
      showMessage(editingId == null ? 'adminCategoryAdded'.tr : 'adminCategorySaved'.tr);
      cancelEdit();
      items = await fetch();
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    saving = false;
    update();
  }

  Future<void> toggleActive(AdminCategory c) async {
    try {
      await data.setCategoryActive(kind, c.id, !c.active);
      items = await fetch();
      update();
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
  }

  @override
  void onClose() {
    ar.dispose();
    en.dispose();
    super.onClose();
  }
}

// ─── E9 طلبات الحذف ───

class AdminDeletionController extends _AdminListController<AdminDeletion> {
  DeletionState tab = DeletionState.pending;
  String? busyId;

  @override
  Future<List<AdminDeletion>> fetch() => data.deletions();

  void setTab(DeletionState t) {
    tab = t;
    update();
  }

  int countOf(DeletionState s) => items.where((d) => d.state == s).length;
  List<AdminDeletion> get visible => items.where((d) => d.state == tab).toList();

  Future<void> approve(AdminDeletion d) async {
    final ok = await confirmAdminAction(
      title: 'adminApproveTitle'.tr,
      body: 'adminApproveBody'.trParams({'name': d.name}),
      confirmLabel: 'adminApprove'.tr,
      danger: true,
    );
    if (!ok) return;
    await _run(d, () => data.approveDeletion(d.id), 'adminDeletionApproved'.tr);
  }

  Future<void> postpone(AdminDeletion d) =>
      _run(d, () => data.postponeDeletion(d.id), 'adminDeletionPostponed'.tr);

  Future<void> _run(AdminDeletion d, Future<AdminDeletion> Function() action, String done) async {
    busyId = d.id;
    update();
    try {
      await action();
      showMessage(done);
    } on RequestFailure catch (e) {
      showMessage(e.type == RequestFailureType.notAllowed ? 'adminHasOpenOrders'.tr : 'errorGeneric'.tr);
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    busyId = null;
    items = await fetch();
    update();
    Get.find<AdminShellController>().refreshBadge();
  }
}

// ─── E10 سجل التدقيق ───

enum AuditPeriod { week, month, all }

class AdminAuditController extends _AdminListController<AuditEntry> {
  AuditType? type;
  AuditPeriod period = AuditPeriod.week;

  @override
  Future<List<AuditEntry>> fetch() => data.audit();

  void setType(AuditType? t) {
    type = t;
    update();
  }

  void setPeriod(AuditPeriod p) {
    period = p;
    update();
  }

  List<AuditEntry> get filtered {
    final now = DateTime.now();
    final from = switch (period) {
      AuditPeriod.week => now.subtract(const Duration(days: 7)),
      AuditPeriod.month => now.subtract(const Duration(days: 30)),
      AuditPeriod.all => DateTime(2000),
    };
    return items
        .where((e) => !e.at.isBefore(from))
        .where((e) => type == null || e.type == type)
        .where((e) => matches('${e.actor} ${e.entity} ${e.actionKey.tr}'))
        .toList();
  }
}
