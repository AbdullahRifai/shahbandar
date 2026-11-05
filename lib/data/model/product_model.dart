/// العملتان المعتمدتان. كل منتج بعملة يحددها مورده، ولا تحويل بينهما.
enum Currency { usd, syp }

/// منتج كما يراه التاجر (FR-16، FR-17، FR-21).
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.supplierId,
    required this.supplierName,
    required this.supplierCity,
    required this.price,
    required this.currency,
    required this.stock,
    this.moq = 1,
    this.active = true,
    this.visual = 'box',
    this.imageUrls = const [],
    this.addedOrder = 0,
  });

  final String id;

  /// الاسم والوصف بلغة المورد، ولا يُترجمان.
  final String name;
  final String description;
  final String categoryId;
  final String supplierId;
  final String supplierName;
  final String supplierCity;
  final double price;
  final Currency currency;

  /// المخزون المتوفر. صفر = نفد، ويبقى ظاهراً مع شارة (FR-21).
  final int stock;

  /// الحد الأدنى للطلب (FR-17).
  final int moq;

  /// الموقوف لا يظهر في البحث ولا في صفحة المورد (FR-22).
  final bool active;

  /// مفتاح الرسم المؤقت حتى يرفع الموردون صوراً حقيقية.
  final String visual;
  final List<String> imageUrls;

  /// ترتيب الإضافة، للترتيب حسب "الأحدث".
  final int addedOrder;

  /// الصورة الأولى إن رفع المورد صوراً.
  String? get coverImage => imageUrls.isEmpty ? null : imageUrls.first;

  bool get inStock => stock > 0;

  /// هل يمكن طلب الحد الأدنى من المخزون الحالي؟
  bool get orderable => active && stock >= moq;

  ProductModel copyWith({
    String? name,
    String? description,
    String? categoryId,
    double? price,
    Currency? currency,
    int? stock,
    int? moq,
    bool? active,
    List<String>? imageUrls,
  }) =>
      ProductModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        supplierId: supplierId,
        supplierName: supplierName,
        supplierCity: supplierCity,
        price: price ?? this.price,
        currency: currency ?? this.currency,
        stock: stock ?? this.stock,
        moq: moq ?? this.moq,
        active: active ?? this.active,
        visual: visual,
        imageUrls: imageUrls ?? this.imageUrls,
        addedOrder: addedOrder,
      );
}
