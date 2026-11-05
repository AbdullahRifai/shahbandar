import '../model/picked_image.dart';

/// العقد لرفع الصور (صور المنتجات، شعار النشاط).
/// الآن MockMediaData، ولاحقاً RemoteMediaData ترفع الملف للخادم وترجع رابطه.
abstract class MediaData {
  /// يرفع الصورة ويرجع رابطها. [onProgress] من 0 إلى 1.
  Future<String> uploadImage(PickedImage image, {void Function(double progress)? onProgress});
}
