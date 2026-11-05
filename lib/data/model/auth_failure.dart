/// أنواع الرفض في عمليات الحساب. المتحكم يحوّل كلاً منها إلى رسالة واضحة.
enum AuthFailureType {
  invalidCredentials, // بريد أو كلمة مرور خاطئة
  accountDisabled,    // FR-9
  tooManyAttempts,    // حد المحاولات
  emailTaken,         // FR-2
  linkExpired,        // رابط التفعيل منتهٍ
  alreadyVerified,    // البريد مفعّل مسبقاً
  offline,            // لا اتصال
  unknown,
}

/// تُرمى من مصدر البيانات (الوهمي الآن، والخادم لاحقاً).
class AuthFailure implements Exception {
  const AuthFailure(this.type, {this.retryAfter = 0});

  final AuthFailureType type;

  /// ثوانٍ قبل السماح بمحاولة جديدة (لـ tooManyAttempts).
  final int retryAfter;
}
