import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'core/constant/app_routes.dart';
import 'core/constant/app_theme.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/translation.dart';
import 'core/services/services.dart';
import 'routes.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // تبقى شاشة النظام ظاهرة أثناء تجهيز الخدمات،
  // وتُزال في SplashController بعد ظهور شاشة Flutter المطابقة.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await initialServices();
  runApp(const ShahbandarApp());
}

class ShahbandarApp extends StatelessWidget {
  const ShahbandarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shahbandar',
      debugShowCheckedModeBanner: false,

      // اللغة: الترجمات + اتجاه الواجهة (RTL للعربية تلقائياً).
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
      initialRoute: AppRoute.splash,
      getPages: routes,
    );
  }
}
