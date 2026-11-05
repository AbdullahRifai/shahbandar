import 'package:get/get.dart';

import 'controller/admin/admin_login_controller.dart';
import 'controller/admin/admin_shell_controller.dart';
import 'core/constant/app_routes.dart';
import 'view/screen/admin/admin_login.dart';
import 'view/screen/admin/admin_shell.dart';

/// مسارات لوحة الإدارة: الدخول، ثم الهيكل الذي يعرض الأقسام الثمانية داخله
/// (الشريط الجانبي ثابت، والمحتوى يتغير)، فلا حاجة لمسار لكل قسم.
final List<GetPage<dynamic>> adminRoutes = [
  GetPage(
    name: AppRoute.adminLogin,
    page: () => const AdminLoginScreen(),
    binding: BindingsBuilder(() {
      Get.put(AdminLoginController());
    }),
  ),
  GetPage(
    name: AppRoute.adminHome,
    page: () => const AdminShell(),
    binding: BindingsBuilder(() {
      Get.put(AdminShellController());
    }),
  ),
];
