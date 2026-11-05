import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_routes.dart';
import '../../../core/functions/format_money.dart';
import '../../../data/model/product_model.dart';
import 'product_thumb.dart';

/// بطاقة منتج في الشبكة: الصورة، الاسم، المورد ومدينته، السعر، والحد الأدنى.
/// المنتج النافد يبقى ظاهراً مع شارة "نفد" (FR-21).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  /// ارتفاع البطاقة في الشبكة، حتى تتساوى البطاقات على كل المقاسات.
  static const double height = 286;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoute.product, arguments: p.id),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductThumb(visual: p.visual, imageUrl: p.coverImage),
                    if (!p.inStock)
                      PositionedDirectional(top: 8, start: 8, child: const OutOfStockBadge()),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 2),
              Text(
                '${p.supplierName} · ${p.supplierCity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: AppColor.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                formatMoney(p.price, p.currency),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: p.inStock ? AppColor.ink : AppColor.textSecondary,
                ),
              ),
              Text(
                'moqShort'.trParams({'n': formatCount(p.moq)}),
                style: const TextStyle(fontSize: 12.5, color: AppColor.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutOfStockBadge extends StatelessWidget {
  const OutOfStockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColor.ink, borderRadius: BorderRadius.circular(8)),
      child: Text(
        'outOfStock'.tr,
        style: const TextStyle(color: AppColor.surface, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// شبكة منتجات متجاوبة: عمودان على الهاتف، وأكثر كلما اتسعت الشاشة.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: ProductCard.height,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  }
}
