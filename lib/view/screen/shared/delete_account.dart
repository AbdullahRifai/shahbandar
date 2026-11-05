import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/shared/delete_account_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../widget/trader/trader_parts.dart';

/// D6 — طلب حذف الحساب.
/// قبل الإرسال: تنبيه الطلبات المفتوحة، ماذا يحدث بعد الإرسال، سبب اختياري، وتأكيد إلزامي.
/// بعد الإرسال: الطلب قيد المراجعة، مع إمكانية إلغائه.
class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeleteAccountController>(
      init: DeleteAccountController(),
      global: false,
      builder: (c) {
        final pending = c.request != null;
        return Scaffold(
          appBar: AppBar(title: Text('deleteAccount'.tr)),
          body: switch (c.status) {
            StatusRequest.failure => ErrorView(onRetry: c.load),
            StatusRequest.success => MaxWidth(child: pending ? _Pending(c: c) : _Form(c: c)),
            _ => const LoadingView(),
          },
          bottomNavigationBar: c.status != StatusRequest.success
              ? null
              : BottomActionBar(
                  child: pending
                      ? AppButton(
                          label: 'cancelDeletion'.tr,
                          style: AppButtonStyle.secondary,
                          isLoading: c.busy,
                          onPressed: c.cancelRequest,
                        )
                      : AppButton(
                          label: 'sendDeletion'.tr,
                          style: AppButtonStyle.danger,
                          isLoading: c.busy,
                          onPressed: c.canSubmit ? c.submit : null,
                        ),
                ),
        );
      },
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.c});

  final DeleteAccountController c;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (c.openOrders.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppColor.warningSoft, borderRadius: BorderRadius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColor.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'openOrdersWarning'.trParams({
                      'n': '${c.openOrders.length}',
                      'ids': c.openOrders.take(3).map((id) => '#$id').join('، '),
                    }),
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF5C3D00)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('whatHappens'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (var i = 1; i <= 3; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 1 ? 0 : 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColor.note, shape: BoxShape.circle),
                        child: Text('$i', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('deleteStep$i'.tr, style: const TextStyle(fontSize: 15, height: 1.5)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: 'whyLeaving'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: ' ${'optional'.tr}', style: const TextStyle(color: AppColor.textSecondary)),
          ]),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: c.reason,
          minLines: 2,
          maxLines: 4,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'whyLeavingHint'.tr,
            filled: true,
            fillColor: AppColor.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColor.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColor.ink, width: 2),
            ),
          ),
        ),
        CheckboxListTile(
          value: c.understood,
          onChanged: c.setUnderstood,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColor.ink,
          title: Text('deleteUnderstand'.tr, style: const TextStyle(fontSize: 15, height: 1.5)),
        ),
      ],
    );
  }
}

class _Pending extends StatelessWidget {
  const _Pending({required this.c});

  final DeleteAccountController c;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColor.warningSoft, shape: BoxShape.circle),
            child: const Icon(Icons.hourglass_top_rounded, color: AppColor.warning, size: 34),
          ),
        ),
        const SizedBox(height: 20),
        Text('deletionPendingTitle'.tr,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'deletionPendingBody'.trParams({'d': formatDate(c.request!.createdAt)}),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary),
        ),
      ],
    );
  }
}
