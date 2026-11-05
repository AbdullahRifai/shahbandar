import 'package:flutter/material.dart';

import '../constant/app_color.dart';

/// "قسيمة الطلب": العنصر المميّز لشاهبندر.
/// بطاقة بيضاء لكل مورد، يفصل رأسها عن محتواها خط مثقّب بنصفي دائرة على الجانبين،
/// كإيصال يُقتطع. تظهر في السلة والمراجعة وتأكيد الإرسال وتفاصيل الطلب.
class OrderSlip extends StatelessWidget {
  const OrderSlip({
    super.key,
    required this.header,
    required this.child,
    this.footer,
    this.notchColor = AppColor.background,
  });

  final Widget header;
  final Widget child;
  final Widget? footer;

  /// لون الخلفية خلف البطاقة، حتى يبدو الثقب مقطوعاً فعلاً.
  final Color notchColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0D17202E), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: header),
          _Perforation(notchColor: notchColor),
          Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 14), child: child),
          if (footer != null) ...[
            _Perforation(notchColor: notchColor),
            Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 14), child: footer),
          ],
        ],
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation({required this.notchColor});

  final Color notchColor;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 20,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: CustomPaint(size: const Size(double.infinity, 1.5), painter: _DashPainter()),
            ),
            PositionedDirectional(start: -10, child: _notch()),
            PositionedDirectional(end: -10, child: _notch()),
          ],
        ),
      ),
    );
  }

  Widget _notch() => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: notchColor, shape: BoxShape.circle),
      );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.border
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;
    const dash = 5.0, gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dash).clamp(0, size.width), 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
