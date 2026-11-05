import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/constant/app_routes.dart';
import '../../data/datasource/admin_data.dart';
import '../../data/model/auth_failure.dart';

/// E1 — دخول الإدارة (FR-61). لا تسجيل ذاتي: الحسابات يُنشئها الفريق.
/// الزر معطّل حتى يُكتب البريد وكلمة المرور، والخطأ رسالة واحدة لا تكشف أيهما الخاطئ.
class AdminLoginController extends GetxController {
  final AdminData _data = Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  bool loading = false;
  String? error;

  @override
  void onInit() {
    super.onInit();
    for (final c in [email, password]) {
      c.addListener(() {
        error = null;
        update();
      });
    }
  }

  bool get canSubmit => email.text.trim().isNotEmpty && password.text.isNotEmpty && !loading;

  void toggleObscure() {
    obscure = !obscure;
    update();
  }

  Future<void> submit() async {
    if (!canSubmit) return;
    loading = true;
    update();
    try {
      await _data.login(email: email.text, password: password.text);
      Get.offAllNamed(AppRoute.adminHome);
      return;
    } on AuthFailure catch (e) {
      error = e.type == AuthFailureType.offline ? 'errorOffline'.tr : 'adminLoginFailed'.tr;
    } catch (_) {
      error = 'errorGeneric'.tr;
    }
    loading = false;
    update();
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
