import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/supplier_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_layout.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/supplier_model.dart';
import '../../widget/trader/product_card.dart';
import '../../widget/trader/trader_parts.dart';

/// B7 — صفحة المورد: البطاقة التعريفية، وسائل التواصل (للنسخ)، ومنتجاته النشطة.
class SupplierPageScreen extends StatelessWidget {
  const SupplierPageScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SupplierController>(
      init: SupplierController(supplierId),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('supplier'.tr)),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => MaxWidth(
              maxWidth: AppLayout.contentMaxWidth,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    sliver: SliverList.list(
                      children: [
                        _Profile(c: c, s: c.supplier!),
                        const SizedBox(height: 8),
                        SectionHeader(title: 'supplierProducts'.trParams({'n': '${c.products.length}'})),
                      ],
                    ),
                  ),
                  if (c.products.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('supplierNoProducts'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColor.textSecondary)),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: ProductSliverGrid(products: c.products),
                    ),
                ],
              ),
            ),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.c, required this.s});

  final SupplierController c;
  final SupplierModel s;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SupplierAvatar(initial: s.initial, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4)),
                    const SizedBox(height: 2),
                    Text('${s.activity} · ${s.city}',
                        style: const TextStyle(color: AppColor.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          if (s.about.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(s.about, style: const TextStyle(fontSize: 15, height: 1.7)),
          ],
          const Divider(height: 28, color: AppColor.divider),
          if (s.phone.isNotEmpty) _ContactRow(icon: Icons.phone_outlined, value: s.phone, onCopy: () => c.copy(s.phone)),
          if (s.email.isNotEmpty) _ContactRow(icon: Icons.mail_outline_rounded, value: s.email, onCopy: () => c.copy(s.email)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value, required this.onCopy});

  final IconData icon;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColor.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          // قيمة LTR بجانب الأيقونة مباشرة في الاتجاهين.
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 15)),
          ),
        ),
        IconButton(
          onPressed: onCopy,
          tooltip: 'copy'.tr,
          icon: const Icon(Icons.copy_rounded, size: 20),
        ),
      ],
    );
  }
}
