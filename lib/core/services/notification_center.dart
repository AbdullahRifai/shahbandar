import 'package:get/get.dart';

import '../../data/datasource/account_data.dart';
import '../../data/model/user_model.dart';

/// عدد الإشعارات غير المقروءة للوضع الحالي، لنقطة الجرس وسطر "الإشعارات" في حسابي.
/// يتحدث عند فتح اللوحة، وبعد الرجوع من شاشة الإشعارات.
class NotificationCenter extends GetxController {
  final AccountData _data = Get.find();

  int unread = 0;

  Future<void> refreshFor(UserRole role) async {
    try {
      unread = await _data.unreadCount(role);
    } catch (_) {
      // نقطة الجرس ليست حرجة: نبقي العدد السابق.
    }
    update();
  }
}
