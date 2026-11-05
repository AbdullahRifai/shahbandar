import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/constant/image_asset.dart';

/// شعار شاشة البداية (A1).
///
/// المربع البرتقالي في مركز الشاشة تماماً، في نفس مكان شعار شاشة النظام،
/// فلا "يقفز" عند الانتقال. لذلك فوقه مساحة شفافة تعادل (المسافة + اسم التطبيق).
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  static const double _gap = 20;
  static const double _wordHeight = 40;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'logoLabel'.tr,
      image: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: _gap + _wordHeight), // موازن غير مرئي
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: AppColor.orange,
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(AppImageAsset.logo, width: 72, height: 72),
          ),
          const SizedBox(height: _gap),
          SizedBox(
            height: _wordHeight,
            child: Text(
              'appName'.tr,
              textScaler: TextScaler.noScaling, // كلمة الشعار لا تتكبر
              style: const TextStyle(
                color: AppColor.surface,
                fontSize: 30,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
