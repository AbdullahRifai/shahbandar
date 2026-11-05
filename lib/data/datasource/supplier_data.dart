import '../model/incoming_order_model.dart';
import '../model/option_model.dart';
import '../model/product_draft.dart';
import '../model/product_model.dart';

/// العقد لكل ما يفعله المورد: الطلبات الواردة ومنتجاته.
/// الآن MockSupplierData، ولاحقاً RemoteSupplierData بنفس الدوال.
/// عند الفشل تُرمى RequestFailure، وعند نقص المخزون AcceptFailure.
abstract class SupplierData {
  /// C1
  Future<SupplierDashboard> dashboard();

  /// C2: كل طلبات المورد.
  Future<List<IncomingOrder>> orders();

  /// C3 / C6: الطلب مع المخزون الحالي لكل صنف.
  Future<IncomingOrder> order(String id);

  /// FR-46، FR-47: يتحقق من المخزون ويخصمه مرة واحدة، أو يرمي AcceptFailure.
  Future<IncomingOrder> accept(String id);

  /// FR-48: السبب اختياري.
  Future<IncomingOrder> reject(String id, {String? reason});

  /// FR-49: مقبول ← قيد التجهيز ← مكتمل.
  Future<IncomingOrder> advance(String id);

  /// C7: كل منتجات المورد، المنشورة والموقوفة.
  Future<List<ProductModel>> myProducts();
  Future<ProductModel> myProduct(String id);

  /// C8 / C9 (FR-16 إلى FR-20)
  Future<ProductModel> saveProduct(ProductDraft draft);

  /// نشر أو إيقاف (FR-22)
  Future<ProductModel> setActive(String productId, bool active);

  Future<List<OptionModel>> categories();

  // رفع الصور في MediaData (data/datasource/media_data.dart).
}
