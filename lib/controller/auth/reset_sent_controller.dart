import 'package:get/get.dart';

import '../../core/class/countdown_mixin.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/auth_data.dart';

/// A9 رابط الاستعادة أُرسل.
class ResetSentController extends GetxController with CountdownMixin {
  final AuthData _auth = Get.find();

  static const int _resendWait = 60;

  final String email = Get.arguments is String ? Get.arguments as String : '';
  bool isResending = false;

  @override
  void onInit() {
    super.onInit();
    startCountdown(_resendWait);
  }

  /// في مرحلة البيانات الوهمية: نحاكي فتح رابط الاستعادة من البريد.
  void openMailApp() => Get.toNamed(AppRoute.newPassword, arguments: email);

  Future<void> resend() async {
    if (isCounting || isResending) return;
    isResending = true;
    update();
    await _auth.requestPasswordReset(email);
    isResending = false;
    showMessage('linkResent'.trParams({'email': email}));
    startCountdown(_resendWait);
  }
}
