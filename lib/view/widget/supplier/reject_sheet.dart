import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';

/// أسباب الرفض الجاهزة. كلها اختيارية (FR-48).
enum RejectReason { outOfStock, noDelivery, productStopped, other }

/// C4 — رفض الطلب.
/// يرجع null عند "تراجع"، أو نص السبب الذي يراه التاجر (قد يكون فارغاً).
Future<String?> showRejectSheet(String orderId) {
  return Get.bottomSheet<String>(
    _RejectSheet(orderId: orderId),
    backgroundColor: AppColor.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  );
}

class _RejectSheet extends StatefulWidget {
  const _RejectSheet({required this.orderId});

  final String orderId;

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  static const int _max = 300;
  RejectReason? _reason;
  final _details = TextEditingController();

  @override
  void initState() {
    super.initState();
    _details.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  /// السبب كما يصل للتاجر: عنوان السبب ثم التفاصيل.
  String _compose() {
    final parts = <String>[
      if (_reason != null && _reason != RejectReason.other) 'rr_${_reason!.name}'.tr,
      if (_details.text.trim().isNotEmpty) _details.text.trim(),
    ];
    return parts.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: AppColor.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  header: true,
                  child: Text('rejectTitle'.trParams({'n': widget.orderId}),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Text('rejectBody'.tr,
                    style: const TextStyle(fontSize: 15, height: 1.6, color: AppColor.textSecondary)),
                const SizedBox(height: 16),
                _optionalLabel('rejectReason'.tr),
                RadioGroup<RejectReason>(
                  groupValue: _reason,
                  onChanged: (v) => setState(() => _reason = v),
                  child: Column(
                    children: [
                      for (final r in RejectReason.values)
                        RadioListTile<RejectReason>(
                          value: r,
                          title: Text('rr_${r.name}'.tr, style: const TextStyle(fontSize: 16)),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColor.ink,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _optionalLabel('rejectDetails'.tr),
                TextField(
                  controller: _details,
                  maxLines: 3,
                  maxLength: _max,
                  decoration: InputDecoration(
                    hintText: 'rejectDetailsHint'.tr,
                    counterText: '${_details.text.length} / $_max',
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'undo'.tr,
                        style: AppButtonStyle.secondary,
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'rejectOrder'.tr,
                        style: AppButtonStyle.danger,
                        onPressed: () => Get.back(result: _compose()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionalLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: ' ${'optional'.tr}', style: const TextStyle(color: AppColor.textSecondary)),
          ]),
          style: const TextStyle(fontSize: 14),
        ),
      );
}
