import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/link_result_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_illustration.dart';
import '../../widget/auth/auth_title.dart';

/// A5 نتيجة فتح رابط التفعيل: ثلاث حالات، لكل منها إجراء واحد.
class LinkResultScreen extends StatelessWidget {
  const LinkResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GetBuilder<LinkResultController>(
          builder: (c) {
            if (c.state == LinkState.checking) {
              return Center(
                child: Semantics(
                  label: 'linkChecking'.tr,
                  child: const CircularProgressIndicator(color: AppColor.ink),
                ),
              );
            }

            final (icon, color, bg, title, body, action) = switch (c.state) {
              LinkState.verified => (
                  Icons.check_rounded, AppColor.success, AppColor.successSoft,
                  'linkVerifiedTitle', 'linkVerifiedBody', 'continue',
                ),
              LinkState.expired => (
                  Icons.schedule_rounded, AppColor.warning, AppColor.warningSoft,
                  'linkExpiredTitle', 'linkExpiredBody', 'sendNewLink',
                ),
              _ => (
                  Icons.mark_email_read_outlined, AppColor.info, AppColor.infoSoft,
                  'linkAlreadyTitle', 'linkAlreadyBody', 'continue',
                ),
            };

            return AuthBody(
              top: 120,
              centered: true,
              children: [
                AuthIllustration(icon: icon, color: color, background: bg, circle: true),
                const SizedBox(height: 28),
                AuthTitle(title: title.tr, subtitle: body.tr, centered: true),
              ],
              bottom: [
                SizedBox(
                  width: double.infinity,
                  child: AppButton(label: action.tr, isLoading: c.isBusy, onPressed: c.onPrimary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
