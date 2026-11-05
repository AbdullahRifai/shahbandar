import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shared/business_profile_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_select_field.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/logo_picker_field.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../widget/trader/trader_parts.dart';

/// D3 — الملف التجاري: نفس حقول A7، للتعديل في أي وقت.
/// يظهر للطرف الآخر: التاجر في الطلبات الواردة، والمورد في صفحته.
class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessProfileController>(
      init: BusinessProfileController(),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('businessProfileTitle'.tr)),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => _Form(c: c),
          _ => const LoadingView(),
        },
        bottomNavigationBar: c.status == StatusRequest.success
            ? BottomActionBar(
                child: AppButton(
                  label: 'saveChanges'.tr,
                  isLoading: c.saving,
                  onPressed: c.canSave ? c.save : null,
                ),
              )
            : null,
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.c});

  final BusinessProfileController c;

  @override
  Widget build(BuildContext context) {
    final contactError = c.contactError;
    return MaxWidth(
      child: Form(
        key: c.formKey,
        autovalidateMode: c.submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
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
              validator: (v) => (v ?? '').trim().isEmpty ? 'fieldRequired'.tr : null,
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
            LayoutBuilder(
              builder: (context, box) {
                final cityField = AppSelectField(
                  label: 'city'.tr,
                  options: c.cities,
                  value: c.city,
                  onChanged: c.selectCity,
                  errorText: c.cityError,
                );
                final addressField = AppTextField(
                  controller: c.address,
                  label: 'addressOptional'.tr,
                  hint: 'addressHint'.tr,
                  maxLength: 120,
                );
                // المدينة والعنوان جنباً إلى جنب حين يتسع العرض.
                if (box.maxWidth < 360) {
                  return Column(children: [cityField, const SizedBox(height: 16), addressField]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: cityField),
                    const SizedBox(width: 10),
                    Expanded(flex: 7, child: addressField),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(20),
                border: contactError == null ? null : Border.all(color: AppColor.danger, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('contactSection'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Semantics(
                    liveRegion: contactError != null,
                    child: Text(
                      contactError ?? 'contactHint'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: contactError == null ? AppColor.textSecondary : AppColor.danger,
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
                    maxLength: 11,
                    validator: c.validatePhone,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: c.contactEmail,
                    label: 'contactEmail'.tr,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    ltr: true,
                    validator: c.validateEmail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
