import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/logo_picker_mixin.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/first_where_or_null.dart';
import '../../core/functions/show_message.dart';
import '../../core/functions/valid_input.dart';
import '../../data/datasource/account_data.dart';
import '../../data/datasource/auth_data.dart';
import '../../data/model/business_profile_model.dart';
import '../../data/model/option_model.dart';

/// D3 — تعديل الملف التجاري (FR-11 إلى FR-14). نفس قواعد A7:
/// الاسم والنشاط والمدينة مطلوبة، ووسيلة تواصل واحدة على الأقل.
/// الزر معطّل حتى يتغير شيء وتكتمل الحقول المطلوبة، والأخطاء بعد أول حفظ.
class BusinessProfileController extends GetxController with LogoPickerMixin {
  final AccountData _data = Get.find();
  final AuthData _auth = Get.find();

  StatusRequest status = StatusRequest.none;
  bool saving = false;
  bool submitted = false;

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final contactEmail = TextEditingController();

  List<OptionModel> categories = [];
  List<OptionModel> cities = [];
  OptionModel? category;
  OptionModel? city;

  /// ما كان محفوظاً، لمعرفة إن تغيّر شيء.
  BusinessProfileModel? _original;

  @override
  void onInit() {
    super.onInit();
    for (final c in [name, address, phone, contactEmail]) {
      c.addListener(update);
    }
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      categories = await _auth.businessCategories();
      cities = await _auth.cities();
      final p = await _data.businessProfile();
      _original = p;
      if (p != null) {
        name.text = p.name;
        address.text = p.address;
        phone.text = p.phone;
        contactEmail.text = p.contactEmail;
        logoUrl = p.logoUrl;
        category = firstWhereOrNull(categories, (o) => o.id == p.categoryId);
        city = firstWhereOrNull(cities, (o) => o.id == p.cityId);
      }
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  void selectCategory(OptionModel v) {
    category = v;
    update();
  }

  void selectCity(OptionModel v) {
    city = v;
    update();
  }

  bool get hasContact => phone.text.trim().isNotEmpty || contactEmail.text.trim().isNotEmpty;
  String? get categoryError => submitted && category == null ? 'fieldRequired'.tr : null;
  String? get cityError => submitted && city == null ? 'fieldRequired'.tr : null;
  String? get contactError => submitted && !hasContact ? 'contactRequired'.tr : null;

  BusinessProfileModel get _current => BusinessProfileModel(
        name: name.text.trim(),
        categoryId: category?.id ?? '',
        cityId: city?.id ?? '',
        address: address.text.trim(),
        phone: phone.text.replaceAll(' ', ''),
        contactEmail: contactEmail.text.trim(),
        logoUrl: logoUrl,
      );

  bool get changed {
    final o = _original, c = _current;
    if (o == null) return true;
    return o.name != c.name ||
        o.categoryId != c.categoryId ||
        o.cityId != c.cityId ||
        o.address != c.address ||
        o.phone != c.phone ||
        o.contactEmail != c.contactEmail ||
        o.logoUrl != c.logoUrl;
  }

  bool get requiredFilled => name.text.trim().isNotEmpty && category != null && city != null;
  bool get canSave => requiredFilled && changed && !saving && !logoUploading;

  Future<void> save() async {
    submitted = true;
    final fieldsValid = formKey.currentState?.validate() ?? false;
    update();
    if (!fieldsValid || !requiredFilled || !hasContact) return;

    saving = true;
    update();
    try {
      _original = await _data.saveBusinessProfile(_current);
      saving = false;
      Get.back();
      showMessage('profileSaved'.tr);
      return;
    } catch (_) {
      showMessage('errorGeneric'.tr);
    }
    saving = false;
    update();
  }

  /// نفس تحقق A7 للهاتف والبريد.
  String? validatePhone(String? v) => ValidInput.optionalPhone(v);
  String? validateEmail(String? v) => ValidInput.optionalEmail(v);

  @override
  void onClose() {
    for (final c in [name, address, phone, contactEmail]) {
      c.dispose();
    }
    super.onClose();
  }
}
