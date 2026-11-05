import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/trader_shell_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_routes.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/order_slip.dart';
import '../../../core/shared/status_chip.dart';
import '../../../data/model/order_model.dart';

/// B12 — تم إرسال الطلب.
/// رقم عملية الشراء، وقسيمة تسرد الموردين وكلٌّ "بانتظار الرد"، وما سيحدث بعد ذلك.
class OrderSentScreen extends StatelessWidget {
  const OrderSentScreen({super.key, required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<TraderShellController>();
    final p = purchase;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goHome();
      },
      child: Scaffold(
        body: SafeArea(
          child: MaxWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(color: AppColor.successSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: AppColor.success, size: 44),
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  header: true,
                  child: Text('orderSentTitle'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Text(
                  'orderSentBody'.trParams({'n': '${p.subOrders.length}'}),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColor.textSecondary, fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 24),
                OrderSlip(
                  header: Row(
                    children: [
                      Expanded(
                        child: Text('purchaseNo'.trParams({'n': p.id}),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                      Text(formatDateTime(p.createdAt),
                          style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (final s in p.subOrders)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.supplierName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                    Text(formatMoney(s.total, s.currency),
                                        style: const TextStyle(color: AppColor.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              StatusChip(status: s.status),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'trackOrder'.tr,
                  onPressed: () {
                    shell.openOrders();
                    Get.offNamed(AppRoute.purchase, arguments: p.id);
                  },
                ),
                const SizedBox(height: 10),
                AppButton(label: 'backHome'.tr, style: AppButtonStyle.secondary, onPressed: shell.goHome),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
