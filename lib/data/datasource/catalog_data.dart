import '../model/option_model.dart';
import '../model/product_filter.dart';
import '../model/product_model.dart';
import '../model/supplier_model.dart';

/// العقد لكل ما يتصفحه التاجر: التصنيفات، البحث، المنتج، المورد.
/// الآن MockCatalogData، ولاحقاً RemoteCatalogData بنفس الدوال.
/// عند الفشل تُرمى RequestFailure.
abstract class CatalogData {
  /// تصنيفات المنتجات المفعّلة (FR-23).
  Future<List<OptionModel>> categories();

  /// البحث والفلترة والترتيب معاً (FR-26 إلى FR-29). المنتجات الموقوفة لا تظهر (FR-22).
  Future<List<ProductModel>> search(ProductFilter filter);

  /// FR-30
  Future<ProductModel> product(String id);

  /// FR-32
  Future<SupplierModel> supplier(String id);

  /// منتجات المورد النشطة، المتوفرة أولاً ثم النافدة (FR-32).
  Future<List<ProductModel>> supplierProducts(String supplierId);
}
