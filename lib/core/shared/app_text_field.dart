import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_color.dart';

/// الحقل الموحّد في كل التطبيق.
/// - العنوان فوق الحقل دائماً (لا يختفي عند الكتابة).
/// - حدّ رمادي، يصير كحلياً سميكاً عند التركيز، وأحمر عند الخطأ.
/// - الخطأ يظهر تحت الحقل نفسه.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
    this.ltr = false,
    this.focusNode,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;

  /// نص ثابت قبل القيمة، مثل +963.
  final String? prefixText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  /// للبريد وكلمة المرور والهاتف: الكتابة من اليسار حتى في الواجهة العربية.
  final bool ltr;
  final FocusNode? focusNode;
  final int? maxLength;

  static OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.ink),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enableSuggestions: !obscureText,
          autocorrect: !obscureText && !ltr,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          maxLength: maxLength,
          textDirection: ltr ? TextDirection.ltr : null,
          // النص اللاتيني يبقى ملاصقاً لجهة بداية الواجهة.
          textAlign: ltr ? (isRtl ? TextAlign.right : TextAlign.left) : TextAlign.start,
          style: const TextStyle(fontSize: 16, color: AppColor.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: ltr ? TextDirection.ltr : null,
            hintStyle: const TextStyle(color: AppColor.textSecondary),
            counterText: '',
            filled: true,
            fillColor: AppColor.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            // prefixIcon يبقى ظاهراً دائماً (بخلاف prefix الذي يظهر عند التركيز فقط).
            prefixIcon: prefixText != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
                    child: Text(
                      prefixText!,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(fontSize: 16, color: AppColor.textSecondary),
                    ),
                  )
                : (prefixIcon == null
                    ? null
                    : Icon(prefixIcon, size: 22, color: AppColor.textSecondary)),
            prefixIconConstraints: prefixText != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: suffix,
            border: _border(AppColor.border, 1.5),
            enabledBorder: _border(AppColor.border, 1.5),
            focusedBorder: _border(AppColor.ink, 2),
            errorBorder: _border(AppColor.danger, 1.5),
            focusedErrorBorder: _border(AppColor.danger, 2),
            errorStyle: const TextStyle(color: AppColor.danger, fontSize: 13, height: 1.4),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

/// زر إظهار وإخفاء كلمة المرور، يوضع في [AppTextField.suffix].
class PasswordToggle extends StatelessWidget {
  const PasswordToggle({super.key, required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: obscured ? 'showPassword'.tr : 'hidePassword'.tr,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColor.textSecondary,
      ),
    );
  }
}
