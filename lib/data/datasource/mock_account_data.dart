import 'package:get/get.dart';

import '../../core/services/session_service.dart';
import '../model/activity_model.dart';
import '../model/business_profile_model.dart';
import '../model/notification_model.dart';
import '../model/user_model.dart';
import 'account_data.dart';
import 'auth_data.dart';

/// بيانات وهمية للواجهات المشتركة، في الذاكرة.
///
/// الإشعارات والسجل لا تُكتب يدوياً فقط: البيانات الوهمية الأخرى تضيف إليها
/// حين يحدث شيء (إرسال طلب، قبول، رفض، تغيّر سعر...) عبر [notify] و[log].
/// عند ربط الخادم يصنعها الخادم نفسه، وتختفي هذه الدالتان.
class MockAccountData implements AccountData {
  /// الملفات التجارية حسب البريد. يكتب فيها أيضاً MockAuthData عند إكمال A7.
  static final Map<String, BusinessProfileModel> profiles = {
    'trader@shahbandar.test': const BusinessProfileModel(
      name: 'متجر الياسمين للمواد الغذائية',
      categoryId: 'grocery',
      cityId: 'damascus',
      address: 'المزة، شارع الجلاء',
      phone: '944123456',
      contactEmail: 'yasmeen.store@example.com',
    ),
    'supplier@shahbandar.test': const BusinessProfileModel(
      name: 'شركة الأفق للمواد الغذائية',
      categoryId: 'wholesale',
      cityId: 'damascus',
      address: 'المنطقة الصناعية، القدم',
      phone: '944120300',
      contactEmail: 'sales@alofuq.example',
    ),
    'both@shahbandar.test': const BusinessProfileModel(
      name: 'مؤسسة النخيل التجارية',
      categoryId: 'wholesale',
      cityId: 'latakia',
      contactEmail: 'both@shahbandar.test',
    ),
  };

  /// المورد الذي تصله طلبات "الأفق" في البيانات الوهمية.
  static const String ofuqEmail = 'supplier@shahbandar.test';

  final List<AppNotification> _notifications = _seedNotifications();
  final Map<String, List<ActivityEntry>> _activity = {};
  final Map<String, DeletionRequest> _deletions = {};
  int _ids = 100;

  SessionService get _session => Get.find();
  AuthData get _auth => Get.find();
  String get _email => _session.currentUser?.email ?? '';

  /// إشعارات التاجر مشتركة (لأن طلبات التاجر الوهمية مشتركة)،
  /// وإشعارات المورد لحساب "الأفق" فقط.
  bool _visible(AppNotification n, UserRole role) =>
      n.role == role && (role == UserRole.trader || _email == ofuqEmail);

  // ─── يُستدعى من البيانات الوهمية الأخرى ───

