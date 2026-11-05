import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/home_route.dart';
import '../../core/functions/show_message.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/compare_service.dart';
import '../../core/services/notification_center.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/account_data.dart';
import '../../data/model/business_profile_model.dart';
import '../../data/model/user_model.dart';
import '../../view/widget/shared/activate_role_sheet.dart';

/// D2 — حسابي، مشتركة بين اللوحتين. [role] هو الوضع الحالي.
/// الحساب بدور واحد ← بطاقة تفعيل الدور الآخر (D4).
/// الحساب بالدورين ← بطاقة التبديل بين الوضعين.
class AccountController extends GetxController {
  AccountController(this.role);

  final UserRole role;
  final AccountData _data = Get.find();
  final SessionService _session = Get.find();

  StatusRequest status = StatusRequest.none;
  BusinessProfileModel? profile;
  bool deletionPending = false;
  bool activating = false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (status != StatusRequest.success) {
      status = StatusRequest.loading;
      update();
    }
    try {
      profile = await _data.businessProfile();
      deletionPending = await _data.deletionRequest() != null;
      await Get.find<NotificationCenter>().refreshFor(role);
      status = StatusRequest.success;
    } catch (_) {
      if (status != StatusRequest.success) status = StatusRequest.failure;
    }
    update();
  }

  UserModel? get user => _session.currentUser;
  String get email => user?.email ?? '';
  String get displayName => (profile?.name.isNotEmpty ?? false) ? profile!.name : email;

  String get initial {
    final n = displayName.trim();
    return n.isEmpty ? '?' : String.fromCharCode(n.runes.first).toUpperCase();
  }

  Set<UserRole> get roles => user?.roles ?? {role};
  UserRole get otherRole => role == UserRole.trader ? UserRole.supplier : UserRole.trader;
  bool get hasOtherRole => roles.contains(otherRole);

  String get languageName => Get.find<LocaleController>().isArabic ? 'العربية' : 'English';

  // ─── التنقل ───

  Future<void> _push(String route, {Object? arguments}) async {
    await Get.toNamed(route, arguments: arguments);
    load();
  }

  void openProfile() => _push(AppRoute.businessProfile);
  void openNotifications() => _push(AppRoute.notifications, arguments: role);
  void openActivity() => _push(AppRoute.activityLog);
  void openChangePassword() => _push(AppRoute.changePassword);
  void openDeleteAccount() => _push(AppRoute.deleteAccount);

  /// الدوران مفعّلان: الانتقال للوضع الآخر.
  void switchMode() {
    final u = user;
    if (u == null) return;
    final updated = u.copyWith(lastMode: otherRole);
    _session.update(updated);
    Get.offAllNamed(homeRouteFor(updated));
  }

  /// D4: تأكيد ثم تفعيل الدور الآخر، والانتقال إليه.
  Future<void> activateOther() async {
    final ok = await showActivateRoleSheet(otherRole);
    if (!ok) return;
    activating = true;
    update();
    try {
      final updated = await _data.activateRole(otherRole);
      final withMode = updated.copyWith(lastMode: otherRole);
      _session.update(withMode);
      showMessage(otherRole == UserRole.supplier ? 'supplierActivated'.tr : 'traderActivated'.tr);
      Get.offAllNamed(homeRouteFor(withMode));
      return;
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    activating = false;
    update();
  }

  Future<void> logout() async {
    Get.find<CartService>().clear();
    Get.find<CompareService>().clear();
    await _session.clear();
    Get.offAllNamed(AppRoute.login);
  }
}
