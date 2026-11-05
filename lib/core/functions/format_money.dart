import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/model/product_model.dart';

final NumberFormat _usd = NumberFormat('#,##0.00', 'en');
final NumberFormat _syp = NumberFormat('#,##0', 'en');

bool get _isArabic => Get.locale?.languageCode != 'en';

/// المبلغ مع عملته. الأرقام لاتينية دائماً لتسهل قراءة الأسعار.
///   دولار:  $1,214.00 (معزول باتجاه LTR حتى لا تنقلب العلامة داخل النص العربي)
///   ليرة:   6,125,000 ل.س  |  SYP 6,125,000
String formatMoney(double amount, Currency currency) {
  return switch (currency) {
    Currency.usd => '⁦\$${_usd.format(amount)}⁩',
    Currency.syp => _isArabic ? '${_syp.format(amount)} ل.س' : 'SYP ${_syp.format(amount)}',
  };
}

/// اسم العملة للعرض في الفلاتر والأزرار.
String currencyName(Currency currency) =>
    currency == Currency.usd ? 'currencyUsd'.tr : 'currencySyp'.tr;

/// عدد صحيح بفواصل الآلاف: 1,250
String formatCount(int value) => _syp.format(value);

const _monthsAr = [
  'كانون الثاني', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران',
  'تموز', 'آب', 'أيلول', 'تشرين الأول', 'تشرين الثاني', 'كانون الأول',
];
const _monthsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// 22 تشرين الأول 2026  |  22 Oct 2026
String formatDate(DateTime d) =>
    '${d.day} ${(_isArabic ? _monthsAr : _monthsEn)[d.month - 1]} ${d.year}';

/// 22 تشرين الأول 2026، 10:30
String formatDateTime(DateTime d) {
  final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  return '${formatDate(d)}${_isArabic ? '،' : ','} $time';
}

/// منذ متى: "قبل 10 د"، "قبل 2 س"، وبعد يوم التاريخ.
String formatAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'agoNow'.tr;
  if (diff.inMinutes < 60) return 'agoMin'.trParams({'n': '${diff.inMinutes}'});
  if (diff.inHours < 24) return 'agoHour'.trParams({'n': '${diff.inHours}'});
  return formatDate(d);
}
