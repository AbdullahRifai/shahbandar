import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/logo_picker_mixin.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/home_route.dart';
import '../../core/functions/show_message.dart';
import '../../core/services/session_service.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/auth_failure.dart';
import '../../data/model/business_profile_model.dart';
import '../../data/model/option_model.dart';

/// A7 الملف التجاري لأول مرة (FR-11 إلى FR-14).
class BusinessSetupController extends GetxController with LogoPickerMixin {
  final AuthData _auth = Get.find();
  final SessionService _session = Get.find();

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  late final contactEmail = TextEditingController(text: _session.currentUser?.email);

  List<OptionModel> categories = [];
  List<OptionModel> cities = [];
  OptionModel? category;
  OptionModel? city;

  StatusRequest statusRequest = StatusRequest.none;
  bool submitted = false;

  bool get isLoading => statusRequest == StatusRequest.loading;

  /// FR-13: وسيلة تواصل واحدة على الأقل.
  bool get hasContact => phone.text.trim().isNotEmpty || contactEmail.text.trim().isNotEmpty;

  String? get categoryError => submitted && category == null ? 'fieldRequired'.tr : null;
  String? get cityError => submitted && city == null ? 'fieldRequired'.tr : null;
  String? get contactError => submitted && !hasContact ? 'contactRequired'.tr : null;

  @override
  void onInit() {
    super.onInit();
    _loadOptions();
    phone.addListener(update);
    contactEmail.addListener(update);
  }

  Future<void> _loadOptions() async {
    categories = await _auth.businessCategories();
    cities = await _auth.cities();
    update();
  }

  void selectCategory(OptionModel value) {
    category = value;
    update();
  }

  void selectCity(OptionModel value) {
    city = value;
    update();
  }

  Future<void> save() async {
    if (isLoading || logoUploading) return;
    submitted = true;
    final fieldsValid = formKey.currentState?.validate() ?? false;
    if (!fieldsValid || category == null || city == null || !hasContact) return update();

    final user = _session.currentUser;
    if (user == null) return;

    statusRequest = StatusRequest.loading;
    update();
    try {
      final updated = await _auth.saveBusinessProfile(
        user.email,
        BusinessProfileModel(
          name: name.text.trim(),
          categoryId: category!.id,
          cityId: city!.id,
          address: address.text.trim(),
          phone: phone.text.replaceAll(' ', ''),
          contactEmail: contactEmail.text.trim(),
          logoUrl: logoUrl,
        ),
      );
      _session.update(updated);
      Get.offAllNamed(homeRouteFor(updated));
      return;
    } on AuthFailure {
      statusRequest = StatusRequest.failure;
      showMessage('errorGeneric'.tr);
    }
    update();
  }

  @override
  void onClose() {
    name.dispose();
    address.dispose();
    phone.dispose();
    contactEmail.dispose();
    super.onClose();
  }
}
