import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/user_model.dart';
import '../constant/app_color.dart';
import '../constant/app_routes.dart';
import '../services/notification_center.dart';

/// جرس الإشعارات في رأس اللوحتين، مع نقطة برتقالية حين يوجد غير مقروء.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, required this.role});

  final UserRole role;

  static Future<void> open(UserRole role) async {
    await Get.toNamed(AppRoute.notifications, arguments: role);
    await Get.find<NotificationCenter>().refreshFor(role);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationCenter>(
      builder: (c) => IconButton(
        onPressed: () => open(role),
        tooltip: c.unread > 0 ? 'notificationsUnread'.trParams({'n': '${c.unread}'}) : 'notifications'.tr,
        icon: Badge(
          isLabelVisible: c.unread > 0,
          smallSize: 10,
          backgroundColor: AppColor.orange,
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ),
    );
  }
}
