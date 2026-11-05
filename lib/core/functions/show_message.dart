import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_color.dart';

/// رسالة قصيرة أسفل الشاشة (تأكيد نجاح، أو تنبيه بسيط).
void showMessage(String message) {
  Get.closeAllSnackbars();
  Get.showSnackbar(
    GetSnackBar(
      messageText: Text(
        message,
        style: const TextStyle(color: AppColor.surface, fontSize: 15, height: 1.5),
      ),
      backgroundColor: AppColor.ink,
      borderRadius: 14,
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    ),
  );
}
