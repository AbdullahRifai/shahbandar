import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/check_email_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_illustration.dart';
import '../../widget/auth/auth_title.dart';
import '../../widget/auth/auth_top_bar.dart';
import '../../widget/auth/steps_indicator.dart';

/// A4 تفعيل البريد: المرحلة 2 من 4.
/// بلا زر رجوع: الحساب أُنشئ، و"تغيير البريد" هو طريق العودة الصحيح.
class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthTopBar(title: 'createAccountBar'.tr, showBack: false),
            const StepsIndicator(current: 1),
            Expanded(
              child: GetBuilder<CheckEmailController>(
                builder: (c) => AuthBody(
                  top: 48,
                  centered: true,
                  children: [
                    const AuthIllustration(icon: Icons.mail_outline_rounded, badge: true),
                    const SizedBox(height: 32),
                    AuthTitle(title: 'checkEmailTitle'.tr, subtitle: 'checkEmailSentTo'.tr, centered: true),
                    const SizedBox(height: 2),
                    Text(
                      c.email,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColor.ink),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'checkEmailNote'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, height: 1.6, color: AppColor.textSecondary),
                    ),
                  ],
                  bottom: [
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(label: 'openMailApp'.tr, onPressed: c.openMailApp),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        style: AppButtonStyle.secondary,
                        label: c.isCounting
                            ? 'resendIn'.trParams({'t': c.countdownText})
                            : 'resendLink'.tr,
                        isLoading: c.isResending,
                        onPressed: c.isCounting ? null : c.resend,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppTextLink(label: 'changeEmail'.tr, onPressed: c.changeEmail),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
