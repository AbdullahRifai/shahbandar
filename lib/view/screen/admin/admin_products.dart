import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_section_controllers.dart';
import '../../../controller/admin/admin_shell_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/admin_models.dart';
import '../../widget/admin/admin_chips.dart';
import '../../widget/admin/admin_parts.dart';
import '../../widget/admin/admin_table.dart';
import '../../widget/trader/product_thumb.dart';

/// E5 — مراجعة المنتجات (FR-64): جدول وبجانبه تفاصيل المنتج المحدد مع زر الإخفاء.
/// "أوقفه المورد" غير "مخفي من الإدارة": الأول قرار المورد، والثاني لا يلغيه إلا الأدمن.
class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminProductsController>(
      init: AdminProductsController(),
      global: false,
      builder: (c) {
        if (c.status == StatusRequest.failure) return ErrorView(onRetry: c.load);
        if (c.status != StatusRequest.success) return const LoadingView();
        final list = c.filtered;
        return AdminPage(
          onRefresh: c.load,
          children: [
            AdminPageHeader(title: 'as_products'.tr, trailing: 'adminProductsCount'.trParams({'n': '${c.items.length}'})),
            FilterBar(children: [
              AdminSearchField(hint: 'adminProductsSearch'.tr, onChanged: c.search),
              for (final f in ProductStatusFilter.values)
                FilterPill(label: 'apf_${f.name}'.tr, selected: c.filter == f, onTap: () => c.setFilter(f)),
            ]),
            TableWithPanel(
              table: AdminTable(
                columns: [
                  AdminColumn('adminColProduct'.tr, flex: 4),
                  AdminColumn('supplier'.tr, flex: 3),
                  AdminColumn('category'.tr, flex: 3),
                  AdminColumn('price'.tr, flex: 2),
                  AdminColumn('adminColStatus'.tr, flex: 3),
                ],
                minWidth: 640,
                emptyText: 'adminNoResults'.tr,
                selected: list.indexWhere((p) => p.id == c.selectedId),
                onTap: (i) => c.select(list[i].id),
                rows: [
                  for (final p in list)
                    [
                      Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(p.supplier, style: const TextStyle(fontSize: 14)),
                      Text(p.category, style: const TextStyle(fontSize: 14)),
                      Text(formatMoney(p.price, p.currency), style: const TextStyle(fontSize: 14)),
                      ProductStatusChip(status: p.status),
                    ],
                ],
              ),
              panel: c.selected == null ? null : _Panel(c: c, p: c.selected!),
            ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.c, required this.p});

  final AdminProductsController c;
  final AdminProduct p;

  @override
  Widget build(BuildContext context) {
    final hidden = p.status == AdminProductStatus.hiddenByAdmin;
    return AdminBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 150, child: ProductThumb(visual: p.visual, iconSize: 64)),
          const SizedBox(height: 14),
          Text(p.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          KeyValueList(keyWidth: 100, items: [
            (
              'supplier'.tr,
              InkWell(
                onTap: () => Get.find<AdminShellController>().openUser(p.supplierUserId),
                child: Text(p.supplier,
                    style: const TextStyle(color: AppColor.orangeDeep, decoration: TextDecoration.underline)),
              )
            ),
            ('stock'.tr, Text(formatCount(p.stock))),
            ('moq'.tr, Text(formatCount(p.moq))),
            ('images'.tr, Text('${p.images}')),
            ('adminLastEdit'.tr, Text(shortDate(p.updatedAt))),
          ]),
          if (p.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(p.description, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColor.textNote)),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: hidden ? 'adminShowProduct'.tr : 'adminHideProduct'.tr,
            style: hidden ? AppButtonStyle.primary : AppButtonStyle.secondary,
            isLoading: c.busy,
            onPressed: c.toggleHidden,
          ),
          const SizedBox(height: 8),
          Text(hidden ? 'adminShowHint'.tr : 'adminHideHint'.tr,
              style: const TextStyle(fontSize: 12, height: 1.5, color: AppColor.textSecondary)),
        ],
      ),
    );
  }
}
