import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_color.dart';
import 'app_button.dart';

/// مؤشر تحميل في منتصف المساحة.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColor.ink, strokeWidth: 2.5),
        ),
      );
}

/// حالة فارغة أو خطأ: أيقونة في دائرة، عنوان، شرح، وإجراء اختياري.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColor.note, shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: AppColor.textNote),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColor.textSecondary, fontSize: 15, height: 1.55),
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: 220,
                  child: AppButton(
                    label: actionLabel!,
                    style: AppButtonStyle.secondary,
                    onPressed: onAction,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// تعذّر التحميل، مع زر إعادة المحاولة.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) => EmptyView(
        icon: Icons.wifi_off_rounded,
        title: 'loadFailed'.tr,
        message: message ?? 'errorOffline'.tr,
        actionLabel: 'retry'.tr,
        onAction: onRetry,
      );
}
