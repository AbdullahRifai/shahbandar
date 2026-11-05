import '../model/option_model.dart';
import '../model/product_filter.dart';
import '../model/product_model.dart';
import '../model/request_failure.dart';
import '../model/supplier_model.dart';
import 'catalog_data.dart';

/// كتالوج وهمي: 4 موردين و13 منتجاً، ومنتج موقوف لا يظهر أبداً (FR-22).
///
/// منتجات تُظهر حالات خاصة:
///   عدس مجروش، سكر مكعبات ← نفدا من المخزون (يظهران مع شارة، ولا يُضافان للسلة)
///   معكرونة ← يتغير سعرها عند فتح السلة (B9: تنبيه تغيّر السعر)
///   رز بسمتي ← ينخفض مخزونه عند التحقق قبل الطلب (B10: صنف غير صالح)
class MockCatalogData implements CatalogData {
  static const Duration _latency = Duration(milliseconds: 400);

  /// المنتجات قابلة للتعديل، لأن السلة تحاكي تغيّر السعر والمخزون.
  final Map<String, ProductModel> products = {for (final p in _products) p.id: p};

  @override
  Future<List<OptionModel>> categories() async {
    await Future<void>.delayed(_latency);
    return _categories;
  }

  @override
  Future<List<ProductModel>> search(ProductFilter filter) async {
    await Future<void>.delayed(_latency);
    return applyFilter(products.values, filter);
  }

