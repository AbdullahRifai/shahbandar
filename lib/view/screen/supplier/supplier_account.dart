import 'package:flutter/widgets.dart';

import '../../../data/model/user_model.dart';
import '../shared/account.dart';

/// تبويب "حسابي" في لوحة المورد: شاشة D2 المشتركة بوضع المورد.
class SupplierAccountScreen extends StatelessWidget {
  const SupplierAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => const AccountScreen(role: UserRole.supplier);
}
