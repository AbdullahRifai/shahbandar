/// أول عنصر يحقق الشرط، أو null إن لم يوجد.
/// مكتوبة هنا بدل الاعتماد على امتداد من مكتبة خارجية قد يتعارض اسمه.
T? firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
