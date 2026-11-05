import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shared/notifications_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/notification_model.dart';
import '../../../data/model/user_model.dart';

/// D1 — الإشعارات.
/// تبويبا "الكل" و"غير المقروءة"، ومجموعات حسب الوقت.
/// غير المقروء: خلفية دافئة ونقطة برتقالية وعنوان عريض.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: NotificationsController(role),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text('notifications'.tr),
          actions: [
            if (c.unreadCount > 0)
              TextButton(
                onPressed: c.markAllRead,
                style: TextButton.styleFrom(foregroundColor: AppColor.orangeDeep, minimumSize: const Size(48, 48)),
                child: Text('markAllRead'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => MaxWidth(
              maxWidth: 640,
              child: Column(
                children: [
                  _Tabs(c: c),
                  Expanded(child: _List(c: c)),
                ],
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.c});

  final NotificationsController c;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool selected, VoidCallback onTap, {int count = 0}) => Expanded(
          child: Semantics(
            selected: selected,
            button: true,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: selected ? AppColor.ink : Colors.transparent, width: 3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColor.ink : AppColor.textSecondary,
                        )),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(color: AppColor.orange, borderRadius: BorderRadius.circular(10)),
                        child: Text('$count',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.ink)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColor.divider))),
      child: Row(
        children: [
          tab('all'.tr, !c.unreadOnly, () => c.setUnreadOnly(false)),
          tab('unread'.tr, c.unreadOnly, () => c.setUnreadOnly(true), count: c.unreadCount),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.c});

  final NotificationsController c;

  @override
  Widget build(BuildContext context) {
    final groups = c.grouped;
    if (groups.isEmpty) {
      return EmptyView(
        icon: Icons.notifications_none_rounded,
        title: c.unreadOnly ? 'noUnread'.tr : 'noNotifications'.tr,
        message: c.unreadOnly ? null : 'noNotificationsHint'.tr,
      );
    }
    return RefreshIndicator(
      onRefresh: c.load,
      color: AppColor.ink,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Semantics(
                header: true,
                child: Text('ng_${entry.key.name}'.tr,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.textSecondary)),
              ),
            ),
            Material(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < entry.value.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColor.divider),
                    _Item(n: entry.value[i], onTap: () => c.open(entry.value[i])),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.n, required this.onTap});

  final AppNotification n;
  final VoidCallback onTap;

  static (IconData, Color, Color) _style(NotificationKind k) => switch (k) {
        NotificationKind.accepted => (Icons.check_rounded, AppColor.info, AppColor.infoSoft),
        NotificationKind.preparing => (Icons.inventory_2_outlined, AppColor.preparing, AppColor.preparingSoft),
        NotificationKind.completed => (Icons.local_shipping_outlined, AppColor.success, AppColor.successSoft),
        NotificationKind.rejected => (Icons.close_rounded, AppColor.danger, AppColor.dangerSoft),
        NotificationKind.cancelled => (Icons.remove_shopping_cart_outlined, AppColor.textNote, AppColor.neutralSoft),
        NotificationKind.priceChanged => (Icons.trending_up_rounded, AppColor.warning, AppColor.warningSoft),
        NotificationKind.newOrder => (Icons.move_to_inbox_outlined, AppColor.orangeDeep, AppColor.orangeSoft),
        NotificationKind.profile => (Icons.person_outline_rounded, AppColor.textNote, AppColor.neutralSoft),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, bg) = _style(n.kind);
    final unread = !n.read;
    final title = n.titleKey.trParams(n.params);
    final body = n.bodyKey.trParams(n.params);

    return Semantics(
      button: true,
      label: '${unread ? '${'unreadLabel'.tr}، ' : ''}$title، $body',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: unread ? const Color(0xFFFFF8F2) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                        )),
                    const SizedBox(height: 2),
                    Text(body, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColor.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatAgo(n.createdAt), style: const TextStyle(fontSize: 12, color: AppColor.textSecondary)),
                  if (unread) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: AppColor.orange, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
