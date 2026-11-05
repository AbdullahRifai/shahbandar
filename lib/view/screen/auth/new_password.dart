import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/new_password_controller.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/password_rules_view.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_title.dart';

/// A10 كلمة مرور جديدة. تُفتح من رابط البريد، فلا زر رجوع.
class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GetBuilder<NewPasswordController>(
          builder: (c) => AuthBody(
            top: 72,
            children: [
              AuthTitle(title: 'newPasswordTitle'.tr, subtitle: 'newPasswordSubtitle'.tr),
              const SizedBox(height: 28),
              AutofillGroup(
                child: AppTextField(
                  controller: c.password,
                  label: 'newPasswordLabel'.tr,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: c.obscurePassword,
                  textInputAction: TextInputAction.done,
                  ltr: true,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => c.save(),
                  suffix: PasswordToggle(obscured: c.obscurePassword, onPressed: c.togglePassword),
                ),
              ),
              const SizedBox(height: 4),
              PasswordRulesView(password: c.password.text),
              const SizedBox(height: 28),
              AppButton(
                label: 'savePassword'.tr,
                isLoading: c.isLoading,
                onPressed: c.canSave ? c.save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
