import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/account_type_controller.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/info_note.dart';
import '../../../data/model/user_model.dart';
import '../../widget/auth/auth_body.dart';
import '../../widget/auth/auth_title.dart';
import '../../widget/auth/auth_top_bar.dart';
import '../../widget/auth/role_option_card.dart';
import '../../widget/auth/steps_indicator.dart';

/// A6 اختيار الأدوار: المرحلة 3 من 4.
/// خانتا اختيار لا ثلاثة خيارات، لأن "الاثنين معاً" جمع للخيارين.
class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthTopBar(title: 'createAccountBar'.tr, showBack: false),
            const StepsIndicator(current: 2),
            Expanded(
              child: GetBuilder<AccountTypeController>(
                builder: (c) => AuthBody(
                  top: 32,
                  children: [
                    AuthTitle(title: 'rolesTitle'.tr, subtitle: 'rolesSubtitle'.tr),
                    const SizedBox(height: 24),
                    RoleOptionCard(
                      title: 'roleTraderTitle'.tr,
                      description: 'roleTraderBody'.tr,
                      icon: Icons.shopping_cart_outlined,
                      selected: c.selected.contains(UserRole.trader),
                      onTap: () => c.toggle(UserRole.trader),
                    ),
                    const SizedBox(height: 12),
                    RoleOptionCard(
                      title: 'roleSupplierTitle'.tr,
                      description: 'roleSupplierBody'.tr,
                      icon: Icons.storefront_outlined,
                      selected: c.selected.contains(UserRole.supplier),
                      onTap: () => c.toggle(UserRole.supplier),
                    ),
                    const SizedBox(height: 16),
                    InfoNote(text: 'rolesNote'.tr),
                  ],
                  bottom: [
                    AppButton(
                      label: 'continueToProfile'.tr,
                      isLoading: c.isLoading,
                      onPressed: c.canContinue ? c.continueToProfile : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
