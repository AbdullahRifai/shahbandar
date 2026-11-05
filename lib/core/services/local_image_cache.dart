import 'dart:typed_data';

/// صور محفوظة في الذاكرة بعنوان يبدأ بـ local://
///
/// الآن: الرفع الوهمي يضع الصورة هنا ويرجع عنوانها، فتظهر الصورة الحقيقية
/// التي اختارها المستخدم في كل الشاشات (السلة، البحث، صفحة المورد...).
/// لاحقاً: الخادم يرجع رابط https، و[AppImage] يعرضه من الشبكة تلقائياً.
abstract final class LocalImageCache {
  static const String scheme = 'local://';
  static final Map<String, Uint8List> _images = {};
  static int _next = 1;

  static String put(Uint8List bytes) {
    final url = '$scheme${_next++}';
    _images[url] = bytes;
    return url;
  }

  static Uint8List? get(String url) => _images[url];
}
