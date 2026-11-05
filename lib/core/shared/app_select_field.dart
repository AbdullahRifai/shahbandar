import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/option_model.dart';
import '../constant/app_color.dart';

/// حقل اختيار من قائمة ثابتة (FR-14: لا يكتب المستخدم قيمة جديدة).
/// شكله مثل AppTextField، والضغط عليه يفتح نافذة سفلية بالخيارات.
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final List<OptionModel> options;
  final OptionModel? value;
  final ValueChanged<OptionModel> onChanged;
  final String? errorText;

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<OptionModel>(
      context: context,
      showDragHandle: true,
      // على الشاشات العريضة لا تمتد النافذة على كامل العرض.
      constraints: const BoxConstraints(maxWidth: 560),
      backgroundColor: AppColor.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _OptionsSheet(title: label, options: options, selected: value),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.ink),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: '$label، ${value?.label ?? 'chooseOption'.tr}',
          excludeSemantics: true,
          child: Material(
            color: AppColor.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: hasError ? AppColor.danger : AppColor.border,
                width: 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: options.isEmpty ? null : () => _open(context),
              child: SizedBox(
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value?.label ?? 'chooseOption'.tr,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: value == null ? AppColor.textSecondary : AppColor.ink,
                          ),
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded, color: AppColor.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, start: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColor.danger, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  const _OptionsSheet({required this.title, required this.options, this.selected});

  final String title;
  final List<OptionModel> options;
  final OptionModel? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColor.ink),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                children: [
                  for (final option in options)
                    OptionTile(
                      label: option.label,
                      selected: option == selected,
                      onTap: () => Navigator.pop(context, option),
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

/// سطر خيار عام: دائرة اختيار + نص، والمحدد بخلفية برتقالية خفيفة.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.textDirection,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: selected ? AppColor.orangeSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColor.ink : AppColor.borderStrong,
                          width: selected ? 6 : 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        textDirection: textDirection,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.ink,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
