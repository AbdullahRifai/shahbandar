import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/constant/image_asset.dart';

/// شعار شاهبندر في مربع برتقالي، مع اسم اللوحة بالأبيض (فوق الكحلي).
class AdminBrand extends StatelessWidget {
  const AdminBrand({super.key, required this.label, this.size = 32});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.14),
          decoration: BoxDecoration(color: AppColor.orange, borderRadius: BorderRadius.circular(size * 0.29)),
          child: SvgPicture.asset(AppImageAsset.logo, semanticsLabel: 'logoLabel'.tr),
        ),
        SizedBox(width: size * 0.3),
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: AppColor.surface, fontSize: size >= 48 ? 22 : 17, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
