import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/user_model.dart';

/// جلسة المستخدم الحالية.
///
/// في مرحلة البيانات الوهمية نحفظ البريد فقط، حتى تتجاوز شاشة البداية
/// تسجيل الدخول عند الفتح التالي. عند ربط الخادم نحفظ هنا Refresh Token
/// بشكل مشفّر بدل البريد، ولا يتغير شيء في الشاشات.
class SessionService extends GetxService {
  SessionService(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'session_email';

  UserModel? currentUser;

  String? get savedEmail => _prefs.getString(_key);

  Future<void> start(UserModel user) async {
    currentUser = user;
    await _prefs.setString(_key, user.email);
  }

  /// بعد أي تغيير على المستخدم (تفعيل البريد، الأدوار، الملف التجاري).
  void update(UserModel user) => currentUser = user;

  Future<void> clear() async {
    currentUser = null;
    await _prefs.remove(_key);
  }
}
