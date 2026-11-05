import 'dart:typed_data';

/// صورة اختارها المستخدم من المعرض أو التقطها بالكاميرا، جاهزة للعرض والرفع.
/// نحتفظ بالبايتات لا بالمسار، حتى تعمل على أندرويد وWindows والويب بنفس الطريقة.
class PickedImage {
  const PickedImage({required this.bytes, required this.name});

  final Uint8List bytes;

  /// اسم الملف الأصلي (photo.jpg)، يُرسل مع الرفع.
  final String name;

  int get sizeBytes => bytes.lengthInBytes;
}
