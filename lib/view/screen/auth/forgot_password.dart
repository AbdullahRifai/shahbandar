import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/forgot_password_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/valid_input.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_text_field.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_title.dart';
import '../../widget/auth/auth_top_bar.dart';

/// A8 استعادة كلمة المرور: إدخال البريد.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AuthTopBar(),
            Expanded(
              child: GetBuilder<ForgotPasswordController>(
                builder: (c) => Form(
                  key: c.formKey,
                  autovalidateMode:
                      c.submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                  child: AuthBody(
                    top: 16,
                    children: [
                      AuthTitle(title: 'forgotTitle'.tr, subtitle: 'forgotSubtitle'.tr),
                      const SizedBox(height: 28),
                      AppTextField(
                        controller: c.email,
                        label: 'email'.tr,
                        hint: 'name@company.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.send,
                        ltr: true,
                        autofillHints: const [AutofillHints.email],
                        validator: ValidInput.email,
                        onFieldSubmitted: (_) => c.send(),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'sendResetLink'.tr,
                        isLoading: c.isLoading,
                        onPressed: c.canSubmit ? c.send : null,
                      ),
                    ],
                    bottom: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'rememberedIt'.tr,
                            style: const TextStyle(fontSize: 15, color: AppColor.textSecondary),
                          ),
                          AppTextLink(label: 'loginButton'.tr, onPressed: () => Get.back()),
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
