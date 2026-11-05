import 'package:flutter/material.dart';

import '../constant/app_color.dart';

/// خطأ عام للنموذج (ليس خاصاً بحقل واحد)، يُعلَن لقارئ الشاشة فور ظهوره.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.dangerSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.error_outline_rounded, size: 20, color: AppColor.danger),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColor.dangerText, fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
