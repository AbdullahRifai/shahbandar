import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_color.dart';
import 'app_image.dart';

/// حقل شعار النشاط: مربع 72 يعرض الشعار الذي رفعه المستخدم، أو أيقونة "إضافة صورة".
/// أثناء الرفع تظهر النسبة فوق الصورة. بعد الرفع: "تغيير" و"حذف".
class LogoPickerField extends StatelessWidget {
  const LogoPickerField({
    super.key,
    required this.url,
    required this.preview,
    required this.uploading,
    required this.progress,
    required this.onPick,
    required this.onRemove,
  });

  final String url;
  final Uint8List? preview;
  final bool uploading;
  final double progress;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  bool get _has => preview != null || url.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final empty = Center(
      child: Icon(Icons.add_a_photo_outlined, color: _has ? AppColor.textSecondary : AppColor.ink),
    );
    return Row(
      children: [
        Semantics(
          button: true,
          label: _has ? 'changeLogo'.tr : 'businessLogo'.tr,
          excludeSemantics: true,
          child: Material(
            color: AppColor.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: _has ? AppColor.border : AppColor.borderStrong, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: uploading ? null : onPick,
              child: SizedBox.square(
                dimension: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (preview != null)
                      Image.memory(preview!, fit: BoxFit.cover, gaplessPlayback: true)
                    else
                      AppImage(url: url, placeholder: empty),
                    if (uploading)
                      ColoredBox(
                        color: const Color(0x8017202E),
                        child: Center(
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(color: AppColor.surface, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('businessLogo'.tr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColor.ink)),
              Text(
                uploading ? 'imageUploadingShort'.tr : 'businessLogoHint'.tr,
                style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
              ),
              if (_has && !uploading)
                Wrap(
                  children: [
                    _link('changeLogo'.tr, AppColor.orangeDeep, onPick),
                    _link('removeLogo'.tr, AppColor.danger, onRemove),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _link(String label, Color color, VoidCallback onTap) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );
}
