import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constant/app_color.dart';
import 'app_button.dart';

/// محدد الكمية: − العدد +. الضغط على العدد يفتح حقلاً لكتابة الكمية مباشرة،
/// لأن كميات الجملة كبيرة (من 30 إلى 100 بالضغط وحده مرهق).
/// الزر يتعطل عند الحد الأدنى أو الأعلى.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.compact = false,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  /// داخل السلة: أصغر قليلاً بصرياً، ومساحة اللمس تبقى 44 على الأقل.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 48.0;
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        border: Border.all(color: AppColor.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove_rounded, 'decrease'.tr, value > min ? () => onChanged(value - 1) : null, size),
          Semantics(
            button: true,
            label: 'editQuantity'.tr,
            child: InkWell(
              onTap: () => _edit(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: compact ? 44 : 56, minHeight: size),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(fontSize: compact ? 15 : 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          _button(Icons.add_rounded, 'increase'.tr, value < max ? () => onChanged(value + 1) : null, size),
        ],
      ),
    );
  }

  Widget _button(IconData icon, String tooltip, VoidCallback? onTap, double size) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      color: AppColor.ink,
      disabledColor: AppColor.borderStrong,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      padding: EdgeInsets.zero,
    );
  }

  Future<void> _edit(BuildContext context) async {
    final field = TextEditingController(text: '$value');
    final result = await Get.dialog<int>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('editQuantity'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: field,
              autofocus: true,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'quantityRange'.trParams({'min': '$min', 'max': '$max'}),
              style: const TextStyle(color: AppColor.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          AppButton(
            label: 'save'.tr,
            onPressed: () {
              final n = int.tryParse(field.text) ?? value;
              Get.back(result: n.clamp(min, max));
            },
          ),
        ],
      ),
    );
    field.dispose();
    if (result != null && result != value) onChanged(result);
  }
}
