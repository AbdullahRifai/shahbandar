/// الملف التجاري (FR-11 إلى FR-14).
class BusinessProfileModel {
  const BusinessProfileModel({
    required this.name,
    required this.categoryId,
    required this.cityId,
    this.address = '',
    this.phone = '',
    this.contactEmail = '',
    this.logoUrl = '',
  });

  final String name;

  /// من قائمة الأنشطة المعتمدة فقط، لا يُنشئ المستخدم نوعاً جديداً (FR-14).
  final String categoryId;
  final String cityId;
  final String address;

  /// رقم الهاتف بدون +963.
  final String phone;
  final String contactEmail;

  /// شعار النشاط بعد رفعه. فارغ = بلا شعار (يظهر أول حرف من الاسم).
  final String logoUrl;

  /// وسيلة تواصل واحدة على الأقل (FR-13).
  bool get hasContact => phone.isNotEmpty || contactEmail.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'categoryId': categoryId,
        'cityId': cityId,
        'address': address,
        'phone': phone.isEmpty ? null : '+963$phone',
        'contactEmail': contactEmail.isEmpty ? null : contactEmail,
        'logoUrl': logoUrl.isEmpty ? null : logoUrl,
      };
}
