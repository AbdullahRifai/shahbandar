import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../services/services.dart';

/// لغة التطبيق.
/// 1. اللغة المحفوظة إن اختارها المستخدم من قبل.
/// 2. وإلا لغة الهاتف: الإنجليزية إن كانت، والعربية في كل حالة أخرى.
class LocaleController extends GetxController {
  static const String _key = 'lang';

  final MyServices _services = Get.find();
  late Locale locale;

  bool get isArabic => locale.languageCode == 'ar';

  @override
  void onInit() {
    super.onInit();
    final saved = _services.prefs.getString(_key);
    locale = Locale(saved ?? (Get.deviceLocale?.languageCode == 'en' ? 'en' : 'ar'));
  }

  Future<void> changeLanguage(String code) async {
    if (code == locale.languageCode || (code != 'ar' && code != 'en')) return;
    locale = Locale(code);
    await _services.prefs.setString(_key, code);
    await Get.updateLocale(locale);
    update();
  }
}
