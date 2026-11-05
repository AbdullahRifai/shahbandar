import '../model/activity_model.dart';
import '../model/business_profile_model.dart';
import '../model/notification_model.dart';
import '../model/user_model.dart';

/// العقد للواجهات المشتركة (D): الإشعارات، الملف التجاري، الأدوار، السجل،
/// كلمة المرور، وطلب الحذف. كلها للمستخدم الحالي في الجلسة.
/// الآن MockAccountData، ولاحقاً RemoteAccountData بنفس الدوال.
abstract class AccountData {
  /// D1
  Future<List<AppNotification>> notifications(UserRole role);
  Future<int> unreadCount(UserRole role);
  Future<void> markRead(String id);
  Future<void> markAllRead(UserRole role);

  /// D3 (FR-11 إلى FR-14). null = لم يُكمل الملف بعد.
  Future<BusinessProfileModel?> businessProfile();
  Future<BusinessProfileModel> saveBusinessProfile(BusinessProfileModel profile);

  /// D4 (FR-10): إضافة دور للحساب الحالي. يرجع المستخدم بعد التحديث.
  Future<UserModel> activateRole(UserRole role);

  /// D5 (FR-59)
  Future<List<ActivityEntry>> activity();

  /// D7: ترمي AuthFailure(invalidCredentials) إن كانت الحالية خاطئة.
  Future<void> changePassword({required String current, required String newPassword});

  /// D6 (FR-60)
  Future<DeletionRequest?> deletionRequest();
  Future<DeletionRequest> requestDeletion(String reason);
  Future<void> cancelDeletion();
}
