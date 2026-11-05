import 'package:flutter/material.dart';

import '../services/local_image_cache.dart';

/// يعرض صورة من أي عنوان:
///   https://...  ← من الشبكة (بعد ربط الخادم)
///   local://...  ← صورة اختارها المستخدم ورُفعت رفعاً وهمياً
/// وإن لم توجد الصورة أو فشل تحميلها يظهر [placeholder].
class AppImage extends StatelessWidget {
  const AppImage({super.key, required this.url, required this.placeholder, this.fit = BoxFit.cover});

  final String? url;
  final Widget placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return placeholder;
    if (u.startsWith(LocalImageCache.scheme)) {
      final bytes = LocalImageCache.get(u);
      if (bytes == null) return placeholder;
      return Image.memory(bytes, fit: fit, gaplessPlayback: true, errorBuilder: (_, _, _) => placeholder);
    }
    if (u.startsWith('http')) {
      return Image.network(
        u,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
      );
    }
    return placeholder;
  }
}
