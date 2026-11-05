import '../model/business_profile_model.dart';
import '../model/option_model.dart';
import '../model/user_model.dart';

/// "العقد" لكل عمليات الحساب والدخول.
///
/// المتحكمات تعرف هذا العقد فقط، ولا تعرف إن كانت البيانات وهمية أو من الخادم.
/// الآن: MockAuthData. لاحقاً: RemoteAuthData بنفس الدوال، ونغيّر سطراً واحداً
/// في core/services/services.dart دون لمس أي شاشة أو متحكم.
///
/// عند الفشل تُرمى [AuthFailure] (data/model/auth_failure.dart).
abstract class AuthData {
  /// استعادة جلسة محفوظة عند فتح التطبيق (A1). null = لا جلسة صالحة.
  Future<UserModel?> restoreSession(String email);

  /// A2 (FR-4)
  Future<UserModel> login({required String email, required String password});

  /// A3 (FR-1, FR-2)
  Future<UserModel> register({required String email, required String password});

  /// A4: إعادة إرسال رابط التفعيل (FR-7)
  Future<void> resendVerification(String email);

  /// A5: ما يحدث عند فتح رابط التفعيل (FR-3)
  Future<UserModel> verifyEmail(String email);

  /// A6 (FR-10)
  Future<UserModel> setRoles(String email, Set<UserRole> roles);

  /// A7 (FR-11 إلى FR-14)
  Future<UserModel> saveBusinessProfile(String email, BusinessProfileModel profile);

  /// A8 (FR-6)
  Future<void> requestPasswordReset(String email);

  /// A10 (FR-6)
  Future<void> resetPassword({required String email, required String newPassword});

  /// قوائم الاختيار في A7.
  Future<List<OptionModel>> businessCategories();
  Future<List<OptionModel>> cities();
}
