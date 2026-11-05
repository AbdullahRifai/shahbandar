import 'package:flutter/material.dart';

import '../../../core/shared/max_width.dart';

/// الهيكل المتكرر في شاشات الحساب: محتوى قابل للتمرير في الأعلى،
/// وأزرار [bottom] ملتصقة بأسفل الشاشة عندما يتسع المكان،
/// وتنزل تحت المحتوى بالتمرير عندما تظهر لوحة المفاتيح.
class AuthBody extends StatelessWidget {
  const AuthBody({
    super.key,
    required this.children,
    this.bottom = const [],
    this.top = 24,
    this.centered = false,
  });

  final List<Widget> children;
  final List<Widget> bottom;
  final double top;

  /// للشاشات التي محتواها في الوسط (أيقونة + عنوان + نص).
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MaxWidth(
            child: Padding(
            padding: EdgeInsets.fromLTRB(24, top, 24, 16 + inset),
            child: Column(
              crossAxisAlignment:
                  centered ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
              children: [
                ...children,
                const Spacer(),
                const SizedBox(height: 24),
                ...bottom,
              ],
            ),
          ),
          ),
        ),
      ],
    );
  }
}
