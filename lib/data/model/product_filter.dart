import 'product_model.dart';

/// خيارات الترتيب (FR-29).
enum ProductSort { newest, priceAsc, priceDesc, name }

/// معايير البحث والفلترة مجتمعة (FR-26 إلى FR-28).
class ProductFilter {
  const ProductFilter({
    this.query = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.priceCurrency = Currency.usd,
    this.availableOnly = false,
    this.sort = ProductSort.newest,
  });

  final String query;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;

  /// نطاق السعر بعملة واحدة، لأن الأسعار لا تُحوَّل.
  final Currency priceCurrency;
  final bool availableOnly;
  final ProductSort sort;

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// عدد الفلاتر المفعّلة (بدون البحث والترتيب).
  int get activeCount =>
      (categoryId != null ? 1 : 0) + (hasPriceRange ? 1 : 0) + (availableOnly ? 1 : 0);

  ProductFilter copyWith({
    String? query,
    String? Function()? categoryId,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    Currency? priceCurrency,
    bool? availableOnly,
    ProductSort? sort,
  }) {
    return ProductFilter(
      query: query ?? this.query,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      availableOnly: availableOnly ?? this.availableOnly,
      sort: sort ?? this.sort,
    );
  }

  /// يبقي البحث والترتيب ويمسح الفلاتر.
  ProductFilter cleared() => ProductFilter(query: query, sort: sort);
}
