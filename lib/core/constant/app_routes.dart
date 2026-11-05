/// أسماء المسارات في مكان واحد. لا يُكتب نص مسار داخل أي شاشة.
abstract final class AppRoute {
  static const String splash = '/';

  // ─── الحساب والدخول (A) ───
  static const String login = '/login';                   // A2
  static const String register = '/register';             // A3
  static const String checkEmail = '/check-email';        // A4
  static const String linkResult = '/link-result';        // A5
  static const String accountType = '/account-type';      // A6
  static const String businessSetup = '/business-setup';  // A7
  static const String forgotPassword = '/forgot-password'; // A8
  static const String resetSent = '/reset-sent';          // A9
  static const String newPassword = '/new-password';      // A10
  static const String accountDisabled = '/account-disabled'; // A11

  // ─── رحلة التاجر (B) ───
  static const String traderHome = '/trader';             // الهيكل: B1، B2، B9، B14، الحساب
  static const String categoryProducts = '/trader/category'; // B5
  static const String product = '/trader/product';        // B6
  static const String supplierPage = '/trader/supplier';  // B7
  static const String compare = '/trader/compare';        // B8
  static const String orderReview = '/trader/review';     // B11
  static const String orderSent = '/trader/sent';         // B12
  static const String orderFailed = '/trader/failed';     // B13
  static const String purchase = '/trader/purchase';      // B15، B17

  // ─── رحلة المورد (C) ───
  static const String supplierHome = '/supplier';               // الهيكل: C1، C2، C7/C10، الحساب
  static const String incomingOrder = '/supplier/order';        // C3، C6 (وC4، C5 فوقها)
  static const String productForm = '/supplier/product-form';   // C8 إضافة، C9 تعديل

  // ─── واجهات مشتركة (D) ───
  static const String notifications = '/notifications';          // D1
  static const String businessProfile = '/account/business';     // D3
  static const String activityLog = '/account/activity';         // D5
  static const String deleteAccount = '/account/delete';         // D6
  static const String changePassword = '/account/password';      // D7
  // D2 تبويب داخل اللوحتين، وD4 نافذة سفلية فوقه.

  // ─── لوحة الإدارة (E) — تعمل من lib/main_admin.dart ───
  static const String adminLogin = '/admin/login';  // E1
  static const String adminHome = '/admin';         // E2 إلى E10 داخل هيكل واحد
}
