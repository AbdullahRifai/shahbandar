import 'package:flutter/widgets.dart';

import '../../../data/model/user_model.dart';
import '../shared/account.dart';

/// تبويب "حسابي" في لوحة التاجر: شاشة D2 المشتركة بوضع التاجر.
class TraderAccountScreen extends StatelessWidget {
  const TraderAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => const AccountScreen(role: UserRole.trader);
}
