import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_login_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/form_error_banner.dart';
import '../../widget/admin/admin_brand.dart';

/// E1 — دخول الإدارة.
/// عريض: لوح كحلي بالهوية والتنبيه، وبجانبه النموذج. ضيق: اللوح فوق النموذج.
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= 860;
          final brand = Container(
            color: AppColor.ink,
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AdminBrand(label: 'adminPanelTitle'.tr, size: 52),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Text('adminLoginNote'.tr,
                      style: const TextStyle(color: AppColor.textOnInkSecondary, fontSize: 15, height: 1.6)),
                ),
              ],
            ),
          );
          const form = _Form();
          if (wide) {
            return Row(
              children: [
                Expanded(flex: 10, child: brand),
                const Expanded(flex: 13, child: Center(child: SingleChildScrollView(child: form))),
              ],
            );
          }
          return ListView(children: [brand, const Padding(padding: EdgeInsets.all(24), child: form)]);
        },
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminLoginController>(
      builder: (c) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text('adminLoginTitle'.tr, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Text('adminLoginSubtitle'.tr, style: const TextStyle(fontSize: 15, color: AppColor.textSecondary)),
                const SizedBox(height: 20),
                if (c.error != null) ...[
                  FormErrorBanner(message: c.error!),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: c.email,
                  label: 'email'.tr,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  ltr: true,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: c.password,
                  label: 'password'.tr,
                  obscureText: c.obscure,
                  ltr: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => c.submit(),
                  suffix: PasswordToggle(obscured: c.obscure, onPressed: c.toggleObscure),
                ),
                const SizedBox(height: 24),
                AppButton(label: 'adminLoginButton'.tr, isLoading: c.loading, onPressed: c.canSubmit ? c.submit : null),
                const SizedBox(height: 16),
                Text('adminNoSignup'.tr, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
