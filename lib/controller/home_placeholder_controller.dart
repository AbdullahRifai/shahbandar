import 'package:get/get.dart';

import '../core/constant/app_routes.dart';
import '../core/services/session_service.dart';

/// متحكم مؤقت للوحتي التاجر والمورد حتى نبنيهما.
/// يسمح بتسجيل الخروج لتجربة رحلة الحساب من جديد.
class HomePlaceholderController extends GetxController {
  final SessionService _session = Get.find();

  String get email => _session.currentUser?.email ?? '';

  Future<void> logout() async {
    await _session.clear();
    Get.offAllNamed(AppRoute.login);
  }
}
