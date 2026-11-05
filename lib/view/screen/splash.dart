import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/splash_controller.dart';
import '../../core/constant/app_color.dart';
import '../widget/splash/splash_logo.dart';

/// A1 شاشة البداية: ترسم الشعار فقط، والقرار في SplashController.
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.ink,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColor.ink,
        // خارج SafeArea عن قصد: نفس مركز شاشة النظام تماماً.
        body: Center(child: SplashLogo()),
      ),
    );
  }
}
