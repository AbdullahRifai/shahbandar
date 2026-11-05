import 'package:flutter/widgets.dart';

import '../constant/app_layout.dart';

/// يحدّ عرض المحتوى ويضعه في المنتصف.
/// على الهاتف لا يغيّر شيئاً، وعلى التابلت وWindows يمنع تمدد النماذج
/// على كامل عرض الشاشة.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = AppLayout.formMaxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
