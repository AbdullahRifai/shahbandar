import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../core/functions/valid_input.dart';
import '../../data/datasource/account_data.dart';
import '../../data/model/auth_failure.dart';

/// D7 — تغيير كلمة المرور.
/// نفس شروط A3/A10، وشرط إضافي: مختلفة عن الحالية.
/// الزر معطّل حتى تُكتب الحالية وتتحقق كل الشروط.
class ChangePasswordController extends GetxController {
  final AccountData _data = Get.find();

  final current = TextEditingController();
  final newPassword = TextEditingController();
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool saving = false;

  /// خطأ من الخادم على الحقل الأول (الحالية غير صحيحة).
  String? currentError;

  @override
  void onInit() {
    super.onInit();
    current.addListener(() {
      currentError = null;
      update();
    });
    newPassword.addListener(update);
  }

  bool get differs => newPassword.text.isNotEmpty && newPassword.text != current.text;
  bool get rulesMet => ValidInput.passwordValid(newPassword.text) && differs;
  bool get canSave => current.text.isNotEmpty && rulesMet && !saving;

  void toggleCurrent() {
    obscureCurrent = !obscureCurrent;
    update();
  }

  void toggleNew() {
    obscureNew = !obscureNew;
    update();
  }

  void forgot() => Get.toNamed(AppRoute.forgotPassword);

  Future<void> save() async {
    if (!canSave) return;
    saving = true;
    update();
    try {
      await _data.changePassword(current: current.text, newPassword: newPassword.text);
      saving = false;
      Get.back();
      showMessage('passwordChanged'.tr);
      return;
    } on AuthFailure catch (e) {
      if (e.type == AuthFailureType.invalidCredentials) {
        currentError = 'currentPasswordWrong'.tr;
      } else {
        showMessage(e.type == AuthFailureType.offline ? 'errorOffline'.tr : 'errorGeneric'.tr);
      }
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    saving = false;
    update();
  }

  @override
  void onClose() {
    current.dispose();
    newPassword.dispose();
    super.onClose();
  }
}