  void notify({
    required UserRole role,
    required NotificationKind kind,
    required String titleKey,
    required String bodyKey,
    Map<String, String> params = const {},
    NotificationTarget target = NotificationTarget.none,
    String? targetId,
  }) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'n${_ids++}',
        role: role,
        kind: kind,
        titleKey: titleKey,
        bodyKey: bodyKey,
        params: params,
        createdAt: DateTime.now(),
        target: target,
        targetId: targetId,
      ),
    );
  }

  void log(ActivityType type, ActivityIcon icon, String textKey, [Map<String, String> params = const {}]) {
    _entries().insert(0, ActivityEntry(type: type, icon: icon, textKey: textKey, params: params, at: DateTime.now()));
  }

  // ─── D1 الإشعارات ───

  @override
  Future<List<AppNotification>> notifications(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _notifications.where((n) => _visible(n, role)).toList();
  }

  @override
  Future<int> unreadCount(UserRole role) async =>
      _notifications.where((n) => _visible(n, role) && !n.read).length;

  @override
  Future<void> markRead(String id) async {
    for (final n in _notifications) {
      if (n.id == id) n.read = true;
    }
  }

  @override
  Future<void> markAllRead(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final n in _notifications.where((n) => _visible(n, role))) {
      n.read = true;
    }
  }

  // ─── D3 الملف التجاري ───

  @override
  Future<BusinessProfileModel?> businessProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return profiles[_email];
  }

  @override
  Future<BusinessProfileModel> saveBusinessProfile(BusinessProfileModel profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    profiles[_email] = profile;
    log(ActivityType.account, ActivityIcon.profile, 'act_profileEdited');
    return profile;
  }

  // ─── D4 تفعيل دور ───

  @override
  Future<UserModel> activateRole(UserRole role) async {
    final user = _session.currentUser!;
    final updated = await _auth.setRoles(user.email, {...user.roles, role});
    log(ActivityType.account, ActivityIcon.role,
        role == UserRole.supplier ? 'act_supplierActivated' : 'act_traderActivated');
    return updated;
  }

  // ─── D5 السجل ───

  @override
  Future<List<ActivityEntry>> activity() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_entries());
  }

  List<ActivityEntry> _entries() => _activity.putIfAbsent(_email, _seedActivity);

  // ─── D7 كلمة المرور ───

  @override
  Future<void> changePassword({required String current, required String newPassword}) async {
    // التحقق من الحالية بنفس منطق الدخول: يرمي invalidCredentials إن كانت خاطئة.
    await _auth.login(email: _email, password: current);
    await _auth.resetPassword(email: _email, newPassword: newPassword);
    log(ActivityType.account, ActivityIcon.password, 'act_passwordChanged');
  }

  // ─── D6 طلب الحذف ───

  @override
  Future<DeletionRequest?> deletionRequest() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _deletions[_email];
  }

  @override
  Future<DeletionRequest> requestDeletion(String reason) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final r = DeletionRequest(createdAt: DateTime.now(), reason: reason);
    _deletions[_email] = r;
    log(ActivityType.account, ActivityIcon.delete, 'act_deletionRequested');
    return r;
  }

  @override
  Future<void> cancelDeletion() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _deletions.remove(_email);
    log(ActivityType.account, ActivityIcon.delete, 'act_deletionCancelled');
  }

  // ─── البيانات الجاهزة ───

  List<ActivityEntry> _seedActivity() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSupplier = _session.currentUser?.homeRole == UserRole.supplier;
    ActivityEntry e(ActivityType t, ActivityIcon i, String key, DateTime at, [Map<String, String> p = const {}]) =>
        ActivityEntry(type: t, icon: i, textKey: key, at: at, params: p);

    return [
      e(ActivityType.account, ActivityIcon.login, 'act_login', today.add(const Duration(hours: 8, minutes: 50))),
      if (isSupplier) ...[
        e(ActivityType.order, ActivityIcon.order, 'act_advanced', today.subtract(const Duration(hours: 6)),
            {'n': '1039-B'}),
        e(ActivityType.account, ActivityIcon.product, 'act_productSaved',
            today.subtract(const Duration(hours: 7)), {'name': 'طحينة سمسم، عبوة 1 كغ'}),
        e(ActivityType.order, ActivityIcon.order, 'act_accepted', today.subtract(const Duration(hours: 14)),
            {'n': '1041-A'}),
      ] else ...[
        e(ActivityType.order, ActivityIcon.cart, 'act_addedToCart', today.subtract(const Duration(hours: 5)),
            {'name': 'مناديل ورقية'}),
        e(ActivityType.account, ActivityIcon.profile, 'act_profileEdited',
            today.subtract(const Duration(hours: 5, minutes: 30))),
        e(ActivityType.order, ActivityIcon.cancel, 'act_orderCancelled', DateTime(2026, 10, 15, 10, 20),
            {'n': '1031-B'}),
        e(ActivityType.order, ActivityIcon.order, 'act_orderSent', DateTime(2026, 10, 15, 9, 10),
            {'n': '1031', 'k': '2'}),
      ],
      e(ActivityType.account, ActivityIcon.password, 'act_passwordChanged', DateTime(2026, 10, 10, 9, 41)),
    ];
  }

  static List<AppNotification> _seedNotifications() {
    final now = DateTime.now();
    var i = 0;
    AppNotification n(
      UserRole role,
      NotificationKind kind,
      String title,
      String body,
      Duration ago, {
      Map<String, String> p = const {},
      NotificationTarget target = NotificationTarget.none,
      String? id,
      bool read = true,
    }) =>
        AppNotification(
          id: 's${i++}',
          role: role,
          kind: kind,
          titleKey: title,
          bodyKey: body,
          params: p,
          createdAt: now.subtract(ago),
          target: target,
          targetId: id,
          read: read,
        );

    const t = UserRole.trader, s = UserRole.supplier;
    return [
      // التاجر
      n(t, NotificationKind.priceChanged, 'n_priceTitle', 'n_priceBody', const Duration(hours: 3),
          p: {'name': 'المعكرونة', 'old': '\$14.20', 'new': '\$14.80'}, target: NotificationTarget.cart, read: false),
      n(t, NotificationKind.rejected, 'n_rejectedTitle', 'n_rejectedBody', const Duration(days: 1, hours: 2),
          p: {'s': 'مؤسسة النور', 'n': '1031-A', 'r': 'الكمية غير متوفرة حالياً.'},
          target: NotificationTarget.purchase, id: '1031'),
      n(t, NotificationKind.completed, 'n_completedTitle', 'n_completedBody', const Duration(days: 4),
          p: {'s': 'مجموعة الشام', 'n': '1038-A'}, target: NotificationTarget.purchase, id: '1038'),
      n(t, NotificationKind.profile, 'n_profileTitle', 'n_profileBody', const Duration(days: 9),
          target: NotificationTarget.businessProfile),
      // المورد (الأفق)
      n(s, NotificationKind.newOrder, 'n_newOrderTitle', 'n_newOrderBody', const Duration(minutes: 10),
          p: {'t': 'متجر الياسمين', 'n': '1045-A'}, target: NotificationTarget.incomingOrder, id: '1045-A', read: false),
      n(s, NotificationKind.newOrder, 'n_newOrderTitle', 'n_newOrderBody', const Duration(minutes: 45),
          p: {'t': 'سوبرماركت الرضا', 'n': '1043-C'}, target: NotificationTarget.incomingOrder, id: '1043-C', read: false),
      n(s, NotificationKind.newOrder, 'n_newOrderTitle', 'n_newOrderBody', const Duration(hours: 2),
          p: {'t': 'مطعم بيت الشام', 'n': '1044-A'}, target: NotificationTarget.incomingOrder, id: '1044-A'),
      n(s, NotificationKind.cancelled, 'n_outOfStockTitle', 'n_outOfStockBody', const Duration(days: 1, hours: 5),
          p: {'name': 'عدس مجروش، كيس 25 كغ'}, target: NotificationTarget.products),
    ];
  }
}
