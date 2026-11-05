import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/pick_image.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/media_data.dart';
import '../../data/datasource/supplier_data.dart';
import '../../data/model/option_model.dart';
import '../../data/model/picked_image.dart';
import '../../data/model/product_draft.dart';
import '../../data/model/product_model.dart';

/// صورة في النموذج: مرفوعة (لها رابط) أو جارٍ رفعها (لها نسبة تقدّم).
/// [preview] هي الصورة التي اختارها المستخدم، تظهر فوراً قبل اكتمال الرفع.
class FormImage {
  FormImage({this.url, this.preview, this.progress = 0});

  String? url;
  final Uint8List? preview;
  double progress;

  bool get uploading => url == null;
}

/// C8 إضافة منتج، C9 تعديل منتج (FR-16 إلى FR-20).
/// [productId] فارغ ← إضافة.
///
/// القاعدة كبقية النماذج: الأزرار معطّلة حتى تُملأ الحقول المطلوبة،
/// والأخطاء التفصيلية تظهر بعد أول ضغطة حفظ فقط.
/// النشر يحتاج صورة واحدة على الأقل، ولا يتاح أثناء رفع صورة.
class ProductFormController extends GetxController {
  ProductFormController(this.productId);

  final String? productId;
  final SupplierData _data = Get.find();
  final MediaData _media = Get.find();

  static const int maxImages = 5;
  static const int maxDescription = 600;

  StatusRequest status = StatusRequest.none;
  List<OptionModel> categories = [];

  final name = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();
  final moq = TextEditingController();

  String? categoryId;
  Currency currency = Currency.usd;

  /// في التعديل فقط: منشور أم موقوف.
  bool active = true;
  final List<FormImage> images = [];

  bool submitted = false;
  bool saving = false;

  bool get isEdit => productId != null;

  @override
  void onInit() {
    super.onInit();
    for (final c in [name, price, stock, moq]) {
      c.addListener(update);
    }
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      categories = await _data.categories();
      if (isEdit) {
        final p = await _data.myProduct(productId!);
        name.text = p.name;
        description.text = p.description;
        price.text = _plain(p.price);
        stock.text = '${p.stock}';
        moq.text = p.moq > 1 ? '${p.moq}' : '';
        categoryId = p.categoryId;
        currency = p.currency;
        active = p.active;
        images
          ..clear()
          ..addAll(p.imageUrls.map((u) => FormImage(url: u, progress: 1)));
      }
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  static String _plain(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  // ─── الصور ───

  bool get uploading => images.any((i) => i.uploading);
  bool get canAddImage => images.length < maxImages;

  /// يفتح المعرض أو الكاميرا، ويرفع كل صورة مختارة (حتى يكتمل العدد 5).
  /// الصور تظهر فوراً، والرفع يجري لكل واحدة على حدة.
  Future<void> addImage() async {
    if (!canAddImage) return;
    final picked = await pickImages(max: maxImages - images.length);
    for (final p in picked) {
      final img = FormImage(preview: p.bytes);
      images.add(img);
      _upload(img, p);
    }
    update();
  }

  Future<void> _upload(FormImage img, PickedImage picked) async {
    try {
      img.url = await _media.uploadImage(picked, onProgress: (p) {
        img.progress = p;
        update();
      });
    } catch (_) {
      images.remove(img);
      showMessage('imageUploadFailed'.tr);
    }
    update();
  }

  void removeImage(FormImage img) {
    images.remove(img);
    update();
  }

  void makeCover(FormImage img) {
    images
      ..remove(img)
      ..insert(0, img);
    update();
  }

  // ─── الحقول ───

  void setCategory(String? id) {
    categoryId = id;
    update();
  }

  void setCurrency(Currency c) {
    currency = c;
    update();
  }

  void setActive(bool v) {
    active = v;
    update();
  }

  /// كل الحقول المطلوبة مكتوبة (بلا فحص صحتها بعد).
  bool get requiredFilled =>
      name.text.trim().isNotEmpty &&
      categoryId != null &&
      price.text.trim().isNotEmpty &&
      stock.text.trim().isNotEmpty;

  bool get canSave => requiredFilled && !uploading && !saving;
  bool get canPublish => canSave && images.isNotEmpty;

  String? get nameError {
    if (!submitted) return null;
    return name.text.trim().length < 3 ? 'productNameShort'.tr : null;
  }

  String? get priceError {
    if (!submitted) return null;
    final v = double.tryParse(price.text.trim());
    return v == null || v <= 0 ? 'priceInvalid'.tr : null;
  }

  String? get stockError {
    if (!submitted) return null;
    final v = int.tryParse(stock.text.trim());
    return v == null || v < 0 ? 'stockInvalid'.tr : null;
  }

  String? get moqError {
    if (!submitted || moq.text.trim().isEmpty) return null;
    final v = int.tryParse(moq.text.trim());
    return v == null || v < 1 ? 'moqInvalid'.tr : null;
  }

  bool get _valid => nameError == null && priceError == null && stockError == null && moqError == null;

  /// C8: "نشر المنتج" (publish = true) أو "حفظ كموقوف". C9: "حفظ التعديلات".
  Future<void> save({bool? publish}) async {
    submitted = true;
    update();
    if (!canSave || !_valid) return;
    final willBeActive = publish ?? active;
    if (willBeActive && images.isEmpty) {
      showMessage('needImageToPublish'.tr);
      return;
    }

    saving = true;
    update();
    try {
      await _data.saveProduct(ProductDraft(
        id: productId,
        name: name.text.trim(),
        description: description.text.trim(),
        categoryId: categoryId!,
        price: double.parse(price.text.trim()),
        currency: currency,
        stock: int.parse(stock.text.trim()),
        moq: int.tryParse(moq.text.trim()) ?? 1,
        active: willBeActive,
        imageUrls: [for (final i in images) i.url!],
      ));
      saving = false;
      Get.back();
      showMessage(isEdit
          ? 'productSaved'.tr
          : (willBeActive ? 'productPublished'.tr : 'productSavedPaused'.tr));
    } catch (_) {
      saving = false;
      update();
      showMessage('errorGeneric'.tr);
    }
  }

  @override
  void onClose() {
    for (final c in [name, description, price, stock, moq]) {
      c.dispose();
    }
    super.onClose();
  }
}
