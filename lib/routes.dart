import 'package:get/get.dart';

import 'controller/auth/account_type_controller.dart';
import 'controller/auth/business_setup_controller.dart';
import 'controller/auth/check_email_controller.dart';
import 'controller/auth/forgot_password_controller.dart';
import 'controller/auth/link_result_controller.dart';
import 'controller/auth/login_controller.dart';
import 'controller/auth/new_password_controller.dart';
import 'controller/auth/register_controller.dart';
import 'controller/auth/reset_sent_controller.dart';
import 'controller/splash_controller.dart';
import 'controller/supplier/supplier_home_controller.dart';
import 'controller/supplier/supplier_orders_controller.dart';
import 'controller/supplier/supplier_products_controller.dart';
import 'controller/supplier/supplier_shell_controller.dart';
import 'controller/trader/cart_controller.dart';
import 'controller/trader/orders_controller.dart';
import 'controller/trader/trader_home_controller.dart';
import 'controller/trader/trader_search_controller.dart';
import 'controller/trader/trader_shell_controller.dart';
import 'core/constant/app_routes.dart';
import 'data/model/option_model.dart';
import 'data/model/order_model.dart';
import 'data/model/request_failure.dart';
import 'data/model/user_model.dart';
import 'view/screen/auth/account_disabled.dart';
import 'view/screen/auth/account_type.dart';
import 'view/screen/auth/business_setup.dart';
import 'view/screen/auth/check_email.dart';
import 'view/screen/auth/forgot_password.dart';
import 'view/screen/auth/link_result.dart';
import 'view/screen/auth/login.dart';
import 'view/screen/auth/new_password.dart';
import 'view/screen/auth/register.dart';
import 'view/screen/auth/reset_sent.dart';
import 'view/screen/shared/activity_log.dart';
import 'view/screen/shared/business_profile.dart';
import 'view/screen/shared/change_password.dart';
import 'view/screen/shared/delete_account.dart';
import 'view/screen/shared/notifications.dart';
import 'view/screen/splash.dart';
import 'view/screen/supplier/incoming_order.dart';
import 'view/screen/supplier/product_form.dart';
import 'view/screen/supplier/supplier_shell.dart';
import 'view/screen/trader/category_products.dart';
import 'view/screen/trader/compare.dart';
import 'view/screen/trader/order_failed.dart';
import 'view/screen/trader/order_review.dart';
import 'view/screen/trader/order_sent.dart';
import 'view/screen/trader/product_details.dart';
import 'view/screen/trader/purchase_details.dart';
import 'view/screen/trader/supplier_page.dart';
import 'view/screen/trader/trader_shell.dart';

