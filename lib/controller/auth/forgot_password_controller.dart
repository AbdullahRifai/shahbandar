import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/auth_failure.dart';

/// A8 استعادة كلمة المرور: إدخال البريد (FR-6، جدول 9.13).
class ForgotPasswordController extends GetxController {
  final AuthData _auth = Get.find();

  final formKey = GlobalKey<FormState>();

  /// يبدأ بالبريد الذي كتبه المستخدم في شاشة الدخول، إن وُجد.
  final email = TextEditingController(text: Get.arguments is String ? Get.arguments as String : '');

  StatusRequest statusRequest = StatusRequest.none;
  bool submitted = false;

  bool get isLoading => statusRequest == StatusRequest.loading;
  bool get canSubmit => email.text.trim().isNotEmpty && !isLoading;

  @override
  void onInit() {
    super.onInit();
    email.addListener(update);
  }

  Future<void> send() async {
    if (!canSubmit) return;
    submitted = true;
    if (!(formKey.currentState?.validate() ?? false)) return update();

    statusRequest = StatusRequest.loading;
    update();
    try {
      await _auth.requestPasswordReset(email.text.trim());
      statusRequest = StatusRequest.success;
      // نفس النتيجة سواء كان البريد مسجلاً أم لا، فلا نكشف من لديه حساب.
      Get.toNamed(AppRoute.resetSent, arguments: email.text.trim());
    } on AuthFailure {
      statusRequest = StatusRequest.failure;
      showMessage('errorGeneric'.tr);
    }
    update();
  }

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}
