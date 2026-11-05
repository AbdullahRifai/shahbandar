import '../../data/model/user_model.dart';
import '../constant/app_routes.dart';

/// إلى أين يذهب المستخدم الآن؟ تستخدمها A1 وA2 وA5 وA6 وA7،
/// فالقاعدة مكتوبة مرة واحدة.
///
/// الترتيب = ترتيب مراحل التسجيل: موقوف ← البريد ← الأدوار ← الملف ← اللوحة.
String homeRouteFor(UserModel user) {
  if (user.isDisabled) return AppRoute.accountDisabled;
  if (!user.emailVerified) return AppRoute.checkEmail;
  if (user.hasNoRole) return AppRoute.accountType;
  if (!user.hasBusinessProfile) return AppRoute.businessSetup;
  return user.homeRole == UserRole.trader ? AppRoute.traderHome : AppRoute.supplierHome;
}
