/// رفض في عمليات الكتالوج والطلبات.
enum RequestFailureType { offline, notFound, notAllowed, unknown }

/// تُرمى من مصادر البيانات (الوهمية الآن، والخادم لاحقاً).
class RequestFailure implements Exception {
  const RequestFailure(this.type);

  final RequestFailureType type;
}