  /// منطق الفلترة نفسه متاح دون انتظار، حتى تعرض نافذة الفلترة عدد النتائج مباشرة.
  static List<ProductModel> applyFilter(Iterable<ProductModel> source, ProductFilter f) {
    final q = _normalize(f.query.trim());
    final list = source.where((p) {
      if (!p.active) return false;
      if (q.isNotEmpty && !_normalize(p.name).contains(q)) return false;
      if (f.categoryId != null && p.categoryId != f.categoryId) return false;
      if (f.availableOnly && !p.inStock) return false;
      if (f.hasPriceRange) {
        if (p.currency != f.priceCurrency) return false;
        if (f.minPrice != null && p.price < f.minPrice!) return false;
        if (f.maxPrice != null && p.price > f.maxPrice!) return false;
      }
      return true;
    }).toList();

    int byCurrency(ProductModel a, ProductModel b) => a.currency.index - b.currency.index;
    switch (f.sort) {
      case ProductSort.newest:
        list.sort((a, b) => b.addedOrder - a.addedOrder);
      // الترتيب بالسعر: الدولار أولاً ثم الليرة، كلٌّ وحده.
      case ProductSort.priceAsc:
        list.sort((a, b) => byCurrency(a, b) != 0 ? byCurrency(a, b) : a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        list.sort((a, b) => byCurrency(a, b) != 0 ? byCurrency(a, b) : b.price.compareTo(a.price));
      case ProductSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  /// توحيد أشكال الحروف العربية في البحث: أ إ آ ← ا، ة ← ه، ى ← ي.
  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');

  @override
  Future<ProductModel> product(String id) async {
    await Future<void>.delayed(_latency);
    final p = products[id];
    if (p == null || !p.active) throw const RequestFailure(RequestFailureType.notFound);
    return p;
  }

  @override
  Future<SupplierModel> supplier(String id) async {
    await Future<void>.delayed(_latency);
    final s = _suppliers[id];
    if (s == null) throw const RequestFailure(RequestFailureType.notFound);
    return s;
  }

  @override
  Future<List<ProductModel>> supplierProducts(String supplierId) async {
    await Future<void>.delayed(_latency);
    final list = products.values.where((p) => p.active && p.supplierId == supplierId).toList()
      ..sort((a, b) => (b.inStock ? 1 : 0) - (a.inStock ? 1 : 0));
    return list;
  }

  /// بيانات مورد دون انتظار (للوحة المورد الوهمية).
  static SupplierModel? supplierById(String id) => _suppliers[id];

  // ─── البيانات ───

  static const _categories = [
    OptionModel(id: 'food', ar: 'مواد غذائية', en: 'Groceries'),
    OptionModel(id: 'paper', ar: 'ورقيات', en: 'Paper goods'),
    OptionModel(id: 'packaging', ar: 'تغليف', en: 'Packaging'),
    OptionModel(id: 'cleaning', ar: 'منظفات', en: 'Cleaning'),
  ];

  static const _suppliers = {
    'ofuq': SupplierModel(
      id: 'ofuq',
      name: 'شركة الأفق للمواد الغذائية',
      city: 'دمشق',
      activity: 'مواد غذائية بالجملة',
      about: 'توزيع زيوت وحبوب ومعلبات للمحلات والمطاعم في دمشق وريفها منذ 2015.',
      phone: '+963 944 120 300',
      email: 'sales@alofuq.example',
    ),
    'noor': SupplierModel(
      id: 'noor',
      name: 'مؤسسة النور للتجارة',
      city: 'دمشق',
      activity: 'سكر ومواد تغليف',
      about: 'مستودع مركزي في المنطقة الصناعية، توصيل خلال يومين داخل دمشق.',
      phone: '+963 933 551 210',
      email: 'info@alnoor.example',
    ),
    'sham': SupplierModel(
      id: 'sham',
      name: 'مجموعة الشام للتوريدات',
      city: 'حلب',
      activity: 'توريدات غذائية ومنظفات',
      about: 'نوّرد للمحافظات الشمالية والوسطى بأسعار الجملة.',
      phone: '+963 988 410 777',
      email: 'orders@alsham.example',
    ),
    'waha': SupplierModel(
      id: 'waha',
      name: 'شركة الواحة للورقيات',
      city: 'حمص',
      activity: 'ورقيات ومناديل',
      about: 'مصنع مناديل ومحارم بإنتاج يومي، نبيع بالكرتونة.',
      phone: '+963 955 302 040',
      email: 'sales@alwaha.example',
    ),
    // مورد بلا منتجات، لتجربة "لا منتجات بعد" (C10) بحساب both@shahbandar.test.
    'nakheel': SupplierModel(
      id: 'nakheel',
      name: 'مؤسسة النخيل التجارية',
      city: 'اللاذقية',
      activity: 'مواد غذائية',
      about: '',
    ),
  };

  static ProductModel _p(
    String id,
    String name,
    String cat,
    String sup,
    double price,
    Currency cur,
    int stock,
    int moq,
    String visual,
    int order, {
    String description = '',
    bool active = true,
  }) {
    final s = _suppliers[sup]!;
    return ProductModel(
      id: id,
      name: name,
      description: description,
      categoryId: cat,
      supplierId: sup,
      supplierName: s.name,
      supplierCity: s.city,
      price: price,
      currency: cur,
      stock: stock,
      moq: moq,
      visual: visual,
      active: active,
      addedOrder: order,
    );
  }

  static final List<ProductModel> _products = [
    _p('oil', 'زيت زيتون بكر ممتاز، 5 لتر', 'food', 'ofuq', 38.50, Currency.usd, 340, 20, 'oil', 13,
        description: 'زيت زيتون بكر ممتاز معصور على البارد، حموضة منخفضة. عبوة معدنية 5 لتر.'),
    _p('pasta', 'معكرونة 500 غ، كرتونة 20', 'food', 'ofuq', 14.20, Currency.usd, 120, 30, 'pasta', 12,
        description: 'معكرونة قمح قاسي، 20 كيساً في الكرتونة.'),
    _p('tahini', 'طحينة سمسم، عبوة 1 كغ', 'food', 'ofuq', 9.60, Currency.usd, 240, 24, 'tahini', 11,
        description: 'طحينة سمسم خام 100%، عبوة زجاجية سعة 1 كغ.'),
    _p('lentils', 'عدس مجروش، كيس 25 كغ', 'food', 'ofuq', 22.30, Currency.usd, 0, 10, 'grain', 10,
        description: 'عدس أحمر مجروش، تعبئة محلية.'),
    _p('sugar_noor', 'سكر أبيض ناعم، كيس 50 كغ', 'food', 'noor', 27.00, Currency.usd, 350, 10, 'sugar', 9,
        description: 'سكر أبيض ناعم مكرر، أكياس منسوجة مبطنة. مناسب للمخابز ومحلات الحلويات.'),
    _p('sugar_sham', 'سكر أبيض ناعم، كيس 50 كغ', 'food', 'sham', 28.50, Currency.usd, 500, 10, 'sugar', 8,
        description: 'سكر أبيض مكرر، شحن من حلب خلال 3 أيام.'),
    _p('sugar_brown', 'سكر خشن، كيس 25 كغ', 'food', 'ofuq', 15.20, Currency.usd, 200, 20, 'sugar', 7),
    _p('sugar_cubes', 'سكر مكعبات، كرتونة 24 علبة', 'food', 'noor', 18.00, Currency.usd, 0, 5, 'cubes', 6),
    _p('rice', 'رز بسمتي، كيس 25 كغ', 'food', 'sham', 1150000, Currency.syp, 80, 10, 'rice', 5,
        description: 'رز بسمتي طويل الحبة، أكياس 25 كغ.'),
    _p('tissues', 'مناديل ورقية، كرتونة 48 علبة', 'paper', 'waha', 245000, Currency.syp, 400, 25, 'tissue', 4,
        description: 'مناديل وجه بطبقتين، 48 علبة في الكرتونة.'),
    _p('kitchen_roll', 'محارم مطبخ، كرتونة 12 لفة', 'paper', 'waha', 180000, Currency.syp, 300, 20, 'roll', 3),
    _p('bags', 'أكياس تغليف، 10 كغ', 'packaging', 'noor', 12.00, Currency.usd, 150, 10, 'bag', 2),
    _p('dish_soap', 'سائل جلي، عبوة 4 لتر', 'cleaning', 'sham', 95000, Currency.syp, 220, 24, 'soap', 1),
    _p('old_cans', 'معلبات فول (موقوف)', 'food', 'ofuq', 5.00, Currency.usd, 50, 10, 'box', 0, active: false),
  ];
}
