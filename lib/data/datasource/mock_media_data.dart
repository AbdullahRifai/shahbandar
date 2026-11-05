import '../../core/services/local_image_cache.dart';
import '../model/picked_image.dart';
import 'media_data.dart';

/// رفع وهمي: يحاكي التقدم ثم يحفظ الصورة الحقيقية التي اختارها المستخدم
/// في الذاكرة ويرجع عنوانها (local://)، فتظهر هي نفسها في التطبيق.
/// الصور تُمسح عند إغلاق التطبيق، كبقية البيانات الوهمية.
class MockMediaData implements MediaData {
  @override
  Future<String> uploadImage(PickedImage image, {void Function(double progress)? onProgress}) async {
    // الصورة الأكبر تأخذ وقتاً أطول، حتى يبدو التقدم واقعياً.
    final steps = (image.sizeBytes / 150000).clamp(4, 12).round();
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      onProgress?.call(i / steps);
    }
    return LocalImageCache.put(image.bytes);
  }
}
