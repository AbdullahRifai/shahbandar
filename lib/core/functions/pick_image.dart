import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/model/picked_image.dart';
import '../constant/app_color.dart';
import 'show_message.dart';

/// أقصى حجم للصورة بعد ضغطها.
const int maxImageBytes = 5 * 1024 * 1024;

const _allowed = ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'];

/// الكاميرا متاحة على الهاتف فقط. على Windows والويب يُفتح اختيار الملفات مباشرة.
bool get _cameraAvailable =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

/// يطلب من المستخدم صورة أو أكثر (حتى [max]):
/// على الهاتف تظهر نافذة "المعرض أو الكاميرا"، ثم تُضغط الصورة (1600 بكسل، جودة 85)
/// ويُتحقق من نوعها وحجمها. يرجع قائمة فارغة إن ألغى المستخدم.
Future<List<PickedImage>> pickImages({int max = 1}) async {
  if (max < 1) return [];
  final source = _cameraAvailable ? await _chooseSource() : ImageSource.gallery;
  if (source == null) return [];

  final picker = ImagePicker();
  const maxSide = 1600.0;
  const quality = 85;
  List<XFile> files;
  try {
    if (source == ImageSource.gallery && max > 1) {
      files = await picker.pickMultiImage(maxWidth: maxSide, maxHeight: maxSide, imageQuality: quality, limit: max);
    } else {
      final f = await picker.pickImage(
        source: source,
        maxWidth: maxSide,
        maxHeight: maxSide,
        imageQuality: quality,
      );
      files = f == null ? [] : [f];
    }
  } on PlatformException catch (e) {
    // المستخدم رفض صلاحية الصور أو الكاميرا.
    final denied = e.code.contains('access_denied') || e.code.contains('permission');
    showMessage(denied
        ? (source == ImageSource.camera ? 'cameraPermissionDenied'.tr : 'photoPermissionDenied'.tr)
        : 'pickFailed'.tr);
    return [];
  } catch (_) {
    showMessage('pickFailed'.tr);
    return [];
  }

  if (files.length > max) {
    showMessage('tooManyImages'.trParams({'n': '$max'}));
    files = files.take(max).toList();
  }

  final result = <PickedImage>[];
  var skipped = false;
  for (final f in files) {
    final name = f.name.isEmpty ? 'image.jpg' : f.name;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
    final bytes = await f.readAsBytes();
    if (!_allowed.contains(ext) || bytes.lengthInBytes > maxImageBytes) {
      skipped = true;
      continue;
    }
    result.add(PickedImage(bytes: bytes, name: name));
  }
  if (skipped) showMessage('imageRejected'.tr);
  return result;
}

Future<ImageSource?> _chooseSource() {
  Widget option(IconData icon, String label, ImageSource value) => ListTile(
        minTileHeight: 56,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColor.orangeSoft, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColor.orangeDeep),
        ),
        title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        onTap: () => Get.back(result: value),
      );

  return Get.bottomSheet<ImageSource>(
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColor.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('pickImageTitle'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            option(Icons.photo_library_outlined, 'pickFromGallery'.tr, ImageSource.gallery),
            option(Icons.photo_camera_outlined, 'pickFromCamera'.tr, ImageSource.camera),
          ],
        ),
      ),
    ),
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  );
}
