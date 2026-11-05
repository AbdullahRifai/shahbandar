import 'package:get/get.dart';

/// عنصر قائمة اختيار (نوع النشاط، المدينة...) باللغتين.
class OptionModel {
  const OptionModel({required this.id, required this.ar, required this.en});

  final String id;
  final String ar;
  final String en;

  /// الاسم بلغة الواجهة الحالية.
  String get label => Get.locale?.languageCode == 'en' ? en : ar;

  @override
  bool operator ==(Object other) => other is OptionModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
