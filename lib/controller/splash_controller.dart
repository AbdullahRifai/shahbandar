import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import '../core/constant/app_routes.dart';
import '../core/functions/home_route.dart';
import '../core/services/session_service.dart';
import '../data/datasource/auth_data.dart';

/// A1: هل توجد جلسة محفوظة؟ وإلى أين نذهب؟
class SplashController extends GetxController {
  final SessionService _session = Get.find();
  final AuthData _auth = Get.find();

  @override
  void onReady() {
    super.onReady();
    // شاشة Flutter المطابقة رُسمت، فنُخفي شاشة النظام بلا ومضة.
    FlutterNativeSplash.remove();
    _route();
  }

  Future<void> _route() async {
    final email = _session.savedEmail;
    if (email == null) return _go(AppRoute.login);

    final user = await _auth.restoreSession(email);
    if (user == null || user.isDisabled) {
      await _session.clear();
      return _go(user == null ? AppRoute.login : AppRoute.accountDisabled);
    }

    await _session.start(user);
    _go(homeRouteFor(user));
  }

  /// نحذف شاشة البداية من السجل، فزر الرجوع لا يعيد إليها.
  void _go(String route) => Get.offAllNamed(route);
}
