import 'package:get/get.dart';

/// شرط واحد من شروط كلمة المرور، يُعرض في القائمة الحية (A3، A10).
class PasswordRule {
  const PasswordRule(this.labelKey, this.isMet);

  final String labelKey;
  final bool Function(String password) isMet;
}

/// قواعد التحقق. كل دالة ترجع نص الخطأ، أو null إن كانت القيمة سليمة.
abstract final class ValidInput {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'fieldRequired'.tr;
    if (!GetUtils.isEmail(v)) return 'emailInvalid'.tr;
    return null;
  }

  /// بريد اختياري: فارغ مقبول، وإن كُتب يجب أن يكون صحيحاً.
  static String? optionalEmail(String? value) {
    if ((value?.trim() ?? '').isEmpty) return null;
    return email(value);
  }

  static String? notEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return 'fieldRequired'.tr;
    return null;
  }

  /// رقم هاتف سوري بدون +963: تسعة أرقام تبدأ بـ 9. فارغ مقبول.
  static String? optionalPhone(String? value) {
    final v = value?.replaceAll(' ', '') ?? '';
    if (v.isEmpty) return null;
    if (!RegExp(r'^9\d{8}$').hasMatch(v)) return 'phoneInvalid'.tr;
    return null;
  }

  static final List<PasswordRule> passwordRules = [
    PasswordRule('ruleLetter', (p) => RegExp(r'[A-Za-zء-ي]').hasMatch(p)),
    PasswordRule('ruleLength', (p) => p.length >= 8),
    PasswordRule('ruleDigit', (p) => RegExp(r'[0-9٠-٩]').hasMatch(p)),
  ];

  static bool passwordValid(String password) =>
      passwordRules.every((rule) => rule.isMet(password));
}
