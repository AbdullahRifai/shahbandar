import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/register_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/form_error_banner.dart';
import '../../../core/shared/password_rules_view.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_title.dart';
import '../../widget/auth/auth_top_bar.dart';
import '../../widget/auth/steps_indicator.dart';

/// A3 إنشاء حساب: المرحلة 1 من 4.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthTopBar(title: 'createAccountBar'.tr),
            const StepsIndicator(current: 0),
            Expanded(
              child: GetBuilder<RegisterController>(
                builder: (c) => Form(
                  key: c.formKey,
                  autovalidateMode:
                      c.submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                  child: AuthBody(
                    top: 28,
                    children: [
                      AuthTitle(title: 'registerTitle'.tr, subtitle: 'registerSubtitle'.tr),
                      const SizedBox(height: 24),
                      AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: c.email,
                              label: 'email'.tr,
                              hint: 'name@company.com',
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              ltr: true,
                              autofillHints: const [AutofillHints.email],
                              validator: c.validateEmail,
                              onFieldSubmitted: (_) => c.passwordFocus.requestFocus(),
                            ),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: c.password,
                              focusNode: c.passwordFocus,
                              label: 'password'.tr,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: c.obscurePassword,
                              textInputAction: TextInputAction.done,
                              ltr: true,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => c.register(),
                              suffix: PasswordToggle(
                                obscured: c.obscurePassword,
                                onPressed: c.togglePassword,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      PasswordRulesView(password: c.password.text),
                      const SizedBox(height: 24),
                      if (c.formError != null) ...[
                        FormErrorBanner(message: c.formError!.tr),
                        const SizedBox(height: 16),
                      ],
                      // قرار ب1: سطر الموافقة فوق الزر بلا خانة اختيار.
                      Text.rich(
                        TextSpan(
                          text: 'termsPrefix'.tr,
                          children: [
                            TextSpan(
                              text: 'termsOfUse'.tr,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColor.ink),
                            ),
                            TextSpan(text: 'termsAnd'.tr),
                            TextSpan(
                              text: 'privacyPolicy'.tr,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColor.ink),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        style: const TextStyle(fontSize: 13, height: 1.6, color: AppColor.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'registerButton'.tr,
                        isLoading: c.isLoading,
                        onPressed: c.canSubmit ? c.register : null,
                      ),
                    ],
                    bottom: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'haveAccount'.tr,
                            style: const TextStyle(fontSize: 15, color: AppColor.textSecondary),
                          ),
                          AppTextLink(label: 'loginButton'.tr, onPressed: c.goToLogin),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
