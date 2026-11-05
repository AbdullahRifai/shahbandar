import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'admin_routes.dart';
import 'core/constant/app_routes.dart';
import 'core/constant/app_theme.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/translation.dart';
import 'core/services/admin_services.dart';
import 'data/datasource/admin_data.dart';

/// نقطة تشغيل لوحة الإدارة (Flutter Web، وتعمل أيضاً على Windows).
///
///   flutter run -d chrome -t lib/main_admin.dart
///   flutter build web -t lib/main_admin.dart
///
/// نفس المشروع ونفس الألوان والخطوط والترجمات، لكن بمسارات وخدمات خاصة بالإدارة.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialAdminServices();
  final signedIn = await Get.find<AdminData>().restoreSession() != null;
  runApp(ShahbandarAdminApp(initialRoute: signedIn ? AppRoute.adminHome : AppRoute.adminLogin));
}

class ShahbandarAdminApp extends StatelessWidget {
  const ShahbandarAdminApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shahbandar Admin',
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: Get.find<LocaleController>().locale,
      fallbackLocale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      initialRoute: initialRoute,
      getPages: adminRoutes,
    );
  }
}
