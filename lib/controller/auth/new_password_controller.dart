import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../core/functions/valid_input.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/auth_failure.dart';

/// A10 كلمة مرور جديدة (FR-6).
class NewPasswordController extends GetxController {
  final AuthData _auth = Get.find();
  final SessionService _session = Get.find();

  final String email = Get.arguments is String ? Get.arguments as String : '';
  final password = TextEditingController();

  StatusRequest statusRequest = StatusRequest.none;
  bool obscurePassword = false; // نُظهرها افتراضياً لأنه لا يوجد حقل تأكيد.

  bool get isLoading => statusRequest == StatusRequest.loading;
  bool get canSave => ValidInput.passwordValid(password.text) && !isLoading;

  @override
  void onInit() {
    super.onInit();
    password.addListener(update);
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    update();
  }

  Future<void> save() async {
    if (!canSave) return;
    statusRequest = StatusRequest.loading;
    update();
    try {
      await _auth.resetPassword(email: email, newPassword: password.text);
      // كل الجلسات تُلغى بعد تغيير كلمة المرور، ونعود للدخول من جديد.
      await _session.clear();
      Get.offAllNamed(AppRoute.login);
      showMessage('passwordChanged'.tr);
      return;
    } on AuthFailure {
      statusRequest = StatusRequest.failure;
      showMessage('errorGeneric'.tr);
    }
    update();
  }

  @override
  void onClose() {
    password.dispose();
    super.onClose();
  }
}
