import 'dart:typed_data';

import 'package:get/get.dart';

import '../../data/datasource/media_data.dart';
import '../functions/pick_image.dart';
import '../functions/show_message.dart';

/// شعار النشاط (A7 إنشاء الحساب، D3 الملف التجاري): اختيار صورة من الجهاز، ورفعها، وحذفها.
/// المتحكم يستخدم [logoUrl] عند الحفظ.
mixin LogoPickerMixin on GetxController {
  /// الرابط بعد الرفع، أو الشعار المحفوظ سابقاً.
  String logoUrl = '';

  /// الصورة المختارة تظهر فوراً قبل اكتمال الرفع.
  Uint8List? logoPreview;
  double logoProgress = 0;
  bool logoUploading = false;

  bool get hasLogo => logoPreview != null || logoUrl.isNotEmpty;

  Future<void> pickLogo() async {
    if (logoUploading) return;
    final picked = await pickImages();
    if (picked.isEmpty) return;
    final image = picked.first;
    final previousUrl = logoUrl;
    logoPreview = image.bytes;
    logoUploading = true;
    logoProgress = 0;
    update();
    try {
      logoUrl = await Get.find<MediaData>().uploadImage(image, onProgress: (p) {
        logoProgress = p;
        update();
      });
    } catch (_) {
      // نرجع للشعار السابق إن فشل الرفع.
      logoPreview = null;
      logoUrl = previousUrl;
      showMessage('imageUploadFailed'.tr);
    }
    logoUploading = false;
    update();
  }

  void removeLogo() {
    logoUrl = '';
    logoPreview = null;
    update();
  }
}
