import 'package:get/get.dart';

import '../../core/constant/app_routes.dart';
import '../../core/functions/home_route.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/auth_failure.dart';

/// حالات فتح رابط التفعيل.
enum LinkState { checking, verified, expired, already }

/// A5 نتيجة فتح رابط التفعيل (FR-3).
class LinkResultController extends GetxController {
  final AuthData _auth = Get.find();
  final SessionService _session = Get.find();

  LinkState state = LinkState.checking;
  bool isBusy = false;

  @override
  void onReady() {
    super.onReady();
    _verify();
  }

  Future<void> _verify() async {
    final user = _session.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoute.login);
      return;
    }
    try {
      final verified = await _auth.verifyEmail(user.email);
      _session.update(verified);
      state = LinkState.verified;
    } on AuthFailure catch (failure) {
      state = failure.type == AuthFailureType.alreadyVerified
          ? LinkState.already
          : LinkState.expired;
    }
    update();
  }

  /// الزر الوحيد في الشاشة، ووظيفته حسب الحالة.
  Future<void> onPrimary() async {
    switch (state) {
      case LinkState.verified:
      case LinkState.already:
        final user = _session.currentUser;
        Get.offAllNamed(user == null ? AppRoute.login : homeRouteFor(user));
      case LinkState.expired:
        isBusy = true;
        update();
        await _auth.resendVerification(_session.currentUser?.email ?? '');
        Get.offAllNamed(AppRoute.checkEmail);
      case LinkState.checking:
        break;
    }
  }
}
