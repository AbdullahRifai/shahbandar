import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/supplier/supplier_shell_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import 'supplier_account.dart';
import 'supplier_home.dart';
import 'supplier_orders.dart';
import 'supplier_products.dart';

/// هيكل لوحة المورد: أربعة تبويبات تحتفظ بحالتها.
///   الهاتف: شريط سفلي. الشاشات العريضة (تابلت، Windows): شريط جانبي.
/// عدّاد الطلبات المنتظرة يظهر على تبويب "الطلبات".
class SupplierShell extends StatelessWidget {
  const SupplierShell({super.key});

  static const _pages = [
    SupplierHomeScreen(),
    SupplierOrdersScreen(),
    SupplierProductsScreen(),
    SupplierAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SupplierShellController>(
      builder: (c) {
        final index = c.tab.index;
        final body = IndexedStack(index: index, children: _pages);
        final items = _destinations(c.awaitingCount);

        return LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth >= AppLayout.wideBreakpoint) {
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: (i) => c.select(SupplierTab.values[i]),
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: AppColor.surface,
                      indicatorColor: AppColor.orangeSoft,
                      selectedLabelTextStyle: const TextStyle(color: AppColor.ink, fontWeight: FontWeight.w700),
                      unselectedLabelTextStyle: const TextStyle(color: AppColor.textSecondary),
                      destinations: [
                        for (final d in items)
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
                onDestinationSelected: (i) => c.select(SupplierTab.values[i]),
                backgroundColor: AppColor.surface,
                indicatorColor: AppColor.orangeSoft,
                height: 68,
                destinations: [
                  for (final d in items) NavigationDestination(icon: d.$1, selectedIcon: d.$2, label: d.$3),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<(Widget, Widget, String)> _destinations(int awaiting) {
    Widget withBadge(IconData icon) => Badge(
          isLabelVisible: awaiting > 0,
          label: Text('$awaiting'),
          backgroundColor: AppColor.ink,
          textColor: AppColor.surface,
          child: Icon(icon),
        );
    return [
      (const Icon(Icons.grid_view_outlined), const Icon(Icons.grid_view_rounded), 'stabHome'.tr),
      (withBadge(Icons.assignment_outlined), withBadge(Icons.assignment_rounded), 'stabOrders'.tr),
      (const Icon(Icons.inventory_2_outlined), const Icon(Icons.inventory_2_rounded), 'stabProducts'.tr),
      (const Icon(Icons.person_outline_rounded), const Icon(Icons.person_rounded), 'tabAccount'.tr),
    ];
  }
}
