import 'dart:async';

import 'package:get/get.dart';

/// عدّاد تنازلي لأزرار "إعادة الإرسال" (FR-7: حد لعدد الطلبات).
/// يُضاف لأي متحكم بـ `with CountdownMixin`، ويُلغى تلقائياً عند إغلاق الشاشة.
mixin CountdownMixin on GetxController {
  int secondsLeft = 0;
  Timer? _timer;

  bool get isCounting => secondsLeft > 0;

  /// بصيغة 0:45
  String get countdownText {
    final minutes = secondsLeft ~/ 60;
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startCountdown(int seconds) {
    _timer?.cancel();
    secondsLeft = seconds;
    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        secondsLeft = 0;
        timer.cancel();
      }
      update();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
