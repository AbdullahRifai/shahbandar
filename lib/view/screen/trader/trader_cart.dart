import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/cart_controller.dart';
import '../../../controller/trader/trader_shell_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/constant/app_routes.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/order_slip.dart';
import '../../../core/shared/quantity_stepper.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/cart_item_model.dart';
import '../../widget/trader/product_thumb.dart';
import '../../widget/trader/trader_parts.dart';

/// B9 — السلة، وB10 حين يكون فيها أصناف غير صالحة.
/// قسيمة لكل مورد، لأن كل مورد يصله طلب منفصل. المجاميع لكل عملة على حدة.
class TraderCartScreen extends StatelessWidget {
  const TraderCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartService>(
      builder: (cart) => GetBuilder<CartController>(
        builder: (c) => Scaffold(
          appBar: AppBar(title: Text('tabCart'.tr)),
          body: cart.isEmpty
              ? EmptyView(
                  icon: Icons.shopping_cart_outlined,
                  title: 'cartEmpty'.tr,
                  message: 'cartEmptyHint'.tr,
                  actionLabel: 'browseProducts'.tr,
                  onAction: Get.find<TraderShellController>().openSearch,
                )
              : _CartBody(c: c, cart: cart),
          bottomNavigationBar: cart.isEmpty ? null : _CheckoutBar(c: c, cart: cart),
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.c, required this.cart});

  final CartController c;
  final CartService cart;

  @override
  Widget build(BuildContext context) {
    final groups = cart.bySupplier.values.toList();
    return MaxWidth(
      maxWidth: AppLayout.contentMaxWidth,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (c.validating)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColor.ink, backgroundColor: AppColor.divider),
            ),
          if (c.validationFailed) ...[
            _Banner(
              color: AppColor.dangerSoft,
              fg: AppColor.dangerText,
              icon: Icons.wifi_off_rounded,
              text: 'validateFailed'.tr,
              action: 'retry'.tr,
              onAction: c.validate,
            ),
            const SizedBox(height: 12),
          ],
          // B10: ملخص المشاكل أعلى السلة، والتفاصيل عند كل صنف.
          if (c.hasIssues) ...[
            _Banner(
              color: AppColor.dangerSoft,
              fg: AppColor.dangerText,
              icon: Icons.error_outline_rounded,
              text: 'issuesSummary'.trParams({'n': '${c.issues.length}'}),
            ),
            const SizedBox(height: 12),
          ],
          if (c.priceChanges.isNotEmpty) ...[
            _Banner(
              color: AppColor.warningSoft,
              fg: AppColor.warning,
              icon: Icons.trending_up_rounded,
              text: [
                'priceChangedTitle'.tr,
                for (final ch in c.priceChanges)
                  'priceChangeLine'.trParams({
                    'name': ch.productName,
                    'old': formatMoney(ch.oldPrice, ch.currency),
                    'new': formatMoney(ch.newPrice, ch.currency),
                  }),
              ].join('\n'),
              action: 'gotIt'.tr,
              onAction: c.dismissPriceChanges,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'cartSummary'.trParams({'items': '${cart.count}', 'suppliers': '${cart.supplierCount}'}),
            style: const TextStyle(color: AppColor.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 10),
          for (final items in groups) ...[
            _SupplierSlip(c: c, items: items),
            const SizedBox(height: 14),
          ],
          const InfoNoteLine(),
        ],
      ),
    );
  }
}

class InfoNoteLine extends StatelessWidget {
  const InfoNoteLine({super.key});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColor.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text('splitNote'.tr,
                style: const TextStyle(color: AppColor.textSecondary, fontSize: 13.5, height: 1.5)),
          ),
        ],
      );
}

class _SupplierSlip extends StatelessWidget {
  const _SupplierSlip({required this.c, required this.items});

  final CartController c;
  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    final first = items.first.product;
    final subtotal = items.fold<double>(0, (s, i) => s + i.total);
    return OrderSlip(
      header: Row(
        children: [
          const Icon(Icons.storefront_outlined, size: 20, color: AppColor.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(first.supplierName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          Text(first.supplierCity, style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
        ],
      ),
      footer: Row(
        children: [
          Expanded(child: Text('supplierSubtotal'.tr, style: const TextStyle(color: AppColor.textSecondary))),
          Text(formatMoney(subtotal, first.currency),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: AppColor.divider),
            _CartLine(c: c, item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.c, required this.item});

  final CartController c;
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final issue = c.issueFor(p.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoute.product, arguments: p.id),
              child: ProductThumb(visual: p.visual, imageUrl: p.coverImage, size: 64, radius: 12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
                  const SizedBox(height: 2),
                  Text(
                    '${'unitPrice'.trParams({'v': formatMoney(p.price, p.currency)})} · ${'moqShort'.trParams({'n': formatCount(p.moq)})}',
                    style: const TextStyle(color: AppColor.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => c.remove(p.id),
              tooltip: 'removeItem'.tr,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColor.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            QuantityStepper(
              compact: true,
              value: item.quantity,
              min: c.minFor(item),
              max: c.maxFor(item),
              onChanged: (v) => c.setQuantity(item, v),
            ),
            const Spacer(),
            Text(formatMoney(item.total, p.currency),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        if (issue != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            decoration: BoxDecoration(color: AppColor.dangerSoft, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 18, color: AppColor.dangerText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'issue_${issue.type.name}'.trParams({
                          'n': formatCount(issue.available),
                          'moq': formatCount(p.moq),
                        }),
                        style: const TextStyle(color: AppColor.dangerText, fontSize: 13.5, height: 1.5),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.end,
                  children: [
                    if (c.canUseAvailable(issue, item))
                      AppTextLink(
                        label: 'useAvailable'.trParams({'n': formatCount(issue.available)}),
                        onPressed: () => c.useAvailable(item),
                      ),
                    AppTextLink(label: 'removeItem'.tr, onPressed: () => c.remove(p.id)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.fg,
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
  });

  final Color color;
  final Color fg;
  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 10),
                Expanded(child: Text(text, style: TextStyle(color: fg, fontSize: 14, height: 1.6))),
              ],
            ),
            if (action != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(foregroundColor: fg, minimumSize: const Size(48, 44)),
                  child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// المجاميع لكل عملة + زر المتابعة، معطّل حتى تُحل كل المشاكل.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.c, required this.cart});

  final CartController c;
  final CartService cart;

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('total'.tr, style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                Align(alignment: AlignmentDirectional.centerStart, child: CurrencyTotals(totals: cart.totals)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 170,
            child: AppButton(
              label: c.hasIssues ? 'fixItemsFirst'.tr : 'continue'.tr,
              isLoading: c.validating,
              onPressed: c.canContinue ? c.goToReview : null,
            ),
          ),
        ],
      ),
    );
  }
}
