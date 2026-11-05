import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/home_route.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/auth_failure.dart';

/// A2 تسجيل الدخول.
class LoginController extends GetxController {
  final AuthData _auth = Get.find();
  final SessionService _session = Get.find();

  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final passwordFocus = FocusNode();

  StatusRequest statusRequest = StatusRequest.none;
  bool obscurePassword = true;

  /// قرار أ1: لا أخطاء حقول قبل أول محاولة، ثم تتحدث أثناء الكتابة.
  bool submitted = false;

  /// خطأ عام (مفتاح ترجمة) يظهر فوق الزر.
  String? formError;

  /// ثوانٍ متبقية بعد "محاولات كثيرة".
  int lockSeconds = 0;
  Timer? _lockTimer;

  bool get isLoading => statusRequest == StatusRequest.loading;

  /// قرار ب2: الزر معطّل حتى يُملأ الحقلان.
  bool get canSubmit =>
      email.text.trim().isNotEmpty && password.text.isNotEmpty && !isLoading && lockSeconds == 0;

  @override
  void onInit() {
    super.onInit();
    email.addListener(_onChanged);
    password.addListener(_onChanged);
  }

  void _onChanged() {
    // الكتابة تعني أن المستخدم يصحح، فنُخفي الخطأ العام.
    if (formError != null && lockSeconds == 0) formError = null;
    update();
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    update();
  }

  Future<void> login() async {
    if (!canSubmit) return;
    submitted = true;
    if (!(formKey.currentState?.validate() ?? false)) return update();

    statusRequest = StatusRequest.loading;
    formError = null;
    update();

    try {
      final user = await _auth.login(email: email.text.trim(), password: password.text);
      statusRequest = StatusRequest.success;
      await _session.start(user);
      Get.offAllNamed(homeRouteFor(user));
      return;
    } on AuthFailure catch (failure) {
      statusRequest = StatusRequest.failure;
      switch (failure.type) {
        case AuthFailureType.accountDisabled:
          Get.offAllNamed(AppRoute.accountDisabled);
          return;
        case AuthFailureType.tooManyAttempts:
          _startLock(failure.retryAfter);
        case AuthFailureType.invalidCredentials:
          // رسالة واحدة لا تكشف أيهما الخطأ.
          formError = 'loginInvalid';
        case AuthFailureType.offline:
          formError = 'errorOffline';
        default:
          formError = 'errorGeneric';
      }
    }
    update();
  }

  void _startLock(int seconds) {
    lockSeconds = seconds;
    formError = 'loginTooMany';
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      lockSeconds--;
      if (lockSeconds <= 0) {
        lockSeconds = 0;
        formError = null;
        timer.cancel();
      }
      update();
    });
  }

  void goToRegister() => Get.toNamed(AppRoute.register);

  /// نمرر البريد المكتوب حتى لا يكتبه المستخدم مرتين.
  void goToForgotPassword() =>
      Get.toNamed(AppRoute.forgotPassword, arguments: email.text.trim());

  @override
  void onClose() {
    _lockTimer?.cancel();
    email.dispose();
    password.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
