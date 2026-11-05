import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../data/datasource/account_data.dart';
import '../../data/model/notification_model.dart';
import '../../data/model/user_model.dart';
import '../supplier/supplier_shell_controller.dart';
import '../trader/trader_shell_controller.dart';

/// مجموعات الإشعارات حسب الوقت.
enum NotificationGroup { today, yesterday, thisWeek, earlier }

/// D1 — الإشعارات: الكل / غير المقروءة، "تعليم الكل كمقروء"،
/// والضغط على إشعار يعلّمه مقروءاً ويفتح ما يخصه.
class NotificationsController extends GetxController {
  NotificationsController(this.role);

  final UserRole role;
  final AccountData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  List<AppNotification> items = [];
  bool unreadOnly = false;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (items.isEmpty) {
      status = StatusRequest.loading;
      update();
    }
    try {
      items = await _data.notifications(role);
      status = StatusRequest.success;
    } catch (_) {
      if (items.isEmpty) status = StatusRequest.failure;
    }
    update();
  }

  int get unreadCount => items.where((n) => !n.read).length;

  void setUnreadOnly(bool value) {
    unreadOnly = value;
    update();
  }

  Future<void> markAllRead() async {
    for (final n in items) {
      n.read = true;
    }
    update();
    await _data.markAllRead(role);
  }

  /// المرئي مجمّعاً بالترتيب: اليوم، أمس، هذا الأسبوع، أقدم.
  Map<NotificationGroup, List<AppNotification>> get grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <NotificationGroup, List<AppNotification>>{};
    for (final n in items.where((n) => !unreadOnly || !n.read)) {
      final g = !n.createdAt.isBefore(today)
          ? NotificationGroup.today
          : !n.createdAt.isBefore(today.subtract(const Duration(days: 1)))
              ? NotificationGroup.yesterday
              : !n.createdAt.isBefore(today.subtract(const Duration(days: 7)))
                  ? NotificationGroup.thisWeek
                  : NotificationGroup.earlier;
      result.putIfAbsent(g, () => []).add(n);
    }
    return {for (final g in NotificationGroup.values) if (result[g] != null) g: result[g]!};
  }

  Future<void> open(AppNotification n) async {
    if (!n.read) {
      n.read = true;
      update();
      _data.markRead(n.id);
    }
    switch (n.target) {
      case NotificationTarget.purchase:
        await Get.toNamed(AppRoute.purchase, arguments: n.targetId);
      case NotificationTarget.incomingOrder:
        await Get.toNamed(AppRoute.incomingOrder, arguments: n.targetId);
      case NotificationTarget.businessProfile:
        await Get.toNamed(AppRoute.businessProfile);
      case NotificationTarget.cart:
        _backToShell();
        if (Get.isRegistered<TraderShellController>()) {
          Get.find<TraderShellController>().select(TraderTab.cart);
        }
      case NotificationTarget.products:
        _backToShell();
        if (Get.isRegistered<SupplierShellController>()) {
          Get.find<SupplierShellController>().select(SupplierTab.products);
        }
      case NotificationTarget.none:
        break;
    }
  }

  void _backToShell() => Get.until((r) =>
      r.settings.name == AppRoute.traderHome || r.settings.name == AppRoute.supplierHome);
}
