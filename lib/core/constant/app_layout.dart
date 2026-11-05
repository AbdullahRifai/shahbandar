/// قياسات التخطيط المشتركة، حتى يعمل التطبيق على كل المقاسات:
/// هاتف صغير، هاتف كبير، تابلت، ونافذة Windows.
abstract final class AppLayout {
  /// أقصى عرض لمحتوى النماذج وشاشات الحساب.
  /// على الهاتف لا يؤثر (الشاشة أضيق منه)، وعلى التابلت وWindows
  /// يبقى النموذج في المنتصف بعرض مريح للقراءة بدل أن يمتد على كامل الشاشة.
  static const double formMaxWidth = 480;

  /// الهامش الجانبي للمحتوى.
  static const double gutter = 24;

  /// أقصى عرض لمحتوى شاشات التاجر (القوائم والشبكات).
  static const double contentMaxWidth = 840;

  /// من هذا العرض فما فوق: شريط تنقل جانبي بدل الشريط السفلي (تابلت وWindows).
  static const double wideBreakpoint = 840;
}
