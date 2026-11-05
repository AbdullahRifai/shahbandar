import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/reset_sent_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/info_note.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_illustration.dart';
import '../../widget/auth/auth_title.dart';
import '../../widget/auth/auth_top_bar.dart';

/// A9 رابط الاستعادة أُرسل. نفس قالب A4 حتى يعرفه المستخدم من أول نظرة.
class ResetSentScreen extends StatelessWidget {
  const ResetSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AuthTopBar(),
            Expanded(
              child: GetBuilder<ResetSentController>(
                builder: (c) => AuthBody(
                  top: 40,
                  centered: true,
                  children: [
                    const AuthIllustration(icon: Icons.lock_reset_rounded),
                    const SizedBox(height: 32),
                    AuthTitle(title: 'resetSentTitle'.tr, subtitle: 'resetSentBody'.tr, centered: true),
                    const SizedBox(height: 4),
                    Text(
                      c.email,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColor.ink),
                    ),
                    const SizedBox(height: 20),
                    InfoNote(text: 'resetLinkNote'.tr, icon: Icons.schedule_rounded),
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
