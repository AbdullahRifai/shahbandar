import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_routes.dart';
import '../../../core/functions/show_message.dart';
import '../../../core/shared/app_button.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_illustration.dart';
import '../../widget/auth/auth_title.dart';

/// A11 حساب موقوف (FR-9). نبرة محايدة بلا لوم، وطريق واضح للتواصل.
/// بلا متحكم: لا حالة ولا بيانات، فقط عرض.
class AccountDisabledScreen extends StatelessWidget {
  const AccountDisabledScreen({super.key});

  static const String _supportEmail = 'support@shahbandar.example';

  Future<void> _copySupportEmail() async {
    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    showMessage('emailCopied'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AuthBody(
          top: 120,
          centered: true,
          children: [
            const AuthIllustration(
              icon: Icons.block_rounded,
              color: AppColor.textNote,
              background: AppColor.neutralSoft,
              circle: true,
            ),
            const SizedBox(height: 28),
            AuthTitle(title: 'disabledTitle'.tr, subtitle: 'disabledBody'.tr, centered: true),
            const SizedBox(height: 24),
            Material(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _copySupportEmail,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'disabledContact'.tr,
                              style: const TextStyle(fontSize: 14, color: AppColor.textSecondary),
                            ),
                            const Text(
                              _supportEmail,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColor.orangeDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.copy_rounded, size: 20, semanticLabel: 'copy'.tr, color: AppColor.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ],
          bottom: [
            SizedBox(
              width: double.infinity,
              child: AppButton(
                style: AppButtonStyle.secondary,
                label: 'backToLogin'.tr,
                onPressed: () => Get.offAllNamed(AppRoute.login),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
