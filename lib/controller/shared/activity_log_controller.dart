import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../data/datasource/account_data.dart';
import '../../data/model/activity_model.dart';

enum ActivityFilter { all, orders, account }

/// D5 — سجل نشاطي (FR-59): للعرض فقط، مجمّع حسب اليوم.
class ActivityLogController extends GetxController {
  final AccountData _data = Get.find();

  StatusRequest status = StatusRequest.none;
  List<ActivityEntry> entries = [];
  ActivityFilter filter = ActivityFilter.all;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    status = StatusRequest.loading;
    update();
    try {
      entries = await _data.activity();
      status = StatusRequest.success;
    } catch (_) {
      status = StatusRequest.failure;
    }
    update();
  }

  void setFilter(ActivityFilter f) {
    filter = f;
    update();
  }

  /// مجموعات بالترتيب من الأحدث، ومفتاح كل مجموعة بداية يومها.
  Map<DateTime, List<ActivityEntry>> get grouped {
    final list = entries.where((e) => switch (filter) {
          ActivityFilter.all => true,
          ActivityFilter.orders => e.type == ActivityType.order,
          ActivityFilter.account => e.type == ActivityType.account,
        }).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    final result = <DateTime, List<ActivityEntry>>{};
    for (final e in list) {
      result.putIfAbsent(DateTime(e.at.year, e.at.month, e.at.day), () => []).add(e);
    }
    return result;
  }
}
