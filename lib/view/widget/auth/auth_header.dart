import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/constant/image_asset.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/shared/language_sheet.dart';

/// الجزء الكحلي أعلى شاشة الدخول (A2): زر اللغة، الشعار، والاسم.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: AlignmentDirectional.centerEnd, child: _LanguageButton()),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColor.orange,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  AppImageAsset.logo,
                  width: 34,
                  height: 34,
                  semanticsLabel: 'logoLabel'.tr,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'appName'.tr,
                      style: const TextStyle(
                        color: AppColor.surface,
                        fontSize: 26,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'tagline'.tr,
                      style: const TextStyle(color: AppColor.textOnInkSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// يعرض اسم اللغة الأخرى بلغتها، ويفتح نافذة اللغة (A12).
class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.find<LocaleController>().isArabic;
    return OutlinedButton.icon(
      onPressed: () => showLanguageSheet(context),
      icon: const Icon(Icons.language_rounded, size: 18),
      label: Text(isArabic ? 'English' : 'العربية'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE8EBF0),
        side: const BorderSide(color: Color(0xFF3A4456)),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        // الشكل 40، ومساحة اللمس 48.
        tapTargetSize: MaterialTapTargetSize.padded,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
