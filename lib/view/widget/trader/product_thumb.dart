import 'package:flutter/material.dart';

import '../../../core/shared/app_image.dart';

/// صورة المنتج. إن رفع المورد صورة تظهر هي، وإلا رسم مؤقت (أيقونة على لون هادئ)
/// حسب نوع المنتج، حتى تبقى الشبكة مرتبة ومقروءة قبل وصول الصور الحقيقية.
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.visual,
    this.imageUrl,
    this.size,
    this.radius = 14,
    this.iconSize,
  });

  final String visual;
  final String? imageUrl;

  /// مربع بحجم ثابت. null ← يملأ المساحة المتاحة.
  final double? size;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = _style(visual);
    final placeholder = ColoredBox(
      color: bg,
      child: Center(child: Icon(icon, color: fg, size: iconSize ?? (size != null ? size! * 0.45 : 44))),
    );

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          // صورة المورد إن رفعها (من الشبكة أو المرفوعة محلياً)، وإلا الرسم المؤقت.
          child: AppImage(url: imageUrl, placeholder: placeholder),
        ),
      ),
    );
  }

  static (IconData, Color, Color) _style(String visual) => switch (visual) {
        'oil' => (Icons.water_drop_rounded, const Color(0xFFF3F0D9), const Color(0xFF6B6215)),
        'pasta' => (Icons.ramen_dining_rounded, const Color(0xFFFBEBD3), const Color(0xFF8A5A00)),
        'tahini' => (Icons.local_drink_rounded, const Color(0xFFF4E8DC), const Color(0xFF7A4A22)),
        'grain' => (Icons.grass_rounded, const Color(0xFFFBE4DC), const Color(0xFF8C3B1F)),
        'sugar' => (Icons.grain_rounded, const Color(0xFFEDF0F5), const Color(0xFF3F4A5C)),
        'cubes' => (Icons.view_in_ar_rounded, const Color(0xFFEDF0F5), const Color(0xFF3F4A5C)),
        'rice' => (Icons.rice_bowl_rounded, const Color(0xFFF1EFE6), const Color(0xFF5E5634)),
        'tissue' => (Icons.layers_rounded, const Color(0xFFE6F0FA), const Color(0xFF1F4F7F)),
        'roll' => (Icons.toll_rounded, const Color(0xFFE6F0FA), const Color(0xFF1F4F7F)),
        'bag' => (Icons.shopping_bag_rounded, const Color(0xFFE7F3EC), const Color(0xFF1E5E3A)),
        'soap' => (Icons.soap_rounded, const Color(0xFFE9EEFF), const Color(0xFF2E3F9E)),
        _ => (Icons.inventory_2_rounded, const Color(0xFFECEEF1), const Color(0xFF4A5260)),
      };
}
