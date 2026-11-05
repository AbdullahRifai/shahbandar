import 'package:get/get.dart';

import '../../core/class/countdown_mixin.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/auth_data.dart';

/// A4 تفعيل البريد: الرابط أُرسل (FR-3، FR-7).
class CheckEmailController extends GetxController with CountdownMixin {
  final AuthData _auth = Get.find();
  final SessionService _session = Get.find();

  static const int _resendWait = 45;

  bool isResending = false;

  String get email => _session.currentUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    // الرابط أُرسل للتو عند إنشاء الحساب، فننتظر قبل السماح بإعادة الإرسال.
    startCountdown(_resendWait);
  }

  /// في مرحلة البيانات الوهمية: نحاكي أن المستخدم فتح الرابط من بريده.
  /// عند الربط الحقيقي: يفتح تطبيق البريد، والرابط يعيد المستخدم إلى A5.
  void openMailApp() => Get.toNamed(AppRoute.linkResult);

  Future<void> resend() async {
    if (isCounting || isResending) return;
    isResending = true;
    update();
    await _auth.resendVerification(email);
    isResending = false;
    showMessage('linkResent'.trParams({'email': email}));
    startCountdown(_resendWait);
  }

  /// يخرج من الحساب غير المفعّل ويعود لإنشاء حساب ببريد آخر.
  Future<void> changeEmail() async {
    await _session.clear();
    Get.offAllNamed(AppRoute.login);
    Get.toNamed(AppRoute.register);
  }
}
