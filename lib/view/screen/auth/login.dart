import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controller/auth/login_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/valid_input.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/form_error_banner.dart';
import '../../../core/shared/max_width.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_header.dart';
import '../../widget/auth/auth_title.dart';

/// A2 تسجيل الدخول: الجزء الكحلي بالأعلى، وفوقه ورقة فاتحة بزوايا 24.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.ink,
        body: SafeArea(
          bottom: false,
          // على الشاشات العريضة: الرأس والورقة بعرض محدود في منتصف الخلفية الكحلية.
          child: MaxWidth(
            child: Column(
            children: [
              const AuthHeader(),
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColor.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: GetBuilder<LoginController>(builder: (c) => _LoginForm(c: c)),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.c});

  final LoginController c;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.formKey,
      autovalidateMode: c.submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: AuthBody(
        top: 32,
        children: [
          AuthTitle(title: 'loginTitle'.tr, subtitle: 'loginSubtitle'.tr),
          const SizedBox(height: 28),
          // يسمح لمدير كلمات المرور في الهاتف بملء الحقلين.
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
                  validator: ValidInput.email,
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
                  autofillHints: const [AutofillHints.password],
                  validator: ValidInput.notEmpty,
                  onFieldSubmitted: (_) => c.login(),
                  suffix: PasswordToggle(obscured: c.obscurePassword, onPressed: c.togglePassword),
                ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppTextLink(label: 'forgotPassword'.tr, onPressed: c.goToForgotPassword),
          ),
          const SizedBox(height: 12),
          if (c.formError != null) ...[
            FormErrorBanner(message: c.formError!.trParams({'s': '${c.lockSeconds}'})),
            const SizedBox(height: 16),
          ],
          // قرار ب2: معطّل حتى يُملأ الحقلان.
          AppButton(
            label: 'loginButton'.tr,
            isLoading: c.isLoading,
            onPressed: c.canSubmit ? c.login : null,
          ),
        ],
        bottom: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('noAccount'.tr, style: const TextStyle(fontSize: 15, color: AppColor.textSecondary)),
              AppTextLink(label: 'createAccount'.tr, onPressed: c.goToRegister),
            ],
          ),
        ],
      ),
    );
  }
}
