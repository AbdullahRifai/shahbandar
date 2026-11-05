/// حالة الحساب (FR-9).
enum AccountStatus { active, disabled }

/// الأدوار داخل تطبيق الهاتف (FR-10). الأدمن في لوحة الويب فقط.
enum UserRole { trader, supplier }

/// بيانات المستخدم التي نحتاجها لتوجيهه بين الشاشات.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.emailVerified = false,
    this.status = AccountStatus.active,
    this.roles = const {},
    this.lastMode,
    this.hasBusinessProfile = false,
  });

  final String id;
  final String email;
  final bool emailVerified;
  final AccountStatus status;
  final Set<UserRole> roles;
  final UserRole? lastMode;

  /// هل أكمل الملف التجاري (A7)؟
  final bool hasBusinessProfile;

  bool get isDisabled => status == AccountStatus.disabled;
  bool get hasNoRole => roles.isEmpty;

  /// دور واحد ← هو. الدوران ← آخر وضع استخدمه، وإلا التاجر.
  UserRole get homeRole {
    if (roles.length == 1) return roles.first;
    if (lastMode != null && roles.contains(lastMode)) return lastMode!;
    return UserRole.trader;
  }

  UserModel copyWith({
    bool? emailVerified,
    AccountStatus? status,
    Set<UserRole>? roles,
    UserRole? lastMode,
    bool? hasBusinessProfile,
  }) {
    return UserModel(
      id: id,
      email: email,
      emailVerified: emailVerified ?? this.emailVerified,
      status: status ?? this.status,
      roles: roles ?? this.roles,
      lastMode: lastMode ?? this.lastMode,
      hasBusinessProfile: hasBusinessProfile ?? this.hasBusinessProfile,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    return UserModel(
      id: '${json['id']}',
      email: '${json['email'] ?? ''}',
      emailVerified: json['emailVerified'] == true,
      status: json['status'] == 'disabled'
          ? AccountStatus.disabled
          : AccountStatus.active,
      roles: {
        if (rawRoles is List)
          for (final r in rawRoles)
            if (_roleFrom(r) case final role?) role,
      },
      lastMode: _roleFrom(json['lastMode']),
      hasBusinessProfile: json['hasBusinessProfile'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'emailVerified': emailVerified,
        'status': status.name,
        'roles': [for (final r in roles) r.name],
        'lastMode': lastMode?.name,
        'hasBusinessProfile': hasBusinessProfile,
      };

  static UserRole? _roleFrom(Object? value) => switch (value) {
        'trader' => UserRole.trader,
        'supplier' => UserRole.supplier,
        _ => null,
      };
}
