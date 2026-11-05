import 'package:flutter/material.dart';

import '../../../core/constant/app_color.dart';

/// الرمز الكبير في وسط شاشات الحالة (A4، A5، A9، A11).
///
/// [circle] = true: دائرة ملوّنة بلون الحالة (نجاح، تنبيه، موقوف).
/// [circle] = false: مربع أبيض بحدّ رمادي (بريد، قفل).
/// [badge]: علامة برتقالية صغيرة في الزاوية (أُرسل الرابط).
class AuthIllustration extends StatelessWidget {
  const AuthIllustration({
    super.key,
    required this.icon,
    this.color = AppColor.ink,
    this.background = AppColor.surface,
    this.circle = false,
    this.badge = false,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final bool circle;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: 120,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: background,
                borderRadius: circle ? null : BorderRadius.circular(32),
                shape: circle ? BoxShape.circle : BoxShape.rectangle,
                border: circle ? null : Border.all(color: AppColor.divider, width: 1.5),
              ),
              child: Icon(icon, size: 52, color: color),
            ),
            if (badge)
              PositionedDirectional(
                top: -4,
                end: -4,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColor.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.background, width: 3),
                  ),
                  child: const Icon(Icons.check_rounded, size: 18, color: AppColor.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
