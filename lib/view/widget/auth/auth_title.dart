import 'package:flutter/material.dart';

import '../../../core/constant/app_color.dart';

/// العنوان والوصف أعلى شاشات الحساب، بنفس السلّم في كل الشاشات.
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.title, this.subtitle, this.centered = false});

  final String title;
  final String? subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: align,
            style: const TextStyle(
              fontSize: 24,
              height: 1.33,
              fontWeight: FontWeight.w700,
              color: AppColor.ink,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: align,
            style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary),
          ),
        ],
      ],
    );
  }
}
