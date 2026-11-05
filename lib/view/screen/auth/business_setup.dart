import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/business_setup_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/valid_input.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_select_field.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/logo_picker_field.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_title.dart';
import '../../widget/auth/auth_top_bar.dart';
import '../../widget/auth/steps_indicator.dart';

/// A7 الملف التجاري لأول مرة: المرحلة 4 من 4 (FR-11 إلى FR-14).
/// الرجوع مسموح هنا لتعديل الأدوار.
class BusinessSetupScreen extends StatelessWidget {
  const BusinessSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthTopBar(title: 'createAccountBar'.tr),
            const StepsIndicator(current: 3),
            Expanded(
              child: GetBuilder<BusinessSetupController>(
                builder: (c) => Form(
                  key: c.formKey,
                  autovalidateMode:
                      c.submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                  child: AuthBody(
                    top: 28,
                    children: [
                      AuthTitle(title: 'profileTitle'.tr, subtitle: 'profileSubtitle'.tr),
                      const SizedBox(height: 20),
                      LogoPickerField(
                        url: c.logoUrl,
                        preview: c.logoPreview,
                        uploading: c.logoUploading,
                        progress: c.logoProgress,
                        onPick: c.pickLogo,
                        onRemove: c.removeLogo,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: c.name,
                        label: 'businessName'.tr,
                        textInputAction: TextInputAction.next,
                        maxLength: 80,
                        validator: ValidInput.notEmpty,
                      ),
                      const SizedBox(height: 16),
                      AppSelectField(
                        label: 'businessCategory'.tr,
                        options: c.categories,
                        value: c.category,
                        onChanged: c.selectCategory,
                        errorText: c.categoryError,
                      ),
                      const SizedBox(height: 16),
                      AppSelectField(
                        label: 'city'.tr,
                        options: c.cities,
                        value: c.city,
                        onChanged: c.selectCity,
                        errorText: c.cityError,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: c.address,
                        label: 'addressOptional'.tr,
                        hint: 'addressHint'.tr,
                        textInputAction: TextInputAction.next,
                        maxLength: 120,
                      ),
                      const SizedBox(height: 20),
                      _ContactSection(c: c),
                    ],
                    bottom: [
                      AppButton(
                        label: 'saveAndStart'.tr,
                        isLoading: c.isLoading,
                        // لا حفظ قبل اكتمال رفع الشعار.
                        onPressed: c.logoUploading ? null : c.save,
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

/// FR-13: الهاتف أو البريد، واحد على الأقل. الخطأ يظهر للمجموعة كلها.
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.c});

  final BusinessSetupController c;

  @override
  Widget build(BuildContext context) {
    final error = c.contactError;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: error == null ? null : Border.all(color: AppColor.danger, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'contactSection'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.ink),
          ),
          const SizedBox(height: 2),
          Semantics(
            liveRegion: error != null,
            child: Text(
              error ?? 'contactHint'.tr,
              style: TextStyle(
                fontSize: 13,
                color: error == null ? AppColor.textSecondary : AppColor.danger,
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: c.phone,
            label: 'phone'.tr,
            hint: '9XX XXX XXX',
            prefixText: '+963',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            ltr: true,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            maxLength: 11,
            validator: ValidInput.optionalPhone,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: c.contactEmail,
            label: 'contactEmail'.tr,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            ltr: true,
            validator: ValidInput.optionalEmail,
          ),
        ],
      ),
    );
  }
}
