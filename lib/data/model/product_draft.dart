import 'product_model.dart';

/// ما يكتبه المورد في نموذج المنتج (C8 إضافة، C9 تعديل). [id] فارغ ← منتج جديد.
class ProductDraft {
  const ProductDraft({
    this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.currency,
    required this.stock,
    required this.moq,
    required this.active,
    required this.imageUrls,
  });

  final String? id;
  final String name;
  final String description;
  final String categoryId;
  final double price;
  final Currency currency;
  final int stock;

  /// الحد الأدنى للطلب، 1 إن تُرك فارغاً.
  final int moq;

  /// منشور أم موقوف (FR-22).
  final bool active;

  /// الصورة الأولى هي الغلاف.
  final List<String> imageUrls;

  bool get isNew => id == null;
}
