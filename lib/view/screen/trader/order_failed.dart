import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/trader/cart_controller.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/info_note.dart';
import '../../../core/shared/max_width.dart';
import '../../../data/model/request_failure.dart';

/// B13 — تعذّر إرسال الطلب.
/// يطمئن التاجر أن سلته محفوظة وأنه لم يُنشأ أي طلب، ويعرض إعادة المحاولة.
/// إعادة المحاولة تستخدم نفس معرّف الطلب، فلا يتكرر إن كان قد وصل فعلاً (FR-55).
class OrderFailedScreen extends StatelessWidget {
  const OrderFailedScreen({super.key, required this.reason});

  final RequestFailureType reason;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (c) => PopScope(
        canPop: !c.placing,
        child: Scaffold(
          appBar: AppBar(automaticallyImplyLeading: !c.placing),
          body: SafeArea(
            child: MaxWidth(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(color: AppColor.dangerSoft, shape: BoxShape.circle),
                      child: Icon(
                        reason == RequestFailureType.offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                        color: AppColor.danger,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    child: Text('orderFailedTitle'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reason == RequestFailureType.offline ? 'orderFailedOffline'.tr : 'orderFailedGeneric'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColor.textSecondary, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  InfoNote(icon: Icons.shopping_cart_checkout_rounded, text: 'cartKept'.tr),
                  const SizedBox(height: 32),
                  AppButton(label: 'retry'.tr, isLoading: c.placing, onPressed: c.placeOrder),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'backToCart'.tr,
                    style: AppButtonStyle.secondary,
                    onPressed: c.placing ? null : c.backToCart,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
