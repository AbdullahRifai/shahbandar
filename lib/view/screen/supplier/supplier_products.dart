import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/supplier/supplier_products_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/product_model.dart';
import '../../widget/supplier/supplier_parts.dart';
import '../../widget/trader/product_thumb.dart';

/// C7 — منتجاتي: تبويبات (الكل، منشور، موقوف، نفد)، صف لكل منتج مع مفتاح النشر،
/// وزر "إضافة منتج" عائم. الضغط على المنتج يفتح التعديل (C9).
/// C10 — حين لا توجد منتجات أصلاً: دعوة لإضافة أول منتج مع ثلاث نصائح.
class SupplierProductsScreen extends StatelessWidget {
  const SupplierProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SupplierProductsController>(
      builder: (c) {
        final empty = c.status == StatusRequest.success && c.products.isEmpty;
        return Scaffold(
          appBar: AppBar(title: Text('stabProducts'.tr)),
          floatingActionButton: c.status == StatusRequest.success && !empty
              ? FloatingActionButton.extended(
                  onPressed: c.openAdd,
                  backgroundColor: AppColor.orange,
                  foregroundColor: AppColor.ink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  icon: const Icon(Icons.add_rounded),
                  label: Text('addProduct'.tr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                )
              : null,
          body: switch (c.status) {
            StatusRequest.failure => ErrorView(onRetry: c.load),
            StatusRequest.success when empty => _NoProducts(onAdd: c.openAdd),
            StatusRequest.success => MaxWidth(
                maxWidth: AppLayout.contentMaxWidth,
                child: Column(
                  children: [
                    _Tabs(c: c),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: c.load,
                        color: AppColor.ink,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          children: [
                            if (c.visible.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 48),
                                child: Text('noProductsInTab'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColor.textSecondary, fontSize: 15)),
                              )
                            else
                              RowsCard(children: [
                                for (final p in c.visible) _ProductRow(c: c, p: p),
                              ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _ => const LoadingView(),
          },
        );
      },
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.c});

  final SupplierProductsController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColor.divider))),
      child: Row(
        children: [
          for (final t in ProductsTab.values)
            Expanded(
              child: Semantics(
                selected: c.tab == t,
                button: true,
                child: InkWell(
                  onTap: () => c.setTab(t),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: c.tab == t ? AppColor.ink : Colors.transparent, width: 3),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${'pt_${t.name}'.tr} ${c.countOf(t)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.tab == t ? AppColor.ink : AppColor.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.c, required this.p});

  final SupplierProductsController c;
  final ProductModel p;

  @override
  Widget build(BuildContext context) {
    final Widget subtitle;
    if (!p.active) {
      subtitle = Text('pausedHint'.tr, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary));
    } else if (!p.inStock) {
      subtitle = Row(
        children: [
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColor.dangerSoft, borderRadius: BorderRadius.circular(11)),
            child: Text('outOfStock'.tr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.danger)),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text('outOfStockHint'.tr,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
          ),
        ],
      );
    } else {
      subtitle = Text(
        '${formatMoney(p.price, p.currency)} · ${'stockShortLabel'.trParams({'n': formatCount(p.stock)})} · ${'moqShort'.trParams({'n': formatCount(p.moq)})}',
        style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
      );
    }

    return InkWell(
      onTap: () => c.openEdit(p),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
        child: Row(
          children: [
            Opacity(
              opacity: p.active ? 1 : 0.55,
              child: ProductThumb(visual: p.visual, imageUrl: p.coverImage, size: 56, radius: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.active ? AppColor.ink : AppColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  subtitle,
                ],
              ),
            ),
            Semantics(
              label: 'publishProduct'.tr,
              child: Switch(
                value: p.active,
                onChanged: c.toggling.contains(p.id) ? null : (_) => c.toggle(p),
                activeTrackColor: AppColor.ink,
                inactiveTrackColor: AppColor.border,
                inactiveThumbColor: AppColor.surface,
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// C10 — لا منتجات بعد.
class _NoProducts extends StatelessWidget {
  const _NoProducts({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: AppColor.borderStrong, width: 1.5),
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 52, color: AppColor.ink),
              ),
              const SizedBox(height: 24),
              Text('noProductsTitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('noProductsBody'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColor.surface, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    for (var i = 1; i <= 3; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i == 1 ? 0 : 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$i',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColor.orangeDeep)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('productTip$i'.tr,
                                  style: const TextStyle(fontSize: 14, height: 1.6, color: AppColor.textNote)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(width: 220, child: AppButton(label: 'addProduct'.tr, onPressed: onAdd)),
            ],
          ),
        ),
      ),
    );
  }
}
