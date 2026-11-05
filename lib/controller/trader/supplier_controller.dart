import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/show_message.dart';
import '../../data/datasource/catalog_data.dart';
import '../../data/model/product_model.dart';
import '../../data/model/supplier_model.dart';

/// B7 — صفحة المورد (FR-32): بياناته ومنتجاته النشطة.
class SupplierController extends GetxController {
  SupplierController(this.supplierId);

  final String supplierId;
  final CatalogData _catalog = Get.find();

  StatusRequest status = StatusRequest.none;
  SupplierModel? supplier;
  List<ProductModel> products = [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      final results = await Future.wait([
        _catalog.supplier(supplierId),
        _catalog.supplierProducts(supplierId),
      ]);
      supplier = results[0] as SupplierModel;
      products = results[1] as List<ProductModel>;
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  /// لا اتصال داخل التطبيق في النسخة الأولى: ننسخ الرقم أو البريد ليستخدمه التاجر.
  Future<void> copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    showMessage('copied'.tr);
  }
}
