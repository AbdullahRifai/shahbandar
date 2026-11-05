import 'user_model.dart';

/// نوع الإشعار، ومنه تُختار الأيقونة واللون.
enum NotificationKind { accepted, preparing, completed, rejected, cancelled, priceChanged, newOrder, profile }

/// أين يذهب المستخدم عند الضغط على الإشعار.
enum NotificationTarget { none, purchase, cart, incomingOrder, products, businessProfile }

/// إشعار داخل التطبيق (FR-56 إلى FR-58).
/// النص مفاتيح ترجمة + قيم، حتى يتبع لغة الواجهة عند تغييرها.
class AppNotification {
  AppNotification({
    required this.id,
    required this.role,
    required this.kind,
    required this.titleKey,
    required this.bodyKey,
    required this.createdAt,
    this.params = const {},
    this.target = NotificationTarget.none,
    this.targetId,
    this.read = false,
  });

  final String id;

  /// لأي وضع يظهر: إشعارات التاجر غير إشعارات المورد.
  final UserRole role;
  final NotificationKind kind;
  final String titleKey;
  final String bodyKey;
  final Map<String, String> params;
  final DateTime createdAt;
  final NotificationTarget target;
  final String? targetId;
  bool read;
}
