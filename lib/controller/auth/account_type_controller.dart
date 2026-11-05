import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/app_routes.dart';
import '../../core/functions/show_message.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/auth_failure.dart';
import '../../data/model/user_model.dart';

/// A6 اختيار الأدوار (FR-10): دور أو الاثنين، بنفس الحساب.
class AccountTypeController extends GetxController {
  final AuthData _auth = Get.find();
  final SessionService _session = Get.find();

  late final Set<UserRole> selected = {...?_session.currentUser?.roles};
  StatusRequest statusRequest = StatusRequest.none;

  bool get isLoading => statusRequest == StatusRequest.loading;
  bool get canContinue => selected.isNotEmpty && !isLoading;

  void toggle(UserRole role) {
    selected.contains(role) ? selected.remove(role) : selected.add(role);
    update();
  }

  Future<void> continueToProfile() async {
    final user = _session.currentUser;
    if (!canContinue || user == null) return;

    statusRequest = StatusRequest.loading;
    update();
    try {
      _session.update(await _auth.setRoles(user.email, {...selected}));
      statusRequest = StatusRequest.success;
      // toNamed لا offAll: يستطيع الرجوع من الملف التجاري لتعديل الأدوار.
      Get.toNamed(AppRoute.businessSetup);
    } on AuthFailure {
      statusRequest = StatusRequest.failure;
      showMessage('errorGeneric'.tr);
    }
    update();
  }
}
