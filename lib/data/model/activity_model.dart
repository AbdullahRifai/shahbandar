/// تصنيف السجل، لفلاتر "الطلبات" و"الحساب".
enum ActivityType { order, account }

/// أيقونة كل حدث.
enum ActivityIcon { order, cart, cancel, login, profile, password, role, product, delete }

/// حدث في سجل النشاط (FR-59). للعرض فقط، ولا يُعدَّل.
class ActivityEntry {
  const ActivityEntry({
    required this.type,
    required this.icon,
    required this.textKey,
    required this.at,
    this.params = const {},
  });

  final ActivityType type;
  final ActivityIcon icon;
  final String textKey;
  final Map<String, String> params;
  final DateTime at;
}

/// طلب حذف الحساب (FR-60). يراجعه الأدمن، ويبقى الحساب يعمل حتى الموافقة.
class DeletionRequest {
  const DeletionRequest({required this.createdAt, this.reason = ''});

  final DateTime createdAt;
  final String reason;
}