/// جدول المسارات: مسار ← شاشة ← متحكم (Binding).
/// الـ Binding ينشئ المتحكم عند فتح الشاشة ويحذفه عند إغلاقها.
///
/// مهم: الدالة بأقواس { } لا بسهم =>. مع السهم يستنتج Dart نوع Get.put
/// على أنه void (نوع رجوع الدالة)، فيُسجَّل المتحكم باسم "void" ولا تجده الشاشة.
final List<GetPage<dynamic>> routes = [
  GetPage(
    name: AppRoute.splash,
    page: () => const SplashScreen(),
    binding: BindingsBuilder(() {
      Get.put(SplashController());
    }),
  ),

  // ─── الحساب والدخول ───
  GetPage(
    name: AppRoute.login,
    page: () => const LoginScreen(),
    binding: BindingsBuilder(() {
      Get.put(LoginController());
    }),
  ),
  GetPage(
    name: AppRoute.register,
    page: () => const RegisterScreen(),
    binding: BindingsBuilder(() {
      Get.put(RegisterController());
    }),
  ),
  GetPage(
    name: AppRoute.checkEmail,
    page: () => const CheckEmailScreen(),
    binding: BindingsBuilder(() {
      Get.put(CheckEmailController());
    }),
  ),
  GetPage(
    name: AppRoute.linkResult,
    page: () => const LinkResultScreen(),
    binding: BindingsBuilder(() {
      Get.put(LinkResultController());
    }),
  ),
  GetPage(
    name: AppRoute.accountType,
    page: () => const AccountTypeScreen(),
    binding: BindingsBuilder(() {
      Get.put(AccountTypeController());
    }),
  ),
  GetPage(
    name: AppRoute.businessSetup,
    page: () => const BusinessSetupScreen(),
    binding: BindingsBuilder(() {
      Get.put(BusinessSetupController());
    }),
  ),
  GetPage(
    name: AppRoute.forgotPassword,
    page: () => const ForgotPasswordScreen(),
    binding: BindingsBuilder(() {
      Get.put(ForgotPasswordController());
    }),
  ),
  GetPage(
    name: AppRoute.resetSent,
    page: () => const ResetSentScreen(),
    binding: BindingsBuilder(() {
      Get.put(ResetSentController());
    }),
  ),
  GetPage(
    name: AppRoute.newPassword,
    page: () => const NewPasswordScreen(),
    binding: BindingsBuilder(() {
      Get.put(NewPasswordController());
    }),
  ),
  GetPage(name: AppRoute.accountDisabled, page: () => const AccountDisabledScreen()),

  // ─── رحلة التاجر ───
  // الهيكل ينشئ متحكمات التبويبات الأربعة مرة واحدة، وتبقى ما دامت اللوحة مفتوحة.
  GetPage(
    name: AppRoute.traderHome,
    page: () => const TraderShell(),
    binding: BindingsBuilder(() {
      Get.put(TraderShellController());
      Get.put(TraderHomeController());
      Get.put(TraderSearchController());
      Get.put(CartController());
      Get.put(OrdersController());
    }),
  ),
  // الصفحات التالية تنشئ متحكمها بنفسها (GetBuilder مع global: false)،
  // لأنها قد تُفتح أكثر من مرة فوق بعضها (منتج ← مورد ← منتج آخر).
  GetPage(
    name: AppRoute.categoryProducts,
    page: () => CategoryProductsScreen(category: Get.arguments as OptionModel),
  ),
  GetPage(
    name: AppRoute.product,
    page: () => ProductDetailsScreen(productId: Get.arguments as String),
  ),
  GetPage(
    name: AppRoute.supplierPage,
    page: () => SupplierPageScreen(supplierId: Get.arguments as String),
  ),
  GetPage(name: AppRoute.compare, page: () => const CompareScreen()),
  // المراجعة والفشل تستخدمان CartController الموجود في الهيكل.
  GetPage(name: AppRoute.orderReview, page: () => const OrderReviewScreen()),
  GetPage(
    name: AppRoute.orderSent,
    page: () => OrderSentScreen(purchase: Get.arguments as Purchase),
  ),
  GetPage(
    name: AppRoute.orderFailed,
    page: () => OrderFailedScreen(reason: Get.arguments as RequestFailureType),
  ),
  GetPage(
    name: AppRoute.purchase,
    page: () => PurchaseDetailsScreen(purchaseId: Get.arguments as String),
  ),

  // ─── رحلة المورد ───
  GetPage(
    name: AppRoute.supplierHome,
    page: () => const SupplierShell(),
    binding: BindingsBuilder(() {
      Get.put(SupplierShellController());
      Get.put(SupplierHomeController());
      Get.put(SupplierOrdersController());
      Get.put(SupplierProductsController());
    }),
  ),
  GetPage(
    name: AppRoute.incomingOrder,
    page: () => IncomingOrderScreen(orderId: Get.arguments as String),
  ),
  // بلا معامل ← إضافة منتج (C8)، مع معرّف المنتج ← تعديل (C9).
  GetPage(
    name: AppRoute.productForm,
    page: () => ProductFormScreen(productId: Get.arguments as String?),
  ),

  // ─── واجهات مشتركة (متحكماتها محلية لكل صفحة) ───
  GetPage(
    name: AppRoute.notifications,
    page: () => NotificationsScreen(role: Get.arguments as UserRole? ?? UserRole.trader),
  ),
  GetPage(name: AppRoute.businessProfile, page: () => const BusinessProfileScreen()),
  GetPage(name: AppRoute.activityLog, page: () => const ActivityLogScreen()),
  GetPage(name: AppRoute.deleteAccount, page: () => const DeleteAccountScreen()),
  GetPage(name: AppRoute.changePassword, page: () => const ChangePasswordScreen()),
];
