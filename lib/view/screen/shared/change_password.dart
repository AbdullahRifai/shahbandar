import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shared/change_password_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/password_rules_view.dart';
import '../../widget/trader/trader_parts.dart';

/// D7 — تغيير كلمة المرور.
/// الحالية مع "نسيتها؟"، الجديدة مع الشروط الحية (ومنها: مختلفة عن الحالية)،
/// وتوضيح أننا نبقيك داخلاً على هذا الجهاز ونُخرجك من الأجهزة الأخرى.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      init: ChangePasswordController(),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('changePassword'.tr)),
        body: MaxWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              AppTextField(
                controller: c.current,
                label: 'currentPassword'.tr,
                obscureText: c.obscureCurrent,
                ltr: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                suffix: PasswordToggle(obscured: c.obscureCurrent, onPressed: c.toggleCurrent),
              ),
              // خطأ الخادم (الحالية غير صحيحة) يظهر تحت الحقل نفسه.
              if (c.currentError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(c.currentError!, style: const TextStyle(color: AppColor.danger, fontSize: 13)),
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppTextLink(label: 'forgotIt'.tr, onPressed: c.forgot),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: c.newPassword,
                label: 'newPassword'.tr,
                obscureText: c.obscureNew,
                ltr: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                suffix: PasswordToggle(obscured: c.obscureNew, onPressed: c.toggleNew),
              ),
              const SizedBox(height: 6),
              PasswordRulesView(
                password: c.newPassword.text,
                extra: [('ruleDifferent'.tr, c.differs)],
              ),
              const SizedBox(height: 20),
              Text('passwordOtherDevices'.tr,
                  style: const TextStyle(fontSize: 14, height: 1.6, color: AppColor.textSecondary)),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          child: AppButton(
            label: 'savePassword'.tr,
            isLoading: c.saving,
            onPressed: c.canSave ? c.save : null,
          ),
        ),
      ),
    );
  }
}
