import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/auth_failure.dart';
import '../model/business_profile_model.dart';
import '../model/option_model.dart';
import '../model/user_model.dart';
import 'auth_data.dart';
import 'mock_account_data.dart';

/// بيانات وهمية للحساب: لا شبكة ولا خادم.
///
/// تحفظ الحسابات في SharedPreferences حتى تبقى بعد إغلاق التطبيق،
/// فتستطيع إنشاء حساب ثم الخروج والدخول به من جديد.
///
/// حسابات جاهزة للتجربة (أي كلمة مرور تعمل معها، ما عدا "wrong"):
///   trader@shahbandar.test     ← تاجر جاهز
///   supplier@shahbandar.test   ← مورد جاهز
///   both@shahbandar.test       ← تاجر ومورد
///   new@shahbandar.test        ← بريد غير مفعّل ← A4
///   expired@shahbandar.test    ← بريد غير مفعّل، ورابطه منتهٍ ← A5
///   norole@shahbandar.test     ← لم يختر دوراً ← A6
///   noprofile@shahbandar.test  ← لم يكمل الملف التجاري ← A7
///   disabled@shahbandar.test   ← حساب موقوف ← A11
///   locked@shahbandar.test     ← محاولات كثيرة (30 ثانية)
///   offline@shahbandar.test    ← لا يوجد اتصال
class MockAuthData implements AuthData {
  MockAuthData(this._prefs);

  final SharedPreferences _prefs;
  static const String _storageKey = 'mock_accounts';

  /// تأخير يشبه الشبكة، حتى تظهر حالات التحميل في الأزرار.
  static const Duration _latency = Duration(milliseconds: 700);

  late final Map<String, _Account> _accounts = _load();

  // ─── العمليات ───

