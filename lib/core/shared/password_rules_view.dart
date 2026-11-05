import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_color.dart';
import '../functions/valid_input.dart';

/// قائمة شروط كلمة المرور، تتحقق أثناء الكتابة (A3، A10).
/// كل شرط يتحول من دائرة رمادية إلى علامة خضراء عند تحققه.
class PasswordRulesView extends StatelessWidget {
  const PasswordRulesView({super.key, required this.password, this.extra = const []});

  final String password;

  /// شروط إضافية خاصة بشاشة، مثل "مختلفة عن الحالية" في D7: (النص، متحقق؟).
  final List<(String, bool)> extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rule in ValidInput.passwordRules)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _RuleRow(label: rule.labelKey.tr, met: rule.isMet(password)),
          ),
        for (final (label, met) in extra)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _RuleRow(label: label, met: met),
          ),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColor.success : AppColor.textSecondary;
    return Semantics(
      // يقرأ قارئ الشاشة حالة الشرط، لا اللون فقط.
      label: '$label، ${met ? 'ruleMet'.tr : 'ruleNotMet'.tr}',
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: met ? AppColor.success : AppColor.borderStrong,
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
