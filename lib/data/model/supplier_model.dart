/// المورد كما يظهر في صفحته (FR-32).
class SupplierModel {
  const SupplierModel({
    required this.id,
    required this.name,
    required this.city,
    required this.activity,
    required this.about,
    this.phone = '',
    this.email = '',
  });

  final String id;
  final String name;
  final String city;

  /// نوع النشاط، مثل "مواد غذائية بالجملة".
  final String activity;
  final String about;
  final String phone;
  final String email;

  /// الحرف الأول من الاسم بعد كلمة "شركة" أو "مؤسسة" أو "مجموعة"، للشعار المؤقت.
  String get initial {
    final words = name.split(' ');
    const skip = {'شركة', 'مؤسسة', 'مجموعة', 'متجر'};
    final word = words.firstWhere((w) => !skip.contains(w), orElse: () => name);
    final clean = word.startsWith('ال') && word.length > 2 ? word.substring(2) : word;
    return clean.isEmpty ? '?' : String.fromCharCode(clean.runes.first);
  }
}