  @override
  Future<UserModel?> restoreSession(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _accounts[email]?.user;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    await Future<void>.delayed(_latency);
    final mail = email.toLowerCase();

    if (mail == 'offline@shahbandar.test') throw const AuthFailure(AuthFailureType.offline);
    if (mail == 'locked@shahbandar.test') {
      throw const AuthFailure(AuthFailureType.tooManyAttempts, retryAfter: 30);
    }

    final account = _accounts[mail];
    final wrongPassword = password == 'wrong' ||
        (account?.password != null && account!.password != password);
    if (account == null || wrongPassword) {
      // رسالة واحدة للحالتين، فلا نكشف إن كان البريد مسجلاً.
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    if (account.user.isDisabled) throw const AuthFailure(AuthFailureType.accountDisabled);
    return account.user;
  }

  @override
  Future<UserModel> register({required String email, required String password}) async {
    await Future<void>.delayed(_latency);
    final mail = email.toLowerCase();
    if (_accounts.containsKey(mail)) throw const AuthFailure(AuthFailureType.emailTaken);

    final user = UserModel(id: 'u${_accounts.length + 1}', email: mail);
    _accounts[mail] = _Account(user, password);
    await _save();
    return user;
  }

  @override
  Future<void> resendVerification(String email) => Future<void>.delayed(_latency);

  @override
  Future<UserModel> verifyEmail(String email) async {
    await Future<void>.delayed(_latency);
    if (email == 'expired@shahbandar.test') throw const AuthFailure(AuthFailureType.linkExpired);
    final user = _require(email);
    if (user.emailVerified) throw const AuthFailure(AuthFailureType.alreadyVerified);
    return _update(user.copyWith(emailVerified: true));
  }

  @override
  Future<UserModel> setRoles(String email, Set<UserRole> roles) async {
    await Future<void>.delayed(_latency);
    return _update(_require(email).copyWith(roles: roles));
  }

  @override
  Future<UserModel> saveBusinessProfile(
    String email,
    BusinessProfileModel profile,
  ) async {
    await Future<void>.delayed(_latency);
    // يظهر لاحقاً في "الملف التجاري" (D3).
    MockAccountData.profiles[email.toLowerCase()] = profile;
    return _update(_require(email).copyWith(hasBusinessProfile: true));
  }

  @override
  Future<void> requestPasswordReset(String email) => Future<void>.delayed(_latency);

  @override
  Future<void> resetPassword({required String email, required String newPassword}) async {
    await Future<void>.delayed(_latency);
    final account = _accounts[email.toLowerCase()];
    if (account == null) return; // لا نكشف إن كان البريد مسجلاً.
    _accounts[account.user.email] = _Account(account.user, newPassword);
    await _save();
  }

  @override
  Future<List<OptionModel>> businessCategories() async => const [
        OptionModel(id: 'grocery', ar: 'بقالة ومواد غذائية', en: 'Grocery store'),
        OptionModel(id: 'restaurant', ar: 'مطعم أو مقهى', en: 'Restaurant / café'),
        OptionModel(id: 'bakery', ar: 'مخبز وحلويات', en: 'Bakery'),
        OptionModel(id: 'wholesale', ar: 'توزيع بالجملة', en: 'Wholesale distributor'),
        OptionModel(id: 'pharmacy', ar: 'صيدلية', en: 'Pharmacy'),
      ];

  @override
  Future<List<OptionModel>> cities() async => const [
        OptionModel(id: 'damascus', ar: 'دمشق', en: 'Damascus'),
        OptionModel(id: 'rif', ar: 'ريف دمشق', en: 'Rif Dimashq'),
        OptionModel(id: 'aleppo', ar: 'حلب', en: 'Aleppo'),
        OptionModel(id: 'homs', ar: 'حمص', en: 'Homs'),
        OptionModel(id: 'hama', ar: 'حماة', en: 'Hama'),
        OptionModel(id: 'latakia', ar: 'اللاذقية', en: 'Latakia'),
        OptionModel(id: 'tartus', ar: 'طرطوس', en: 'Tartus'),
      ];

  // ─── التخزين ───

  UserModel _require(String email) {
    final account = _accounts[email.toLowerCase()];
    if (account == null) throw const AuthFailure(AuthFailureType.unknown);
    return account.user;
  }

  Future<UserModel> _update(UserModel user) async {
    _accounts[user.email] = _Account(user, _accounts[user.email]?.password);
    await _save();
    return user;
  }

  Map<String, _Account> _load() {
    final accounts = {for (final a in _seed) a.user.email: a};
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final saved = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in saved.entries) {
          accounts[entry.key] = _Account.fromJson(entry.value as Map<String, dynamic>);
        }
      } catch (_) {
        // بيانات تالفة: نبدأ من الحسابات الجاهزة.
      }
    }
    return accounts;
  }

  Future<void> _save() => _prefs.setString(
        _storageKey,
        jsonEncode({for (final e in _accounts.entries) e.key: e.value.toJson()}),
      );

  static const _ready = {UserRole.trader};

  static final List<_Account> _seed = [
    const _Account(UserModel(id: 's1', email: 'trader@shahbandar.test', emailVerified: true, roles: _ready, hasBusinessProfile: true)),
    const _Account(UserModel(id: 's2', email: 'supplier@shahbandar.test', emailVerified: true, roles: {UserRole.supplier}, hasBusinessProfile: true)),
    const _Account(UserModel(id: 's3', email: 'both@shahbandar.test', emailVerified: true, roles: {UserRole.trader, UserRole.supplier}, lastMode: UserRole.supplier, hasBusinessProfile: true)),
    const _Account(UserModel(id: 's4', email: 'new@shahbandar.test')),
    const _Account(UserModel(id: 's5', email: 'expired@shahbandar.test')),
    const _Account(UserModel(id: 's6', email: 'norole@shahbandar.test', emailVerified: true)),
    const _Account(UserModel(id: 's7', email: 'noprofile@shahbandar.test', emailVerified: true, roles: _ready)),
    const _Account(UserModel(id: 's8', email: 'disabled@shahbandar.test', emailVerified: true, status: AccountStatus.disabled, roles: _ready, hasBusinessProfile: true)),
  ];
}

/// حساب وهمي: المستخدم + كلمة المرور (null = أي كلمة مرور تقبل).
class _Account {
  const _Account(this.user, [this.password]);

  final UserModel user;
  final String? password;

  factory _Account.fromJson(Map<String, dynamic> json) => _Account(
        UserModel.fromJson(json['user'] as Map<String, dynamic>),
        json['password'] as String?,
      );

  Map<String, dynamic> toJson() => {'user': user.toJson(), 'password': password};
}
