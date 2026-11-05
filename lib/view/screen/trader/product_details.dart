import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/product_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/quantity_stepper.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/product_model.dart';
import '../../widget/trader/product_card.dart';
import '../../widget/trader/product_thumb.dart';
import '../../widget/trader/trader_parts.dart';

/// B6 — تفاصيل المنتج.
/// الصورة، الاسم والسعر، المخزون والحد الأدنى، الوصف، بطاقة المورد،
/// وفي الأسفل: الكمية + "أضف إلى السلة". على الشاشات العريضة الصورة بجانب التفاصيل.
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      init: ProductController(productId),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(
          actions: [
            if (c.product != null)
              IconButton(
                onPressed: c.toggleCompare,
                tooltip: c.inCompare ? 'removeFromCompare'.tr : 'addToCompare'.tr,
                isSelected: c.inCompare,
                icon: const Icon(Icons.compare_arrows_rounded),
                selectedIcon: const Icon(Icons.compare_arrows_rounded, color: AppColor.orangeDeep),
              ),
            const SizedBox(width: 4),
          ],
        ),
        body: switch (c.status) {
          StatusRequest.failure when c.notFound => EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'productUnavailable'.tr,
              message: 'productUnavailableHint'.tr,
              actionLabel: 'back'.tr,
              onAction: () => Get.back(),
            ),
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => _Body(c: c, p: c.product!),
          _ => const LoadingView(),
        },
        bottomNavigationBar: c.product == null ? null : _AddBar(c: c, p: c.product!),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.c, required this.p});

  final ProductController c;
  final ProductModel p;

  @override
  Widget build(BuildContext context) {
    final image = AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProductThumb(visual: p.visual, imageUrl: p.coverImage, radius: 20, iconSize: 88),
          if (!p.inStock) const PositionedDirectional(top: 12, start: 12, child: OutOfStockBadge()),
        ],
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.4)),
        const SizedBox(height: 6),
        Text(formatMoney(p.price, p.currency),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        Text('perUnit'.tr, style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Fact(
                icon: p.inStock ? Icons.inventory_2_outlined : Icons.remove_shopping_cart_outlined,
                label: 'stock'.tr,
                value: p.inStock ? formatCount(p.stock) : 'outOfStock'.tr,
                color: p.inStock ? AppColor.success : AppColor.dangerText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Fact(
                icon: Icons.low_priority_rounded,
                label: 'moq'.tr,
                value: formatCount(p.moq),
                color: AppColor.ink,
              ),
            ),
          ],
        ),
        if (p.inStock && !p.orderable) ...[
          const SizedBox(height: 10),
          Text('stockBelowMoq'.tr, style: const TextStyle(color: AppColor.dangerText, fontSize: 14)),
        ],
        if (p.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionHeader(title: 'description'.tr),
          Text(p.description, style: const TextStyle(fontSize: 15, height: 1.7)),
        ],
        const SizedBox(height: 20),
        SectionHeader(title: 'supplier'.tr),
        Material(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: c.openSupplier,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  SupplierAvatar(initial: _initial(p.supplierName)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.supplierName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text(p.supplierCity, style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Text('viewSupplier'.tr,
                      style: const TextStyle(color: AppColor.orangeDeep, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right_rounded, color: AppColor.orangeDeep),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 760;
        return MaxWidth(
          maxWidth: wide ? 1000 : 600,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: image),
                      const SizedBox(width: 24),
                      Expanded(child: details),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [image, const SizedBox(height: 16), details],
                  ),
          ),
        );
      },
    );
  }

  /// الحرف الأول من اسم المورد دون "شركة/مؤسسة/مجموعة" وأداة التعريف.
  static String _initial(String name) {
    const skip = {'شركة', 'مؤسسة', 'مجموعة', 'متجر'};
    final word = name.split(' ').firstWhere((w) => !skip.contains(w), orElse: () => name);
    final clean = word.startsWith('ال') && word.length > 2 ? word.substring(2) : word;
    return clean.isEmpty ? '?' : String.fromCharCode(clean.runes.first);
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColor.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColor.textSecondary, fontSize: 12.5)),
                Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط الإضافة: محدد الكمية + الزر. النافد أو الأقل من الحد الأدنى ← الزر معطّل مع السبب.
class _AddBar extends StatelessWidget {
  const _AddBar({required this.c, required this.p});

  final ProductController c;
  final ProductModel p;

  @override
  Widget build(BuildContext context) {
    if (!p.orderable) {
      return BottomActionBar(
        child: AppButton(label: p.inStock ? 'notOrderable'.tr : 'outOfStock'.tr, onPressed: null),
      );
    }
    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              QuantityStepper(value: c.quantity, min: p.moq, max: p.stock, onChanged: c.setQuantity),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('lineTotal'.tr, style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                    Text(formatMoney(p.price * c.quantity, p.currency),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(
            label: c.inCart ? 'updateCart'.tr : 'addToCart'.tr,
            onPressed: c.addToCart,
          ),
        ],
      ),
    );
  }
}
