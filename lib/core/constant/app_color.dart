import 'package:flutter/material.dart';

/// ألوان هوية شاهبندر. لا يُكتب أي لون مباشرة داخل الواجهات، بل من هنا فقط.
/// كل لون نص هنا يحقق تباين 4.5:1 على الأقل فوق الخلفية المقصودة له.
abstract final class AppColor {
  // ─── الهوية ───
  static const Color ink = Color(0xFF17202E);         // النص والهيكل والخلفيات الداكنة
  static const Color orange = Color(0xFFF27A1A);      // تعبئة الإجراء الرئيسي فقط
  static const Color orangeDeep = Color(0xFFA3470A);  // الروابط فوق الخلفيات الفاتحة
  static const Color orangeSoft = Color(0xFFFDE7D3);  // خلفية العنصر المحدد
  static const Color orangeOnInk = Color(0xFFF7A15A); // نص برتقالي فوق الكحلي

  // ─── الأسطح والنصوص ───
  static const Color background = Color(0xFFF4F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE3E6EB);
  static const Color border = Color(0xFFD5DAE1);
  static const Color borderStrong = Color(0xFF9AA3B2); // حدود خانات الاختيار
  static const Color note = Color(0xFFE9ECF0);         // خلفية الملاحظات الرمادية
  static const Color textSecondary = Color(0xFF5B6472);      // فوق الفاتح
  static const Color textNote = Color(0xFF4A5260);           // فوق note
  static const Color textOnInkSecondary = Color(0xFF9AA3B2); // فوق الكحلي

  // ─── الحالات ───
  static const Color success = Color(0xFF17713C);
  static const Color successSoft = Color(0xFFE3F5EA);
  static const Color warning = Color(0xFF8A5A00);
  static const Color warningSoft = Color(0xFFFFF4DB);
  static const Color info = Color(0xFF1F4FBF);
  static const Color infoSoft = Color(0xFFE7EEFF);
  static const Color preparing = Color(0xFF5B3FB8);
  static const Color preparingSoft = Color(0xFFEFEBFF);
  static const Color danger = Color(0xFFB3261E);
  static const Color dangerSoft = Color(0xFFFDE8E6);
  static const Color dangerText = Color(0xFF8C1D18);
  static const Color neutralSoft = Color(0xFFECEEF1);
}
