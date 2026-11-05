import '../model/admin_models.dart';

/// العقد للوحة الإدارة (E1 إلى E10).
/// الآن MockAdminData، ولاحقاً RemoteAdminData بنفس الدوال.
/// كل إجراء إداري يُسجَّل في سجل التدقيق من جهة الخادم (هنا: من البيانات الوهمية).
/// عند الفشل تُرمى AuthFailure (الدخول) أو RequestFailure.
abstract class AdminData {
  /// E1 (FR-61)
  Future<String> login({required String email, required String password});
  Future<String?> restoreSession();
  Future<void> logout();

  /// E2
  Future<AdminStats> stats();

  /// E3 / E4 (FR-62، FR-63)
  Future<List<AdminUser>> users();
  Future<AdminUser> user(String id);
  Future<AdminUser> setUserStatus(String id, AdminUserStatus status, {String reason = ''});

  /// E5 (FR-64)
  Future<List<AdminProduct>> products();
  Future<AdminProduct> setProductHidden(String id, bool hidden);

  /// E6 (FR-65): للعرض فقط، الإدارة لا تغيّر حالة الطلبات.
  Future<List<AdminOrder>> orders();

  /// E7 / E8 (FR-66، FR-67)
  Future<List<AdminCategory>> categories(CategoryKind kind);
  Future<AdminCategory> saveCategory(CategoryKind kind, AdminCategory category);
  Future<AdminCategory> setCategoryActive(CategoryKind kind, String id, bool active);

  /// E9 (FR-68)
  Future<List<AdminDeletion>> deletions();
  Future<AdminDeletion> approveDeletion(String id);
  Future<AdminDeletion> postponeDeletion(String id);

  /// E10 (FR-69): للقراءة فقط.
  Future<List<AuditEntry>> audit();
}
