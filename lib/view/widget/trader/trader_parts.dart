import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_routes.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/services/cart_service.dart';
import '../../../data/model/product_model.dart';

/// أجزاء صغيرة تتكرر في شاشات التاجر.

/// عنوان قسم مع رابط اختياري ("عرض الكل").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColor.orangeDeep,
                minimumSize: const Size(48, 48),
              ),
              child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

/// دائرة بالحرف الأول من اسم المورد (حتى يرفع شعاره).
class SupplierAvatar extends StatelessWidget {
  const SupplierAvatar({super.key, required this.initial, this.size = 40});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: AppColor.ink, borderRadius: BorderRadius.circular(size * 0.3)),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(color: AppColor.orangeOnInk, fontSize: size * 0.45, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// المجاميع لكل عملة في أسطر منفصلة: لا نجمع الدولار مع الليرة أبداً.
class CurrencyTotals extends StatelessWidget {
  const CurrencyTotals({super.key, required this.totals, this.large = false});

  final Map<Currency, double> totals;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()..sort((a, b) => a.key.index - b.key.index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in entries)
          Text(
            formatMoney(e.value, e.key),
            style: TextStyle(fontSize: large ? 18 : 15, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }
}

/// أيقونة السلة مع عدّاد الأصناف، تتحدث تلقائياً.
class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key, this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartService>(
      builder: (cart) => Badge(
        isLabelVisible: cart.count > 0,
        label: Text('${cart.count}'),
        backgroundColor: AppColor.orange,
        textColor: AppColor.ink,
        child: Icon(selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined),
      ),
    );
  }
}

/// زر المقارنة العائم أعلى القوائم حين يكون في المقارنة منتجان أو أكثر.
class CompareShortcut extends StatelessWidget {
  const CompareShortcut({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed(AppRoute.compare),
      backgroundColor: AppColor.ink,
      foregroundColor: AppColor.surface,
      icon: const Icon(Icons.compare_arrows_rounded),
      label: Text('compareCount'.trParams({'n': '$count'})),
    );
  }
}

/// حاوية بيضاء بزوايا 20، للأقسام داخل الصفحات.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: AppColor.surface, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}

/// شريط سفلي ثابت للإجراء الرئيسي، فوق المحتوى بخط فاصل.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.surface,
        border: Border(top: BorderSide(color: AppColor.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: child),
          ),
        ),
      ),
    );
  }
}

/// أيقونة كل تصنيف (حتى تُضاف صور التصنيفات من لوحة الأدمن).
IconData categoryIcon(String id) => switch (id) {
      'food' => Icons.local_grocery_store_outlined,
      'paper' => Icons.layers_outlined,
      'packaging' => Icons.inventory_2_outlined,
      'cleaning' => Icons.cleaning_services_outlined,
      _ => Icons.category_outlined,
    };
