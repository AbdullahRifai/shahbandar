import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/valid_input.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/auth_failure.dart';

/// A3 إنشاء حساب (FR-1، FR-2).
class RegisterController extends GetxController {
  final AuthData _auth = Get.find();
  final SessionService _session = Get.find();

  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final passwordFocus = FocusNode();

  StatusRequest statusRequest = StatusRequest.none;
  bool obscurePassword = true;
  bool submitted = false;

  /// "البريد مسجل مسبقاً" يظهر تحت حقل البريد نفسه.
  String? emailTakenError;
  String? formError;

  bool get isLoading => statusRequest == StatusRequest.loading;

  /// الزر معطّل حتى يُكتب البريد وتتحقق كل شروط كلمة المرور.
  bool get canSubmit =>
      email.text.trim().isNotEmpty && ValidInput.passwordValid(password.text) && !isLoading;

  @override
  void onInit() {
    super.onInit();
    email.addListener(() {
      emailTakenError = null;
      formError = null;
      update();
    });
    password.addListener(update);
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    update();
  }

  /// يجمع خطأ "مسجل مسبقاً" مع قواعد صيغة البريد.
  String? validateEmail(String? value) => emailTakenError ?? ValidInput.email(value);

  Future<void> register() async {
    if (!canSubmit) return;
    submitted = true;
    if (!(formKey.currentState?.validate() ?? false)) return update();

    statusRequest = StatusRequest.loading;
    update();

    try {
      final user = await _auth.register(email: email.text.trim(), password: password.text);
      await _session.start(user);
      // الحساب أُنشئ ورابط التفعيل أُرسل، فلا رجوع لهذه الشاشة.
      Get.offAllNamed(AppRoute.checkEmail);
      return;
    } on AuthFailure catch (failure) {
      statusRequest = StatusRequest.failure;
      if (failure.type == AuthFailureType.emailTaken) {
        emailTakenError = 'emailTaken'.tr;
        formKey.currentState?.validate();
      } else {
        formError = failure.type == AuthFailureType.offline ? 'errorOffline' : 'errorGeneric';
      }
    }
    update();
  }

  void goToLogin() => Get.back();

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
