import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/trader_shell_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../widget/trader/trader_parts.dart';
import 'trader_account.dart';
import 'trader_cart.dart';
import 'trader_home.dart';
import 'trader_orders.dart';
import 'trader_search.dart';

/// هيكل لوحة التاجر: خمسة تبويبات تحتفظ بحالتها (IndexedStack).
///   الهاتف: شريط تنقل سفلي.
///   الشاشات العريضة (تابلت، Windows): شريط جانبي، والمحتوى في المنتصف.
class TraderShell extends StatelessWidget {
  const TraderShell({super.key});

  static const _pages = [
    TraderHomeScreen(),
    TraderSearchScreen(),
    TraderCartScreen(),
    TraderOrdersScreen(),
    TraderAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TraderShellController>(
      builder: (c) {
        final index = c.tab.index;
        final body = IndexedStack(index: index, children: _pages);

        return LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth >= AppLayout.wideBreakpoint) {
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: (i) => c.select(TraderTab.values[i]),
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: AppColor.surface,
                      indicatorColor: AppColor.orangeSoft,
                      selectedLabelTextStyle: const TextStyle(color: AppColor.ink, fontWeight: FontWeight.w700),
                      unselectedLabelTextStyle: const TextStyle(color: AppColor.textSecondary),
                      destinations: [
                        for (final d in _destinations())
                          NavigationRailDestination(icon: d.$1, selectedIcon: d.$2, label: Text(d.$3)),
                      ],
                    ),
                    const VerticalDivider(width: 1, thickness: 1, color: AppColor.divider),
                    Expanded(child: body),
                  ],
                ),
              );
            }
            return Scaffold(
              body: body,
              bottomNavigationBar: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => c.select(TraderTab.values[i]),
                backgroundColor: AppColor.surface,
                indicatorColor: AppColor.orangeSoft,
                height: 68,
                destinations: [
                  for (final d in _destinations())
                    NavigationDestination(icon: d.$1, selectedIcon: d.$2, label: d.$3),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<(Widget, Widget, String)> _destinations() => [
        (const Icon(Icons.home_outlined), const Icon(Icons.home_rounded), 'tabHome'.tr),
        (const Icon(Icons.search_rounded), const Icon(Icons.manage_search_rounded), 'tabSearch'.tr),
        (const CartBadgeIcon(), const CartBadgeIcon(selected: true), 'tabCart'.tr),
        (const Icon(Icons.receipt_long_outlined), const Icon(Icons.receipt_long_rounded), 'tabOrders'.tr),
        (const Icon(Icons.person_outline_rounded), const Icon(Icons.person_rounded), 'tabAccount'.tr),
      ];
}
