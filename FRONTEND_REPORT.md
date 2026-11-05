# تقرير أعمال الواجهة الأمامية — شاهبندر (Shahbandar)

> **مسار المشروع:** `C:\shahbandar`  
> **الحزمة:** `shahbandar` (في `pubspec.yaml`)  
> **التقنية:** Flutter 3.38 · Dart ^3.10.4 · GetX 4.7  
> **تاريخ التقرير:** 4 نوفمبر 2026  
> **الحالة:** كل الواجهات من A إلى E مكتملة على بيانات وهمية (Mock)، جاهزة لاستبدال مصادر البيانات بخادم حقيقي.

---

## فهرس المحتويات

1. [نظرة عامة](#1-نظرة-عامة)
2. [طريقة التشغيل](#2-طريقة-التشغيل)
3. [هيكل المجلدات](#3-هيكل-المجلدات)
4. [المعمارية: كيف تتصل الطبقات](#4-المعمارية-كيف-تتصل-الطبقات)
5. [شرح الأكواد المحورية: لماذا كُتبت هكذا؟](#5-شرح-الأكواد-المحورية-لماذا-كتبت-هكذا)
6. [نظام التصميم](#6-نظام-التصميم)
7. [الرحلات والشاشات](#7-الرحلات-والشاشات)
8. [رفع الصور الحقيقي](#8-رفع-الصور-الحقيقي)
9. [تغيير الاسم إلى شاهبندر والشعار](#9-تغيير-الاسم-إلى-شاهبندر-والشعار)
10. [حسابات وسيناريوهات التجربة](#10-حسابات-وسيناريوهات-التجربة)
11. [ملفات المنصات (خارج lib)](#11-ملفات-المنصات-خارج-lib)
12. [ملاحظات وأعمال متبقية](#12-ملاحظات-وأعمال-متبقية)
13. [فهرس الملفات التفصيلي (179 ملفاً)](#13-فهرس-الملفات-التفصيلي)

---

## 1. نظرة عامة

شاهبندر سوق جملة (B2B) يربط **التاجر** (صاحب متجر أو مطعم يشتري بالجملة) بـ **المورد** (شركة توزيع تبيع بالجملة). المشروع تطبيقان من قاعدة كود واحدة:

| التطبيق | نقطة التشغيل | المنصات | المحتوى |
|---|---|---|---|
| تطبيق الهاتف | `lib/main.dart` | Android أولاً، ويعمل على Windows والويب | رحلات A (الحساب) وB (التاجر) وC (المورد) وD (المشتركة) |
| لوحة الإدارة | `lib/main_admin.dart` | Flutter Web، ويعمل على Windows | رحلة E (الإدارة) |

**أرقام سريعة:**

- 179 ملف Dart في `lib`، نحو 20,200 سطر.
- 57 شاشة موزعة على خمس رحلات (A1–A11، B1–B17، C1–C10، D1–D7، E1–E10).
- لغتان: العربية (افتراضية، من اليمين لليسار) والإنجليزية، في ملف ترجمة واحد.
- ستة عقود بيانات (Abstract) لكل منها تطبيق وهمي، وعقد سابع للإدارة.

**قواعد العمل التي التزم بها الكود:**

1. **بيانات وهمية فقط:** لا شبكة ولا خادم. كل عملية تنجح (أو تفشل عمداً لتجربة حالات الخطأ) حتى يمكن التنقل في كل الرحلات.
2. **فصل الواجهة عن المتحكم عن البيانات:** الشاشة لا تعرف من أين تأتي البيانات. عند ربط الخادم يتغير سطر التسجيل في `services.dart` فقط.
3. **لا قيم مكتوبة مباشرة في الشاشات:** الألوان من `AppColor`، والمسارات من `AppRoute`، والنصوص من ملف الترجمة.
4. **يعمل على كل المقاسات:** هاتف صغير، هاتف كبير، تابلت، نافذة Windows.

---

## 2. طريقة التشغيل

كل الأوامر تُكتب من داخل مجلد المشروع:

```powershell
cd C:\shahbandar
flutter pub get
```

### تطبيق الهاتف

```powershell
flutter run                     # على الهاتف أو المحاكي المتصل
flutter run -d chrome           # في المتصفح
```

### لوحة الإدارة

المشروع لا يحتوي مجلد `web` بعد، فيُنشأ مرة واحدة فقط:

```powershell
flutter create --platforms=web .
flutter run -d chrome -t lib/main_admin.dart
```

- `-t lib/main_admin.dart` يخبر Flutter أن يبدأ من نقطة تشغيل الإدارة بدل `main.dart`.
- الدخول: `admin@shahbandar.test` وأي كلمة مرور ما عدا `wrong`.
- التشغيل على Windows (`-d windows`) يحتاج Visual Studio 2022 مع حزمة **Desktop development with C++**. إن ظهر الخطأ `Unable to find suitable Visual Studio toolchain` فالحل الأسهل هو Chrome.

### بعد تغيير الشعار

شاشة البداية الأصلية (Native Splash) تُولَّد من الصور، فيلزم تشغيل هذا الأمر مرة واحدة لتظهر صورة شاهبندر الجديدة:

```powershell
dart run flutter_native_splash:create
```

---

## 3. هيكل المجلدات

```
C:\shahbandar\
├── lib\
│   ├── main.dart                ← تشغيل تطبيق الهاتف
│   ├── main_admin.dart          ← تشغيل لوحة الإدارة
│   ├── routes.dart              ← جدول مسارات التطبيق (مسار ← شاشة ← متحكم)
│   ├── admin_routes.dart        ← جدول مسارات الإدارة
│   │
│   ├── core\                    ← كل ما هو مشترك ولا يخص شاشة بعينها
│   │   ├── class\               ← أنواع وأدوات عامة (StatusRequest، Mixins)
│   │   ├── constant\            ← الألوان، السمة، المسارات، القياسات
│   │   ├── functions\           ← دوال مساعدة (تحقق، تنسيق، اختيار صور)
│   │   ├── localization\        ← الترجمات واللغة
│   │   ├── services\            ← خدمات دائمة (الجلسة، السلة، الإشعارات)
│   │   └── shared\              ← مكوّنات واجهة مشتركة (أزرار، حقول، شارات)
│   │
│   ├── data\
│   │   ├── model\               ← نماذج البيانات (منتج، طلب، مستخدم…)
│   │   └── datasource\          ← العقود (Abstract) + تطبيقاتها الوهمية (Mock)
│   │
│   ├── controller\              ← منطق كل شاشة (GetxController)
│   │   ├── auth\  trader\  supplier\  shared\  admin\
│   │
│   └── view\
│       ├── screen\              ← الشاشات الكاملة
│       │   ├── auth\  trader\  supplier\  shared\  admin\
│       └── widget\              ← أجزاء الشاشات القابلة لإعادة الاستخدام
│           ├── auth\  trader\  supplier\  shared\  admin\  splash\
│
├── assets\
│   ├── fonts\                   ← IBM Plex Sans Arabic (4 أوزان)
│   ├── image\logo.svg           ← شعار شاهبندر
│   └── splash\                  ← صور شاشة البداية
│
├── android\  ios\  windows\     ← ملفات المنصات (الاسم والأيقونات)
├── pubspec.yaml
└── flutter_native_splash.yaml
```

**لماذا هذا التقسيم؟** كل طبقة لها سبب واحد للتغيير:

- `view` تتغير إذا تغيّر **التصميم**.
- `controller` يتغير إذا تغيّر **سلوك الشاشة**.
- `data/datasource` يتغير إذا تغيّر **مصدر البيانات** (وهمي ← خادم).
- `core` يتغير نادراً، لأن كل الشاشات تعتمد عليه.

---

## 4. المعمارية: كيف تتصل الطبقات

```
  الشاشة (View)                 المتحكم (Controller)              مصدر البيانات
  ─────────────                 ────────────────────              ─────────────
  GetBuilder<X>  ── يقرأ ──►   حقول + StatusRequest   ── Get.find ──►  AuthData (abstract)
       ▲                            │                                    ▲
       └──── update() ◄─────────────┘                                    │ implements
                                                                   MockAuthData  ← الآن
                                                                   RemoteAuthData ← لاحقاً
```

### 4.1 مسار طلب واحد من البداية للنهاية

مثال: التاجر يضغط "إرسال الطلب" في B11.

1. **الشاشة** `order_review.dart` تستدعي `c.placeOrder` من الزر. لا تحتوي أي منطق.
2. **المتحكم** `cart_controller.dart` يضع `placing = true` ثم `update()`، فيظهر مؤشر التحميل في الزر.
3. المتحكم يستدعي `_orders.placeOrder(...)`، و `_orders` من النوع المجرد `OrderData`.
4. **المصدر الوهمي** `mock_order_data.dart` ينتظر 800 ملّي ثانية (كأنها شبكة)، ينشئ الطلب، يضيف إشعاراً وسطراً في سجل النشاط، ويرجع `Purchase`.
5. المتحكم يفرّغ السلة وينتقل إلى B12 مع تمرير الطلب كـ `arguments`.
6. إن رمى المصدر `RequestFailure`، ينتقل المتحكم إلى B13 مع نوع الخطأ.

### 4.2 دورة حياة المتحكم

هناك طريقتان لإنشاء المتحكمات، ولكل واحدة سبب:

| الطريقة | متى تُستخدم | أمثلة |
|---|---|---|
| `binding` في `routes.dart` | الشاشة تُفتح مرة واحدة في كل وقت | تسجيل الدخول، الهياكل (Shell) |
| `GetBuilder(init: X(args), global: false)` | الشاشة قد تُفتح أكثر من نسخة، أو تحتاج معاملاً | تفاصيل منتج، طلب وارد، حسابي، الملف التجاري |

**لماذا `global: false`؟** لو فتح التاجر منتجاً، ثم من صفحة المورد فتح منتجاً آخر، فبالطريقة العامة (`Get.put`) ستشترك الشاشتان في متحكم واحد، وتعرض الثانية بيانات الأولى. مع `global: false` يملك كل عنصر في الشاشة متحكمه الخاص، ويُحذف معه.

### 4.3 الخدمات الدائمة (permanent)

تُسجَّل مرة واحدة في `initialServices()` وتعيش طوال عمر التطبيق:

| الخدمة | الملف | لماذا دائمة؟ |
|---|---|---|
| `MyServices` | `core/services/services.dart` | تحمل `SharedPreferences` (اللغة، الجلسة) |
| `LocaleController` | `core/localization/locale_controller.dart` | اللغة الحالية تؤثر على كل الشاشات |
| `SessionService` | `core/services/session_service.dart` | المستخدم الحالي يُقرأ من كل مكان |
| `CartService` | `core/services/cart_service.dart` | السلة تُعدَّل من البحث والتفاصيل وصفحة المورد، وعدّادها على أيقونة التبويب |
| `CompareService` | `core/services/compare_service.dart` | قائمة المقارنة تُبنى من شاشات مختلفة |
| `NotificationCenter` | `core/services/notification_center.dart` | نقطة الجرس في أكثر من شاشة |
| مصادر البيانات الستة | `data/datasource/mock_*.dart` | تحفظ الحالة الوهمية في الذاكرة (لو حُذفت لضاعت الطلبات) |

---

## 5. شرح الأكواد المحورية: لماذا كُتبت هكذا؟

هذا القسم يشرح الأسطر التي لها سبب غير واضح من قراءتها، أو التي تحل مشكلة محددة.

### 5.1 `main.dart` — إبقاء شاشة النظام حتى تجهز الخدمات

```dart
Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await initialServices();
  runApp(const ShahbandarApp());
}
```

| السطر | لماذا؟ |
|---|---|
| `WidgetsFlutterBinding.ensureInitialized()` | `initialServices` تقرأ `SharedPreferences` قبل `runApp`، وهذا يحتاج محرك Flutter جاهزاً. بدون هذا السطر يتوقف التطبيق بخطأ عند التشغيل. |
| `FlutterNativeSplash.preserve(...)` | بدونه تختفي شاشة النظام فوراً وتظهر شاشة بيضاء لحظة قبل شاشة Flutter (ومضة). هذا السطر يبقيها حتى نزيلها نحن في `SplashController.onReady`. |
| `await initialServices()` | يجب أن تُسجَّل كل الخدمات **قبل** بناء أي شاشة، لأن الشاشات تستدعي `Get.find` فوراً. |

وداخل `GetMaterialApp`:

```dart
translations: AppTranslation(),
locale: Get.find<LocaleController>().locale,
fallbackLocale: const Locale('ar'),
localizationsDelegates: const [GlobalMaterialLocalizations.delegate, ...],
```

- `locale` يأتي من `LocaleController` الذي سُجّل في `initialServices`، فيبدأ التطبيق باللغة المحفوظة مباشرة.
- `localizationsDelegates` ضرورية لعكس الاتجاه (RTL) في عناصر Material نفسها (التقويم، أزرار الرجوع، النصوص الافتراضية). الترجمات وحدها لا تكفي لذلك.

### 5.2 `services.dart` — نقطة التبديل الوحيدة للخادم

```dart
// الآن: بيانات وهمية. عند ربط الخادم يتغير هذا السطر فقط.
Get.put<AuthData>(MockAuthData(services.prefs), permanent: true);
final catalog = MockCatalogData();
Get.put<CatalogData>(catalog, permanent: true);
...
final orders = MockOrderData(catalog, account);
Get.put<SupplierData>(MockSupplierData(catalog, orders, account), permanent: true);
```

- **`Get.put<AuthData>(...)` مع النوع بين `< >`:** يسجّل الكائن باسم العقد المجرد لا باسم الفئة الوهمية. فالمتحكم يكتب `Get.find<AuthData>()`، ولا يعرف أبداً أن خلفه `MockAuthData`. لاحقاً يصبح السطر `Get.put<AuthData>(RemoteAuthData(api))` بلا تغيير في أي متحكم.
- **لماذا نمرّر `catalog` و `account` لـ `MockOrderData`؟** المصادر الوهمية مترابطة لتبدو الرحلات حقيقية: عندما يقبل المورد طلباً ينقص المخزون في كتالوج التاجر، ويصل إشعار للتاجر. هذا الربط موجود في الوهمي فقط؛ في الخادم الحقيقي يحدث في قاعدة البيانات.
- **الترتيب مهم:** `MyServices` أولاً (لأن الباقي يحتاج `prefs`)، ثم `LocaleController` (يقرأ من `MyServices`)، ثم مصادر البيانات، ثم الخدمات التي تستخدمها (`NotificationCenter` تستدعي `Get.find<AccountData>()`).

### 5.3 `routes.dart` — لماذا الأقواس `{ }` بدل السهم `=>`

```dart
GetPage(
  name: AppRoute.login,
  page: () => const LoginScreen(),
  binding: BindingsBuilder(() {
    Get.put(LoginController());
  }),
),
```

هذا من أهم الأسطر في المشروع. لو كُتب بالسهم:

```dart
binding: BindingsBuilder(() => Get.put(LoginController())),   // ❌ خطأ خفي
```

فإن `BindingsBuilder` يتوقع دالة نوعها `void Function()`، فيستنتج Dart أن النوع العام لـ `Get.put<S>` هو `void`. النتيجة: يُسجَّل المتحكم باسم `void`، وتفشل الشاشة عند `Get.find<LoginController>()` بخطأ "not found". الأقواس تمنع هذا الاستنتاج. التعليق نفسه مكتوب في رأس الملف حتى لا يُعاد الخطأ.

### 5.4 `home_route.dart` — قاعدة "إلى أين يذهب المستخدم" في مكان واحد

```dart
String homeRouteFor(UserModel user) {
  if (user.isDisabled) return AppRoute.accountDisabled;
  if (!user.emailVerified) return AppRoute.checkEmail;
  if (user.hasNoRole) return AppRoute.accountType;
  if (!user.hasBusinessProfile) return AppRoute.businessSetup;
  return user.homeRole == UserRole.trader ? AppRoute.traderHome : AppRoute.supplierHome;
}
```

- خمس شاشات تحتاج هذا القرار: البداية A1، الدخول A2، نتيجة الرابط A5، اختيار الدور A6، الملف التجاري A7.
- لو كُتبت القاعدة في كل شاشة لاختلفت مع الوقت. الآن تُعدَّل في مكان واحد.
- **ترتيب الشروط = ترتيب مراحل التسجيل.** مستخدم لم يفعّل بريده ولم يختر دوراً يُرسل لتفعيل البريد أولاً، لأنه الشرط الأسبق.
- `homeRole` يتذكر آخر وضع استخدمه (تاجر أو مورد) لمن يملك الدورين.

### 5.5 `splash_controller.dart` — `onReady` لا `onInit`

```dart
@override
void onReady() {
  super.onReady();
  FlutterNativeSplash.remove();
  _route();
}

void _go(String route) => Get.offAllNamed(route);
```

- **`onReady`** تُستدعى بعد رسم أول إطار من الشاشة، و**`onInit`** قبله. لو أزلنا شاشة النظام في `onInit` لظهرت لحظة فراغ قبل رسم شاشة Flutter.
- **`offAllNamed`** يحذف شاشة البداية من سجل التنقل. بدونه يضغط المستخدم "رجوع" من الرئيسية فيعود لشاشة البداية، وهذا سلوك غريب.
- إن كانت الجلسة لحساب موقوف، تُمسح الجلسة **قبل** الانتقال، حتى لا يدخل تلقائياً في المرة التالية.

### 5.6 `StatusRequest` وقراءة الحالة في الشاشة

```dart
enum StatusRequest { none, loading, success, failure }
```

وفي كل شاشة تقريباً:

```dart
body: switch (c.status) {
  StatusRequest.failure => ErrorView(onRetry: c.load),
  StatusRequest.success => _Content(c: c),
  _ => const LoadingView(),
},
```

- أربع حالات كافية لكل الشاشات، وتعبير `switch` في Dart 3 يجبرنا على تغطية كل الحالات.
- `_ =>` يجمع `none` و `loading` معاً: قبل أول تحميل وأثناءه نعرض نفس مؤشر التحميل.
- **لماذا `_Content` منفصل؟** داخله تكون البيانات مؤكدة (غير null)، فلا نكتب `!` في كل سطر. هذا أصلح خطأ كان في `supplier_home.dart`.

### 5.7 `SessionService` — حفظ البريد الآن، والرمز لاحقاً

```dart
static const String _key = 'session_email';
Future<void> start(UserModel user) async {
  currentUser = user;
  await _prefs.setString(_key, user.email);
}
```

- في الوهمي نحفظ البريد فقط حتى تتجاوز شاشة البداية الدخول في الفتح التالي.
- عند ربط الخادم يُحفظ هنا **Refresh Token** مشفّر بدل البريد، ولا تتغير أي شاشة لأنها كلها تقرأ `currentUser`.
- `update(user)` بلا حفظ: لتحديث المستخدم في الذاكرة بعد تفعيل دور أو تعديل الملف، دون كتابة غير ضرورية.

### 5.8 `requestId` — منع إنشاء الطلب مرتين (FR-55)

في `cart_controller.dart`:

```dart
Future<void> goToReview() async {
  final ok = await validate();
  if (!ok) return;
  _requestId = 'req-${DateTime.now().microsecondsSinceEpoch}';   // ① رقم جديد لكل مراجعة
  Get.toNamed(AppRoute.orderReview);
}

Future<void> placeOrder() async {
  if (placing) return;                                             // ② منع الضغط المزدوج
  _requestId ??= 'req-...';                                        // ③ يبقى نفسه عند إعادة المحاولة
  final purchase = await _orders.placeOrder(cart.items, requestId: _requestId!);
  _requestId = null;                                               // ④ يُصفَّر بعد النجاح فقط
```

وفي `mock_order_data.dart`:

```dart
final existing = _byRequest[requestId];
if (existing != null) return existing;
```

**المشكلة التي يحلها:** التاجر يضغط "إرسال"، فينقطع الاتصال **بعد** أن وصل الطلب للخادم وقبل أن يصل الرد. يرى B13 فيضغط "إعادة المحاولة". بدون `requestId` يُنشأ طلب ثانٍ مكرر. مع `requestId` يتعرّف الخادم على الطلب نفسه ويرجع الأول.

- ① رقم جديد عند كل دخول للمراجعة، لأن السلة قد تكون تغيّرت.
- ③ `??=` يعني "ضع قيمة فقط إن كانت فارغة"، فإعادة المحاولة من B13 ترسل نفس الرقم.
- ④ يُصفَّر بعد النجاح فقط؛ عند الفشل يبقى لإعادة المحاولة.

### 5.9 `IndexedStack` في هياكل التاجر والمورد

```dart
final body = IndexedStack(index: index, children: _pages);
```

- **لماذا لا نبني التبويب الحالي فقط؟** لأن التاجر يكتب في البحث، يفلتر، يمرر للأسفل، ثم يذهب للسلة ويعود. مع `IndexedStack` تبقى كل التبويبات حية، فيعود البحث كما تركه تماماً.
- `_pages` ثابتة `static const`، فلا تُعاد بناؤها عند كل تغيير تبويب.

والتخطيط المتجاوب في نفس الملف:

```dart
if (box.maxWidth >= AppLayout.wideBreakpoint) {   // 840
  return Scaffold(body: Row(children: [NavigationRail(...), VerticalDivider(...), Expanded(child: body)]));
}
return Scaffold(body: body, bottomNavigationBar: NavigationBar(...));
```

- `LayoutBuilder` يقيس **عرض المساحة المتاحة** لا عرض الشاشة، فيعمل صحيحاً حتى عند تصغير نافذة Windows.
- 840 هو حد Material 3 للتخطيط المتوسط: عنده يصبح الشريط السفلي بعيداً عن المحتوى، والجانبي أنسب.
- **نفس `body` في الحالتين**، فلا تضيع حالة التبويبات عند تغيير حجم النافذة.

### 5.10 `KeyedSubtree` في هيكل الإدارة

```dart
final content = KeyedSubtree(
  key: ValueKey('${c.section}-${c.openUserId}'),
  child: _section(c),
);
```

- **عكس قرار هياكل التاجر تماماً، ولسبب مختلف.** في الإدارة نريد بيانات **حديثة** كل مرة يفتح المشرف قسماً: إن أوقف منتجاً من "المنتجات" ثم فتح "لوحة المؤشرات"، يجب أن يرى العدد الجديد.
- المفتاح يتغير عند تغيير القسم، فيعتبره Flutter عنصراً جديداً ويحذف القديم مع متحكمه، وينشئ متحكماً جديداً يحمّل من البداية.
- `openUserId` جزء من المفتاح: فتح مستخدم ثم مستخدم آخر يُنشئ تفاصيل جديدة لا يعيد استخدام القديمة.
- الشريط الجانبي يتحول إلى `Drawer` تحت 900 بكسل (أعرض من حد التطبيق لأن جداول الإدارة تحتاج مساحة).

### 5.11 `MaxWidth` و `AppLayout`

```dart
static const double formMaxWidth = 480;      // النماذج وشاشات الحساب
static const double contentMaxWidth = 840;   // القوائم والشبكات
```

- على الهاتف العرض أصلاً أقل من 480، فلا يتغير شيء.
- على Windows أو التابلت بدون هذا الحد يمتد حقل البريد على 1900 بكسل، فيصعب قراءته ويبدو مكسوراً.
- `Alignment.topCenter` يضع المحتوى في المنتصف أفقياً ويبقيه أعلى الشاشة.

### 5.12 `LocaleController` — اختيار اللغة الأولى

```dart
locale = Locale(saved ?? (Get.deviceLocale?.languageCode == 'en' ? 'en' : 'ar'));
```

- اللغة المحفوظة أولاً إن وُجدت.
- وإلا: الإنجليزية **فقط** إن كان الهاتف بالإنجليزية، والعربية في **كل** حالة أخرى (فرنسي، تركي…)، لأن الجمهور الأساسي عربي.
- `Get.updateLocale` يعيد بناء كل التطبيق باللغة الجديدة ويعكس الاتجاه فوراً.

### 5.13 `.tr` و `.trParams`

```dart
Text('tabAccount'.tr)
'newCount'.trParams({'n': '${n.unread}'})   // "جديدة: @n"
```

- كل نص ظاهر للمستخدم مفتاح في `core/localization/translation.dart`، فيه قسم `ar` وقسم `en` بنفس المفاتيح.
- `trParams` لإدخال أرقام أو أسماء داخل الجملة، لأن موضعها يختلف بين العربية والإنجليزية.
- عند كل مرحلة تم التحقق آلياً أن كل مفتاح مستخدم موجود في اللغتين، وأنه لا مفاتيح مكررة.

### 5.14 `firstWhereOrNull` محلية

```dart
T? firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) { ... }
```

- GetX و Dart كلاهما يوفّران دوال بنفس الفكرة، لكن أسماءها وأماكنها تغيرت بين الإصدارات، فظهر تعارض بين `package:get` و `package:collection`.
- دالة محلية من 8 أسطر تزيل الاعتماد على أي إصدار.

---

## 6. نظام التصميم

### 6.1 الألوان (`core/constant/app_color.dart`)

> القاعدة المكتوبة في رأس الملف: **لا يُكتب أي لون مباشرة داخل الواجهات.** وكل لون نص يحقق تباين 4.5:1 على الأقل فوق خلفيته (WCAG AA).

| الرمز | القيمة | الاستخدام |
|---|---|---|
| `ink` | `#17202E` | النص الأساسي، الهيكل، الخلفيات الداكنة (لوحة الإدارة، الشعار) |
| `orange` | `#F27A1A` | **تعبئة الإجراء الرئيسي فقط** (الزر الأساسي) |
| `orangeDeep` | `#A3470A` | الروابط والأيقونات البرتقالية فوق الفاتح (البرتقالي العادي لا يحقق 4.5:1 كنص) |
| `orangeSoft` | `#FDE7D3` | خلفية العنصر المحدد (التبويب، الشريحة) |
| `orangeOnInk` | `#F7A15A` | نص برتقالي فوق الكحلي |
| `background` | `#F4F5F7` | خلفية الشاشات |
| `surface` | `#FFFFFF` | البطاقات والحقول |
| `textSecondary` | `#5B6472` | النص الثانوي |
| `success` / `warning` / `info` / `preparing` / `danger` | — | حالات الطلبات، كل منها بنسخة `Soft` للخلفية |

**لماذا `onPrimary: AppColor.ink`؟** النص الأبيض على البرتقالي `#F27A1A` تباينه 2.8:1 فقط (أقل من الحد 4.5:1). الكحلي عليه 5.9:1.

### 6.2 السمة (`core/constant/app_theme.dart`)

- **الخط:** IBM Plex Sans Arabic بأربعة أوزان (400، 500، 600، 700). يدعم العربية واللاتينية بنفس الروح، فلا يختلف شكل الأرقام والبريد الإنجليزي.
- **شريط العنوان:** بلون الخلفية بلا ظل (`elevation: 0`)، وظل خفيف 0.5 عند التمرير فقط، والعنوان على اليمين (`centerTitle: false`) كما في iOS الحديث.
- `surfaceTintColor: Colors.transparent`: Material 3 يلوّن الشريط تلقائياً بلون أساسي عند التمرير؛ هذا يمنع ظهور مسحة برتقالية.

### 6.3 الأشكال والقياسات

| العنصر | نصف القطر | الارتفاع الأدنى |
|---|---|---|
| البطاقات والمجموعات | 20 | — |
| الأزرار | 16 | 52 |
| الحقول | 14 | 56 |
| النوافذ السفلية | 28 (الأعلى فقط) | — |
| مساحة اللمس | — | 44–48 على الأقل (معيار Apple HIG) |

نظام التباعد على شبكة 4 بكسل: 4، 8، 12، 16، 20، 24.

### 6.4 المكوّن المميز: `OrderSlip`

`core/shared/order_slip.dart` يرسم قسيمة طلب بحافة مثقّبة (دوائر مقتطعة على الجانبين وخط متقطع)، مستوحاة من إيصالات الجملة الورقية. تظهر في B12 (تم الإرسال) وتفاصيل الطلب وتفاصيل الطلب الوارد عند المورد. هي الهوية البصرية التي تميّز شاهبندر عن قوالب التسوق المعتادة.

### 6.5 مكونات مشتركة (`core/shared`)

| المكوّن | الغرض |
|---|---|
| `AppButton` | زر بثلاثة أنواع (أساسي برتقالي، ثانوي بإطار، نصي)، مع حالة تحميل تمنع الضغط المزدوج |
| `AppTextField` | حقل بعنوان فوقه، رسالة خطأ تحته، وخيار `ltr` للبريد والهاتف داخل واجهة عربية |
| `AppSelectField` | قائمة اختيار تفتح نافذة سفلية بحث (بدل القائمة المنسدلة الصغيرة على الهاتف) |
| `StatusChip` | شارة حالة الطلب بلون ونص |
| `QuantityStepper` | عدّاد الكمية مع الحد الأدنى للطلب (MOQ) والمخزون |
| `state_views.dart` | `LoadingView`، `ErrorView`، `EmptyView`، بنفس الشكل في كل التطبيق |
| `AppImage` | عرض صورة من `https` أو `local://` أو بديل (انظر القسم 8) |
| `LogoPickerField` | مربع رفع شعار النشاط |
| `NotificationBell` | أيقونة الجرس مع نقطة الإشعارات غير المقروءة |
| `MaxWidth` | حد أقصى للعرض على الشاشات الكبيرة |

---

## 7. الرحلات والشاشات

### 7.1 رحلة A — الحساب والدخول

| الرمز | الشاشة | الملف (`lib/view/screen/...`) | المتحكم (`lib/controller/...`) |
|---|---|---|---|
| A1 | البداية | `splash.dart` | `splash_controller.dart` |
| A2 | تسجيل الدخول | `auth/login.dart` | `auth/login_controller.dart` |
| A3 | إنشاء حساب | `auth/register.dart` | `auth/register_controller.dart` |
| A4 | تحقق من بريدك | `auth/check_email.dart` | `auth/check_email_controller.dart` |
| A5 | نتيجة رابط التفعيل | `auth/link_result.dart` | `auth/link_result_controller.dart` |
| A6 | نوع الحساب | `auth/account_type.dart` | `auth/account_type_controller.dart` |
| A7 | الملف التجاري | `auth/business_setup.dart` | `auth/business_setup_controller.dart` |
| A8 | نسيت كلمة المرور | `auth/forgot_password.dart` | `auth/forgot_password_controller.dart` |
| A9 | تم إرسال الرابط | `auth/reset_sent.dart` | `auth/reset_sent_controller.dart` |
| A10 | كلمة مرور جديدة | `auth/new_password.dart` | `auth/new_password_controller.dart` |
| A11 | الحساب موقوف | `auth/account_disabled.dart` | — |

**قرارات مهمة:**

- **الأزرار معطّلة حتى تكتمل الحقول المطلوبة، والأخطاء التفصيلية تظهر بعد أول ضغطة فقط** (`submitted` + `AutovalidateMode`). المستخدم لا يُوبَّخ بأخطاء حمراء قبل أن يكمل الكتابة.
- `CountdownMixin` (`core/class/countdown_mixin.dart`) يُستخدم في A4 (انتظار 45 ثانية) وA9 (60 ثانية) لمنع إعادة إرسال البريد مباشرة، ويعرض الوقت المتبقي بصيغة 0:45.
- `PasswordRulesView` تعرض شروط كلمة المرور وتتلون كل شرط عند تحقيقه، بدل رسالة خطأ واحدة بعد الإرسال.
- A7 تطلب **وسيلة تواصل واحدة على الأقل** (هاتف أو بريد)، والخطأ يظهر على البطاقة كلها لا على حقل بعينه.
- `auth_body.dart` هيكل مشترك لشاشات A: محتوى قابل للتمرير، وأزرار ملتصقة بالأسفل تنزل تحت المحتوى عند ظهور لوحة المفاتيح. و `auth_header.dart` الجزء الكحلي أعلى شاشة الدخول A2 (زر اللغة، الشعار، الاسم).

### 7.2 رحلة B — التاجر

| الرمز | الشاشة | الملف | ملاحظة |
|---|---|---|---|
| — | الهيكل | `trader/trader_shell.dart` | 5 تبويبات في `IndexedStack` |
| B1 | الرئيسية | `trader/trader_home.dart` | الفئات، الموردون، آخر الطلبات |
| B2–B4 | البحث والفرز والفلترة | `trader/trader_search.dart` + `widget/trader/filter_sheet.dart`، `sort_sheet.dart` | الفلتر في نموذج `ProductFilter` |
| B5 | منتجات فئة | `trader/category_products.dart` | |
| B6 | تفاصيل المنتج | `trader/product_details.dart` | متحكم محلي `global: false` |
| B7 | صفحة المورد | `trader/supplier_page.dart` | |
| B8 | المقارنة | `trader/compare.dart` | حتى 3 منتجات، `CompareService` |
| B9–B10 | السلة والتحقق | `trader/trader_cart.dart` | تجميع حسب المورد، تغيّر السعر، نقص المخزون |
| B11 | مراجعة الطلب | `trader/order_review.dart` | |
| B12 | تم الإرسال | `trader/order_sent.dart` | `OrderSlip` |
| B13 | فشل الإرسال | `trader/order_failed.dart` | إعادة المحاولة بنفس `requestId` |
| B14 | طلباتي | `trader/trader_orders.dart` | |
| B15–B17 | تفاصيل الطلب والإلغاء | `trader/purchase_details.dart` + `widget/trader/cancel_dialog.dart` | `OrderTracker` لمراحل الطلب |

**قرارات مهمة:**

- **السلة مجمّعة حسب المورد** (`CartService.bySupplier`)، لأن كل مورد يصله طلب منفصل (FR-42). الطلب الواحد من التاجر = `Purchase` يحتوي عدة `SubOrder`، واحد لكل مورد.
- **المجموع لكل عملة على حدة** (`totals`)، بلا تحويل، لأن الموردين قد يسعّرون بالليرة أو الدولار.
- عدّاد السلة = **عدد الأصناف** لا مجموع الكميات (100 كيس سكر = صنف واحد).
- **قبل المراجعة يُتحقق من السلة** (`validateCart`): إن تغيّر سعر يظهر شريط تنبيه، وإن نقص المخزون يُقترح "استخدام المتوفر" إن كان لا يقل عن الحد الأدنى.

### 7.3 رحلة C — المورد

| الرمز | الشاشة | الملف (`lib/view/screen/supplier/...`) | المتحكم (`lib/controller/supplier/...`) |
|---|---|---|---|
| — | الهيكل | `supplier_shell.dart` | `supplier_shell_controller.dart` |
| C1 | الرئيسية | `supplier_home.dart` | `supplier_home_controller.dart` |
| C2 | الطلبات الواردة | `supplier_orders.dart` | `supplier_orders_controller.dart` |
| C3 / C6 | تفاصيل الطلب الوارد | `incoming_order.dart` | `incoming_order_controller.dart` |
| C4 | نافذة الرفض | `widget/supplier/reject_sheet.dart` | (داخل متحكم C3) |
| C5 | فشل القبول (نقص مخزون) | `widget/supplier/accept_failed_dialog.dart` | (داخل متحكم C3) |
| C7 / C10 | منتجاتي / حالة فارغة | `supplier_products.dart` | `supplier_products_controller.dart` |
| C8 / C9 | إضافة / تعديل منتج | `product_form.dart` | `product_form_controller.dart` |
| — | حسابي | `supplier_account.dart` | (يستخدم `AccountScreen`) |

**قرارات مهمة:**

- **القبول يتحقق من المخزون أولاً لكل الأصناف، ثم يخصمها كلها معاً** (`mock_supplier_data.dart`). لو خُصم صنف ثم فشل الثاني، يبقى المخزون في حالة خاطئة.
- **إن ألغى التاجر الطلب أثناء فتح المورد للشاشة**، يرمي القبول `notAllowed`، فيرى المورد رسالة بدل قبول طلب ملغى.
- `IncomingOrder.moveTo()` يضيف سطراً في الخط الزمني (`OrderTimeline`) مع الوقت، فيرى الطرفان تاريخ كل حالة.
- `AgeChip` في القوائم يعرض "منذ 3 ساعات" ويتلون بالتحذير بعد مدة، حتى لا تُنسى الطلبات المنتظرة.
- `_afterChange` يكتب في سجل النشاط **دائماً**، ويرسل إشعاراً للتاجر.
- **نموذج المنتج** (C8): النشر يحتاج صورة واحدة على الأقل، ولا يُتاح أثناء رفع صورة، ويوجد خيار "حفظ كموقوف" لمنتج غير جاهز للعرض.

### 7.4 رحلة D — الواجهات المشتركة

| الرمز | الشاشة | الملف (`lib/view/screen/shared/...`) | المتحكم (`lib/controller/shared/...`) |
|---|---|---|---|
| D1 | الإشعارات | `notifications.dart` | `notifications_controller.dart` |
| D2 | حسابي | `account.dart` | `account_controller.dart` |
| D3 | الملف التجاري | `business_profile.dart` | `business_profile_controller.dart` |
| D4 | تفعيل الدور الآخر | `widget/shared/activate_role_sheet.dart` | (داخل متحكم D2) |
| D5 | سجل النشاط | `activity_log.dart` | `activity_log_controller.dart` |
| D6 | طلب حذف الحساب | `delete_account.dart` | `delete_account_controller.dart` |
| D7 | تغيير كلمة المرور | `change_password.dart` | `change_password_controller.dart` |

**قرارات مهمة:**

- **`AccountScreen` واحدة للدورين**، تأخذ `role` كمعامل. `trader_account.dart` و `supplier_account.dart` مجرد غلاف من سطر واحد:
  ```dart
  Widget build(BuildContext context) => const AccountScreen(role: UserRole.trader);
  ```
  أي تعديل على "حسابي" يظهر في اللوحتين معاً.
- **الإشعارات منفصلة لكل دور:** إشعارات التاجر لا تظهر في وضع المورد، لأن من يملك الدورين يفكر بكل وضع على حدة.
- **رابط حذف الحساب أحمر وفي الأسفل** بعيداً عن العناصر اليومية، ونصه يتغير إلى "طلب الحذف قيد المراجعة" إن أُرسل.
- **D3 يقارن بالمحفوظ** (`changed`): زر الحفظ معطّل حتى يتغير شيء فعلاً، فلا يحفظ المستخدم بلا سبب.
- `MockAccountData` مركز الإشعارات والسجل: `notify()` و `log()` تستدعيهما مصادر الطلبات والمورد عند كل حدث.

### 7.5 رحلة E — لوحة الإدارة

| الرمز | القسم | الملف (`lib/view/screen/admin/...`) |
|---|---|---|
| E1 | الدخول | `admin_login.dart` |
| — | الهيكل والشريط الجانبي | `admin_shell.dart` |
| E2 | لوحة المؤشرات | `admin_dashboard.dart` |
| E3 / E4 | المستخدمون وتفاصيل مستخدم | `admin_users.dart` |
| E5 | المنتجات | `admin_products.dart` |
| E6 | الطلبات | `admin_orders.dart` |
| E7 / E8 | فئات المنتجات / فئات النشاط | `admin_categories.dart` (نفس الشاشة بمعامل `kind`) |
| E9 | طلبات الحذف | `admin_deletion.dart` |
| E10 | سجل التدقيق | `admin_audit.dart` |

**المتحكمات:**

- `admin_login_controller.dart`: الدخول وحفظ الجلسة (`admin_email` في prefs).
- `admin_shell_controller.dart`: القسم الحالي (`AdminSection`)، فتح مستخدم، وعدّاد طلبات الحذف على الشريط.
- `admin_section_controllers.dart`: متحكم لكل قسم في ملف واحد لأنها متشابهة البنية (تحميل، فلترة، صفحات، إجراء).

**أجزاء مشتركة (`lib/view/widget/admin/...`):**

- `admin_table.dart`: جدول بأعمدة نسبية العرض، رأس رمادي فاتح، صف محدد بخلفية دافئة، وتمرير أفقي حين يضيق العرض.
- `admin_parts.dart`: `AdminPage` (رأس + محتوى)، `TableWithPanel` (جدول ولوحة تفاصيل بجانبه)، `FilterPill`، و `confirmAdminAction` (نافذة تأكيد قبل أي إجراء، بزر أحمر للإجراءات الخطرة).
- `admin_chips.dart`: شارات حالات المستخدم والمنتج والحذف.
- `admin_brand.dart`: شعار "شاهبندر · الإدارة".

**قرارات مهمة:**

- **نقطة تشغيل منفصلة** (`main_admin.dart`): لوحة الإدارة لا تُضمَّن في تطبيق الهاتف، فلا يمكن لأي مستخدم الوصول إليها، ولا تزيد حجم التطبيق.
- **مساران فقط** (`adminLogin`، `adminHome`): الأقسام الثمانية داخل هيكل واحد، فالشريط الجانبي لا يُعاد رسمه.
- **كل إجراء حساس (إيقاف، حذف، رفض) يمر بنافذة تأكيد**، والإيقاف في E4 يُرفق بسبب، ويُكتب كل إجراء في سجل التدقيق E10 مع المشرف والوقت.

---

## 8. رفع الصور الحقيقي

قبل هذا التعديل كان التطبيق يضع صورة افتراضية من عنده. الآن يختار المستخدم صوره الحقيقية من المعرض أو الكاميرا.

### 8.1 تدفق الصورة

```
 المستخدم يضغط "إضافة صورة"
          │
          ▼
 pickImages()                     core/functions/pick_image.dart
   ├─ هاتف؟ ← نافذة "المعرض / الكاميرا"
   ├─ ضغط: 1600 بكسل، جودة 85
   └─ تحقق: jpg/png/webp/heic، ≤ 5 MB
          │  List<PickedImage> (بايتات + اسم)
          ▼
 المتحكم يعرض الصورة فوراً (preview)  ← المستخدم يراها قبل اكتمال الرفع
          │
          ▼
 MediaData.uploadImage(onProgress)   data/datasource/media_data.dart
   └─ MockMediaData: يحاكي التقدم، ثم LocalImageCache.put(bytes) ← "local://7"
          │
          ▼
 الرابط يُحفظ مع المنتج أو الملف التجاري
          │
          ▼
 AppImage(url) في كل الشاشات         core/shared/app_image.dart
   ├─ local://… ← Image.memory
   ├─ https://… ← Image.network (بعد ربط الخادم)
   └─ غير ذلك ← البديل (أيقونة على لون)
```

### 8.2 لماذا البايتات لا المسار؟

```dart
class PickedImage {
  final Uint8List bytes;
  final String name;
}
```

على **الويب** لا يوجد مسار ملف حقيقي، وعلى **Windows** المسار يختلف عن Android. البايتات تعمل بنفس الطريقة على المنصات الثلاث، وهي ما يُرسل للخادم في النهاية.

### 8.3 `pick_image.dart` — سطر بسطر

```dart
bool get _cameraAvailable =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
```
على Windows والويب لا كاميرا عملية، فيُفتح اختيار الملفات مباشرة بلا نافذة سؤال.

```dart
if (source == ImageSource.gallery && max > 1) {
  files = await picker.pickMultiImage(maxWidth: maxSide, maxHeight: maxSide, imageQuality: quality, limit: max);
}
```
- `pickMultiImage` لاختيار عدة صور مرة واحدة (صور المنتج). الكاميرا تلتقط صورة واحدة دائماً.
- `limit: max` = المتبقي من 5 صور، فلا يختار المستخدم 8 ثم نرفض 3.
- `maxWidth: 1600, imageQuality: 85`: صورة هاتف حديث 12 ميغابكسل حجمها 4–8 MB؛ بعد الضغط 300–600 KB بلا فرق مرئي على الشاشة. هذا يوفّر بيانات التاجر والمورد ومساحة الخادم.

```dart
} on PlatformException catch (e) {
  final denied = e.code.contains('access_denied') || e.code.contains('permission');
  showMessage(denied ? (source == ImageSource.camera ? 'cameraPermissionDenied'.tr : 'photoPermissionDenied'.tr) : 'pickFailed'.tr);
```
إن رفض المستخدم صلاحية الصور أو الكاميرا، تظهر رسالة واضحة تذكر أيهما، بدل أن يتعطل التطبيق أو لا يحدث شيء.

```dart
if (!_allowed.contains(ext) || bytes.lengthInBytes > maxImageBytes) { skipped = true; continue; }
...
if (skipped) showMessage('imageRejected'.tr);
```
الصور غير المقبولة تُتخطى **بصمت فردياً** ثم رسالة **واحدة** في النهاية، بدل رسالة لكل صورة.

### 8.4 `LocalImageCache` و `AppImage`

```dart
abstract final class LocalImageCache {
  static const String scheme = 'local://';
  static final Map<String, Uint8List> _images = {};
  static String put(Uint8List bytes) { final url = '$scheme${_next++}'; _images[url] = bytes; return url; }
}
```

- **المشكلة:** الرفع الوهمي يجب أن يرجع "رابطاً" كما سيفعل الخادم، والصورة يجب أن تظهر في شاشات أخرى (السلة، البحث عند التاجر).
- **الحل:** رابط بصيغة `local://N` يشير لبايتات في الذاكرة. كل الشاشات تتعامل معه كرابط عادي.
- **عند ربط الخادم:** يرجع `https://...`، و `AppImage` يعرضه من الشبكة تلقائياً، ولا يتغير أي سطر في الشاشات.

```dart
return Image.memory(bytes, fit: fit, gaplessPlayback: true, errorBuilder: (_, _, _) => placeholder);
```
- `gaplessPlayback: true`: عند إعادة بناء الشاشة (بسبب `update()` أثناء رفع صورة أخرى) تبقى الصورة ظاهرة بلا ومضة.
- `errorBuilder`: صورة تالفة تُظهر البديل بدل علامة خطأ حمراء.
- `(_, _, _)`: صيغة Dart 3.7+ لتجاهل المعاملات غير المستخدمة.

### 8.5 `LogoPickerMixin` — منطق الشعار مرة واحدة لشاشتين

```dart
mixin LogoPickerMixin on GetxController {
  String logoUrl = '';
  Uint8List? logoPreview;
  ...
  Future<void> pickLogo() async {
    final previousUrl = logoUrl;
    ...
    } catch (_) {
      logoPreview = null;
      logoUrl = previousUrl;       // نرجع للشعار السابق إن فشل الرفع
```

- A7 (إنشاء الحساب) و D3 (تعديل الملف) تحتاجان نفس منطق الشعار. `mixin` يضيفه لأي متحكم بكلمة `with LogoPickerMixin`.
- `on GetxController` يضمن أنه يُستخدم فقط مع متحكم، فيستطيع استدعاء `update()`.
- **`previousUrl`:** إن كان للمستخدم شعار قديم وفشل رفع الجديد، لا يفقد القديم.
- في D3: `canSave => ... && !logoUploading`، فلا يُحفظ الملف قبل اكتمال رفع الشعار.

### 8.6 صور المنتج: رفع متوازٍ لكل صورة

```dart
Future<void> addImage() async {
  final picked = await pickImages(max: maxImages - images.length);
  for (final p in picked) {
    final img = FormImage(preview: p.bytes);
    images.add(img);
    _upload(img, p);        // بلا await: كل صورة ترفع وحدها بالتوازي
  }
  update();
}
```

- **بلا `await` داخل الحلقة عمداً:** لو اختار 4 صور، تبدأ كلها بالرفع معاً، وكل مربع يعرض تقدمه الخاص.
- إن فشلت صورة واحدة تُحذف وحدها، والباقي يكمل.
- `makeCover(img)` ينقل الصورة لأول القائمة: **الصورة الأولى هي الغلاف** دائماً، فلا حاجة لحقل منفصل.
- `uploading => images.any((i) => i.uploading)`: زر النشر معطّل ما دامت أي صورة قيد الرفع.

### 8.7 صلاحيات المنصات

- **iOS** (`ios/Runner/Info.plist`): `NSPhotoLibraryUsageDescription` و `NSCameraUsageDescription` بنص عربي يشرح السبب. بدونهما يرفض Apple التطبيق ويتعطل عند فتح الكاميرا.
- **Android:** `image_picker` 1.1 يستخدم Photo Picker الخاص بالنظام، فلا يحتاج صلاحية تخزين.

---

## 9. تغيير الاسم إلى شاهبندر والشعار

### 9.1 الملفات التي تغيّرت

| المكان | التغيير |
|---|---|
| `pubspec.yaml` | `name: shahbandar` |
| `lib/main.dart` | `JisrApp` ← `ShahbandarApp`، والعنوان `Shahbandar` |
| `lib/main_admin.dart` | `ShahbandarAdminApp`، والعنوان `Shahbandar Admin` |
| `lib/core/localization/translation.dart` | كل "جسر" ← "شاهبندر"، وكل "Jisr" ← "Shahbandar" |
| كل المصادر الوهمية | البريد `@jisr.test` ← `@shahbandar.test`، و `jisr.example` ← `shahbandar.example` |
| `android/app/build.gradle.kts` | `applicationId = "shahbandar.net.shahbandar"` |
| `android/app/src/main/AndroidManifest.xml` | `android:label="@string/app_name"` |
| `android/app/src/main/res/values/strings.xml` | جديد: `شاهبندر` |
| `android/app/src/main/res/values-en/strings.xml` | جديد: `Shahbandar` (يظهر إن كان الهاتف بالإنجليزية) |
| `ios/Runner/Info.plist` | `CFBundleDisplayName = شاهبندر`، `CFBundleName = shahbandar` |
| `ios/Runner.xcodeproj/project.pbxproj` | `PRODUCT_BUNDLE_IDENTIFIER = shahbandar.net.shahbandar` |
| `windows/CMakeLists.txt` | `project(shahbandar)`، `BINARY_NAME "shahbandar"` |
| `windows/runner/main.cpp` | عنوان النافذة `L"Shahbandar"` |
| `windows/runner/Runner.rc` | اسم الشركة والمنتج والملف |
| `README.md` | الاسم وطريقة التشغيل |

**لماذا بقي `namespace = "jisr.net.jisr"` في `build.gradle.kts`؟** `namespace` يجب أن يطابق اسم الحزمة المكتوب في ملف `MainActivity.kt` (داخل `android/app/src/main/kotlin/`). تغييره يتطلب نقل الملف إلى مجلد جديد وحذف القديم، وأداة التعديل عن بُعد لا تملك صلاحية الحذف، فيُنقل يدوياً لاحقاً إن أردت. **المستخدم لا يرى `namespace` أبداً**؛ ما يظهر في المتجر والهاتف هو `applicationId` وهو الآن `shahbandar.net.shahbandar`.

### 9.2 الشعار

- **الفكرة:** "شاهبندر" لقب تاريخي لكبير التجار في الخان أو السوق. الشعار **قوس بوابة خان** (مدخل السوق) يعلوه **ثلاث نقاط**: هي تاج كبير التجار، وفي الوقت نفسه النقاط الثلاث لحرف **ش** أول حرف في الاسم.
- **الألوان:** القوس كحلي `ink` والنقاط برتقالية `orange`، نفس هوية التطبيق.
- **الملفات:**
  - `assets/image/logo.svg`: المصدر المتجه، يُعرض بـ `flutter_svg` في شاشة البداية ورأس شاشات الحساب ولوحة الإدارة.
  - `assets/splash/splash_icon.png` (448×448) و `splash_icon_android12.png` (960×960): شاشة النظام. Android 12+ يقص الأيقونة في دائرة، لذلك نسخة منفصلة بهامش أكبر.
  - `android/app/src/main/res/mipmap-*/ic_launcher.png`: أيقونة التطبيق بخمسة مقاسات (48، 72، 96، 144، 192) لكثافات الشاشات المختلفة.
  - `windows/runner/resources/app_icon.ico`: أيقونة نافذة Windows.
- **في الكود:** `core/constant/image_asset.dart` يحمل المسار، و `view/widget/splash/splash_logo.dart` و `view/widget/admin/admin_brand.dart` يعرضانه.

---

## 10. حسابات وسيناريوهات التجربة

### 10.1 حسابات التطبيق (أي كلمة مرور ما عدا `wrong`)

| البريد | ما يحدث |
|---|---|
| `trader@shahbandar.test` | تاجر جاهز ← لوحة التاجر |
| `supplier@shahbandar.test` | مورد "شركة الأفق" بمنتجات وطلبات ← لوحة المورد |
| `both@shahbandar.test` | تاجر ومورد (مورد "مؤسسة النخيل" بلا منتجات ← C10) |
| `new@shahbandar.test` | بريد غير مفعّل ← A4 |
| `expired@shahbandar.test` | رابط التفعيل منتهٍ ← A5 |
| `norole@shahbandar.test` | لم يختر دوراً ← A6 |
| `noprofile@shahbandar.test` | لم يكمل الملف التجاري ← A7 |
| `disabled@shahbandar.test` | حساب موقوف ← A11 |
| `locked@shahbandar.test` | محاولات كثيرة، انتظار 30 ثانية |
| `offline@shahbandar.test` | لا يوجد اتصال |

### 10.2 لوحة الإدارة

`admin@shahbandar.test` وأي كلمة مرور ما عدا `wrong`.

### 10.3 سيناريوهات مدمجة

| السيناريو | كيف تجربه | الشاشة |
|---|---|---|
| تغيّر السعر | أضف المعكرونة للسلة ثم افتح السلة | B9 |
| نقص المخزون | أضف الرز البسمتي (ينخفض لـ 5) | B10 |
| فشل الإرسال | اجعل كمية أي صنف 13 بالضبط | B13 |
| قبول تلقائي | بعد 20 ثانية من الإرسال يقبل أول مورد | B15 |
| فشل القبول | طلب "مطعم بيت الشام" (220 كيس سكر، المتوفر 200) | C5 |
| حالة فارغة | ادخل بـ `both@shahbandar.test` ← منتجاتي | C10 |

**ملاحظة:** الحسابات الجديدة تُحفظ في `SharedPreferences` وتبقى بعد إغلاق التطبيق. الطلبات والصور المرفوعة في الذاكرة فقط وتُمسح عند الإغلاق.

---

## 11. ملفات المنصات (خارج lib)

| الملف | المحتوى والسبب |
|---|---|
| `C:\shahbandar\pubspec.yaml` | الاعتماديات: `get`، `shared_preferences`، `flutter_native_splash`، `flutter_svg`، `intl`، `flutter_localizations`، `image_picker`. والخط بأربعة أوزان، والأصول. |
| `C:\shahbandar\flutter_native_splash.yaml` | لون خلفية شاشة النظام (كحلي) وصورتها، بنسختين: عادية و Android 12. |
| `C:\shahbandar\android\app\build.gradle.kts` | `applicationId` الجديد. |
| `C:\shahbandar\android\app\src\main\AndroidManifest.xml` | الاسم من `strings.xml` حتى يتغير حسب لغة الهاتف. |
| `C:\shahbandar\android\app\src\main\res\values\strings.xml` | `app_name = شاهبندر`. |
| `C:\shahbandar\android\app\src\main\res\values-en\strings.xml` | `app_name = Shahbandar`. |
| `C:\shahbandar\android\app\src\main\res\mipmap-*\ic_launcher.png` | الأيقونة بخمس كثافات. |
| `C:\shahbandar\ios\Runner\Info.plist` | الاسم وصلاحيات الصور والكاميرا. |
| `C:\shahbandar\windows\CMakeLists.txt` | اسم المشروع والملف التنفيذي `shahbandar.exe`. |
| `C:\shahbandar\windows\runner\main.cpp` | عنوان النافذة. |
| `C:\shahbandar\windows\runner\Runner.rc` | بيانات الملف التنفيذي (الشركة، المنتج، الإصدار). |
| `C:\shahbandar\windows\runner\resources\app_icon.ico` | أيقونة النافذة. |
| `C:\shahbandar\assets\image\logo.svg` | الشعار. |
| `C:\shahbandar\assets\splash\*.png` | صور شاشة البداية. |
| `C:\shahbandar\assets\fonts\IBMPlexSansArabic-*.ttf` | الخط. |

---

## 12. ملاحظات وأعمال متبقية

### 12.1 تعديل يدوي مطلوب: إعدادات VS Code

الملف `C:\shahbandar\.vscode\settings.json` ما زال يشير للمسار القديم، ومجلد `.vscode` محمي من التعديل عن بُعد. افتحه وغيّر:

```json
{
    "cmake.sourceDirectory": "C:/jisr/windows"
}
```

إلى:

```json
{
    "cmake.sourceDirectory": "C:/shahbandar/windows"
}
```

### 12.2 بعد إعادة تسمية المجلد

لأن المجلد تغيّر من `C:\jisr` إلى `C:\shahbandar`، قد تبقى مسارات قديمة في ملفات البناء المؤقتة. شغّل مرة واحدة:

```powershell
cd C:\shahbandar
flutter clean
flutter pub get
```

### 12.3 أعمال مؤجلة

| البند | الحالة |
|---|---|
| ربط الخادم | لكل عقد في `data/datasource` يُكتب `Remote...Data`، ويُستبدل سطره في `services.dart` و `admin_services.dart`. |
| البريد الذي يصل باسم "jisr" | التطبيق لا يرسل بريداً حقيقياً (الإرسال وهمي). إن كان البريد من Firebase أو خدمة أخرى، فالاسم يُغيَّر من إعدادات تلك الخدمة (في Firebase: Project settings ← Public-facing name). |
| `namespace` في Android | يبقى `jisr.net.jisr` داخلياً (انظر 9.1). يمكن نقله لاحقاً مع مجلد `MainActivity.kt`. |
| الوضع الداكن | الألوان معرّفة كرموز في `AppColor`، فإضافة `AppTheme.dark()` لا تتطلب تعديل الشاشات. |
| الإشعارات الفورية (Push) | `NotificationCenter` جاهز لاستقبال العدد من الخادم. |

---
## 13. فهرس الملفات التفصيلي

كل ملف في `C:\shahbandar\lib`، مرتباً حسب المجلد. لكل ملف: المسار الكامل، عدد الأسطر، الغرض، الأنواع المعرّفة فيه مع وصف كل منها، الدوال الموثقة، والملفات التي يعتمد عليها.

> الأوصاف مأخوذة من تعليقات التوثيق (`///`) المكتوبة داخل الملفات نفسها، فهي تطابق الكود الحالي حرفياً.

### الجذر

#### 1. `admin_routes.dart`

- **المسار:** `C:\shahbandar\lib\admin_routes.dart`
- **الأسطر:** 27
- **الغرض:** مسارات لوحة الإدارة: الدخول، ثم الهيكل الذي يعرض الأقسام الثمانية داخله.
- **الحزم:** get
- **يعتمد على:** `admin_login_controller`، `admin_shell_controller`، `app_routes`، `admin_login`، `admin_shell`

#### 2. `main.dart`

- **المسار:** `C:\shahbandar\lib\main.dart`
- **الأسطر:** 50
- **الغرض:** نقطة تشغيل تطبيق الهاتف: تبقي شاشة النظام ظاهرة، تسجّل الخدمات، ثم تشغّل `ShahbandarApp` (GetMaterialApp باللغة والسمة والمسارات).
- **أنواع داخلية/مساعدة:** `main`، `ShahbandarApp`
- **الحزم:** flutter، flutter_localizations، flutter_native_splash، get
- **يعتمد على:** `app_routes`، `app_theme`، `locale_controller`، `translation`، `services`، `routes`

#### 3. `main_admin.dart`

- **المسار:** `C:\shahbandar\lib\main_admin.dart`
- **الأسطر:** 51
- **الغرض:** نقطة تشغيل لوحة الإدارة (Flutter Web، وتعمل أيضاً على Windows).  flutter run -d chrome -t lib/main_admin.dart flutter build web -t lib/main_admin.dart  نفس المشروع ونفس الألوان والخطوط والترجمات، لكن بمسارات وخدمات خاصة بالإدارة.
- **أنواع داخلية/مساعدة:** `ShahbandarAdminApp`
- **الحزم:** flutter، flutter_localizations، get
- **يعتمد على:** `admin_routes`، `app_routes`، `app_theme`، `locale_controller`، `translation`، `admin_services`، `admin_data`

#### 4. `routes.dart`

- **المسار:** `C:\shahbandar\lib\routes.dart`
- **الأسطر:** 210
- **الغرض:** جدول مسارات تطبيق الهاتف: كل مسار ← شاشته ← متحكمه (Binding). الدالة بأقواس `{ }` لا بسهم (انظر 5.3).
- **الحزم:** get
- **يعتمد على:** `account_type_controller`، `business_setup_controller`، `check_email_controller`، `forgot_password_controller`، `link_result_controller`، `login_controller`، `new_password_controller`، `register_controller`، `reset_sent_controller`، `splash_controller`، `supplier_home_controller`، `supplier_orders_controller`، `supplier_products_controller`، `supplier_shell_controller`، `cart_controller`، `orders_controller`، `trader_home_controller`، `trader_search_controller`، `trader_shell_controller`، `app_routes`، `option_model`، `order_model`، `request_failure`، `user_model`، `account_disabled`، `account_type`، `business_setup`، `check_email`، `forgot_password`، `link_result`، `login`، `new_password`، `register`، `reset_sent`، `activity_log`، `business_profile`، `change_password`، `delete_account`، `notifications`، `splash`، `incoming_order`، `product_form`، `supplier_shell`، `category_products`، `compare`، `order_failed`، `order_review`، `order_sent`، `product_details`، `purchase_details`، `supplier_page`، `trader_shell`

### core/class — أنواع وأدوات عامة

#### 5. `countdown_mixin.dart`

- **المسار:** `C:\shahbandar\lib\core\class\countdown_mixin.dart`
- **الأسطر:** 40
- **الغرض:** عدّاد تنازلي لأزرار "إعادة الإرسال" (FR-7: حد لعدد الطلبات). يُضاف لأي متحكم بـ `with CountdownMixin`، ويُلغى تلقائياً عند إغلاق الشاشة.

| النوع | الاسم | الوصف |
|---|---|---|
| Mixin | `CountdownMixin` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `CountdownMixin.countdownText` | بصيغة 0:45 |

- **الحزم:** get

#### 6. `logo_picker_mixin.dart`

- **المسار:** `C:\shahbandar\lib\core\class\logo_picker_mixin.dart`
- **الأسطر:** 53
- **الغرض:** شعار النشاط (A7 إنشاء الحساب، D3 الملف التجاري): اختيار صورة من الجهاز، ورفعها، وحذفها. المتحكم يستخدم [logoUrl] عند الحفظ.
- **الحزم:** get
- **يعتمد على:** `media_data`، `pick_image`، `show_message`

#### 7. `status_request.dart`

- **المسار:** `C:\shahbandar\lib\core\class\status_request.dart`
- **الأسطر:** 3
- **الغرض:** حالة أي عملية في التطبيق. كل متحكم يحمل متغيراً منها، والواجهة ترسم حسبه.

### core/constant — الثوابت والهوية

#### 8. `app_color.dart`

- **المسار:** `C:\shahbandar\lib\core\constant\app_color.dart`
- **الأسطر:** 38
- **الغرض:** ألوان هوية شاهبندر. لا يُكتب أي لون مباشرة داخل الواجهات، بل من هنا فقط. كل لون نص هنا يحقق تباين 4.5:1 على الأقل فوق الخلفية المقصودة له.
- **الحزم:** flutter

#### 9. `app_layout.dart`

- **المسار:** `C:\shahbandar\lib\core\constant\app_layout.dart`
- **الأسطر:** 18
- **الغرض:** قياسات التخطيط المشتركة، حتى يعمل التطبيق على كل المقاسات: هاتف صغير، هاتف كبير، تابلت، ونافذة Windows.

#### 10. `app_routes.dart`

- **المسار:** `C:\shahbandar\lib\core\constant\app_routes.dart`
- **الأسطر:** 45
- **الغرض:** أسماء المسارات في مكان واحد. لا يُكتب نص مسار داخل أي شاشة.

#### 11. `app_theme.dart`

- **المسار:** `C:\shahbandar\lib\core\constant\app_theme.dart`
- **الأسطر:** 48
- **الغرض:** سمة التطبيق: الخط والألوان الأساسية. أشكال الحقول والأزرار في core/shared حتى تبقى موحّدة.
- **الحزم:** flutter
- **يعتمد على:** `app_color`

#### 12. `image_asset.dart`

- **المسار:** `C:\shahbandar\lib\core\constant\image_asset.dart`
- **الأسطر:** 8
- **الغرض:** مسارات الصور المحلية، مطابقة لقسم assets في pubspec.yaml.

### core/functions — دوال مساعدة

#### 13. `first_where_or_null.dart`

- **المسار:** `C:\shahbandar\lib\core\functions\first_where_or_null.dart`
- **الأسطر:** 9
- **الغرض:** دالة محلية تبحث عن أول عنصر يحقق شرطاً أو ترجع null، بلا اعتماد على إصدار GetX أو collection (انظر 5.14).

#### 14. `format_money.dart`

- **المسار:** `C:\shahbandar\lib\core\functions\format_money.dart`
- **الأسطر:** 54
- **الغرض:** المبلغ مع عملته. الأرقام لاتينية دائماً لتسهل قراءة الأسعار. دولار:  $1,214.00 (معزول باتجاه LTR حتى لا تنقلب العلامة داخل النص العربي) ليرة:   6,125,000 ل.س  |  SYP 6,125,000

| النوع | الاسم | الوصف |
|---|---|---|
| دالة | `formatMoney` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| دالة | `currencyName` | اسم العملة للعرض في الفلاتر والأزرار. |
| دالة | `formatCount` | عدد صحيح بفواصل الآلاف: 1,250 |
| دالة | `formatDate` | 22 تشرين الأول 2026  \|  22 Oct 2026 |
| دالة | `formatDateTime` | 22 تشرين الأول 2026، 10:30 |
| دالة | `formatAgo` | منذ متى: "قبل 10 د"، "قبل 2 س"، وبعد يوم التاريخ. |

- **الحزم:** get، intl
- **يعتمد على:** `product_model`

#### 15. `home_route.dart`

- **المسار:** `C:\shahbandar\lib\core\functions\home_route.dart`
- **الأسطر:** 15
- **الغرض:** إلى أين يذهب المستخدم الآن؟ تستخدمها A1 وA2 وA5 وA6 وA7، فالقاعدة مكتوبة مرة واحدة.  الترتيب = ترتيب مراحل التسجيل: موقوف ← البريد ← الأدوار ← الملف ← اللوحة.
- **يعتمد على:** `user_model`، `app_routes`

#### 16. `pick_image.dart`

- **المسار:** `C:\shahbandar\lib\core\functions\pick_image.dart`
- **الأسطر:** 119
- **الغرض:** يطلب من المستخدم صورة أو أكثر (حتى [max]): على الهاتف تظهر نافذة "المعرض أو الكاميرا"، ثم تُضغط الصورة (1600 بكسل، جودة 85) ويُتحقق من نوعها وحجمها. يرجع قائمة فارغة إن ألغى المستخدم.
- **أنواع داخلية/مساعدة:** `_chooseSource`
- **الحزم:** flutter، get، image_picker
- **يعتمد على:** `picked_image`، `app_color`، `show_message`

#### 17. `show_message.dart`

- **المسار:** `C:\shahbandar\lib\core\functions\show_message.dart`
- **الأسطر:** 23
- **الغرض:** رسالة قصيرة أسفل الشاشة (تأكيد نجاح، أو تنبيه بسيط).
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`

#### 18. `valid_input.dart`

- **المسار:** `C:\shahbandar\lib\core\functions\valid_input.dart`
- **الأسطر:** 48
- **الغرض:** شرط واحد من شروط كلمة المرور، يُعرض في القائمة الحية (A3، A10).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `PasswordRule` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `ValidInput` | قواعد التحقق. كل دالة ترجع نص الخطأ، أو null إن كانت القيمة سليمة. |
| ↳ عضو | `ValidInput.optionalEmail` | بريد اختياري: فارغ مقبول، وإن كُتب يجب أن يكون صحيحاً. |
| ↳ عضو | `ValidInput.optionalPhone` | رقم هاتف سوري بدون +963: تسعة أرقام تبدأ بـ 9. فارغ مقبول. |

- **الحزم:** get

### core/localization — اللغة والترجمة

#### 19. `locale_controller.dart`

- **المسار:** `C:\shahbandar\lib\core\localization\locale_controller.dart`
- **الأسطر:** 32
- **الغرض:** لغة التطبيق. 1. اللغة المحفوظة إن اختارها المستخدم من قبل. 2. وإلا لغة الهاتف: الإنجليزية إن كانت، والعربية في كل حالة أخرى.
- **الحزم:** flutter، get
- **يعتمد على:** `services`

#### 20. `translation.dart`

- **المسار:** `C:\shahbandar\lib\core\localization\translation.dart`
- **الأسطر:** 1435
- **الغرض:** نصوص التطبيق باللغتين، مجمّعة حسب الشاشة. الاستخدام: 'loginTitle'.tr — ومع متغيرات: 'resendIn'.trParams({'t': '0:45'})
- **الحزم:** get

### core/services — الخدمات الدائمة

#### 21. `admin_services.dart`

- **المسار:** `C:\shahbandar\lib\core\services\admin_services.dart`
- **الأسطر:** 17
- **الغرض:** خدمات لوحة الإدارة فقط (تُستدعى من main_admin.dart). لا تحتاج سلة ولا كتالوج التطبيق.
- **الحزم:** get
- **يعتمد على:** `admin_data`، `mock_admin_data`، `locale_controller`، `services`

#### 22. `cart_service.dart`

- **المسار:** `C:\shahbandar\lib\core\services\cart_service.dart`
- **الأسطر:** 70
- **الغرض:** سلة التاجر (FR-33 إلى FR-37). متاحة من أي شاشة، والعدّاد على أيقونة السلة يتحدث تلقائياً.  في هذه المرحلة السلة في الذاكرة فقط. عند ربط الخادم تُحفظ في حسابه، ويبقى شكل هذه الخدمة كما هو.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `CartService` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `CartService.count` | عدد الأصناف (لا مجموع الكميات)، لعدّاد الأيقونة. |
| ↳ عضو | `CartService.add` | إضافة منتج، أو تعديل كميته إن كان في السلة أصلاً. |

- **الحزم:** get
- **يعتمد على:** `cart_item_model`، `product_model`، `first_where_or_null`

#### 23. `compare_service.dart`

- **المسار:** `C:\shahbandar\lib\core\services\compare_service.dart`
- **الأسطر:** 50
- **الغرض:** قائمة المقارنة (FR-31): من 2 إلى 4 منتجات من التصنيف نفسه.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `CompareService` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `CompareService.cheapestId` | "الأقل سعراً" يظهر فقط حين تكون كل المنتجات بعملة واحدة، لأننا لا نحوّل بين الدولار والليرة. |

- **أنواع داخلية/مساعدة:** `CompareAddResult`
- **الحزم:** get
- **يعتمد على:** `product_model`

#### 24. `local_image_cache.dart`

- **المسار:** `C:\shahbandar\lib\core\services\local_image_cache.dart`
- **الأسطر:** 21
- **الغرض:** صور محفوظة في الذاكرة بعنوان يبدأ بـ local://  الآن: الرفع الوهمي يضع الصورة هنا ويرجع عنوانها، فتظهر الصورة الحقيقية التي اختارها المستخدم في كل الشاشات (السلة، البحث، صفحة المورد...). لاحقاً: الخادم يرجع رابط https، و[AppImage] يعرضه من الشبكة تلقائياً.

#### 25. `notification_center.dart`

- **المسار:** `C:\shahbandar\lib\core\services\notification_center.dart`
- **الأسطر:** 22
- **الغرض:** عدد الإشعارات غير المقروءة للوضع الحالي، لنقطة الجرس وسطر "الإشعارات" في حسابي. يتحدث عند فتح اللوحة، وبعد الرجوع من شاشة الإشعارات.
- **الحزم:** get
- **يعتمد على:** `account_data`، `user_model`

#### 26. `services.dart`

- **المسار:** `C:\shahbandar\lib\core\services\services.dart`
- **الأسطر:** 55
- **الغرض:** الإعدادات العامة غير الحساسة (اللغة...).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `MyServices` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| دالة | `initialServices` | تُستدعى مرة واحدة في main قبل تشغيل التطبيق. الترتيب مهم. |

- **الحزم:** get، shared_preferences
- **يعتمد على:** `account_data`، `auth_data`، `catalog_data`، `mock_account_data`، `mock_auth_data`، `media_data`، `mock_catalog_data`، `mock_media_data`، `mock_order_data`، `mock_supplier_data`، `order_data`، `supplier_data`، `locale_controller`، `cart_service`، `compare_service`، `notification_center`، `session_service`

#### 27. `session_service.dart`

- **المسار:** `C:\shahbandar\lib\core\services\session_service.dart`
- **الأسطر:** 34
- **الغرض:** جلسة المستخدم الحالية.  في مرحلة البيانات الوهمية نحفظ البريد فقط، حتى تتجاوز شاشة البداية تسجيل الدخول عند الفتح التالي. عند ربط الخادم نحفظ هنا Refresh Token بشكل مشفّر بدل البريد، ولا يتغير شيء في الشاشات.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SessionService` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `SessionService.update` | بعد أي تغيير على المستخدم (تفعيل البريد، الأدوار، الملف التجاري). |

- **الحزم:** get، shared_preferences
- **يعتمد على:** `user_model`

### core/shared — مكوّنات الواجهة المشتركة

#### 28. `app_button.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\app_button.dart`
- **الأسطر:** 94
- **الغرض:** primary: البرتقالي، لإجراء رئيسي واحد في الشاشة. secondary: أبيض بحدّ رمادي، للإجراء البديل. danger: أحمر، للإجراءات التي لا تُعكس.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `AppButtonStyle` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `AppButton` | الزر الموحّد: ارتفاع 52، زوايا 16، حالة تحميل تمنع الضغط المزدوج. onPressed = null ← الزر معطّل (رمادي). |
| فئة | `AppTextLink` | رابط نصي بالبرتقالي العميق، مساحة لمسه 48. |

- **الحزم:** flutter
- **يعتمد على:** `app_color`، `app_theme`

#### 29. `app_image.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\app_image.dart`
- **الأسطر:** 36
- **الغرض:** يعرض صورة من أي عنوان: https://...  ← من الشبكة (بعد ربط الخادم) local://...  ← صورة اختارها المستخدم ورُفعت رفعاً وهمياً وإن لم توجد الصورة أو فشل تحميلها يظهر [placeholder].
- **الحزم:** flutter
- **يعتمد على:** `local_image_cache`

#### 30. `app_select_field.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\app_select_field.dart`
- **الأسطر:** 216
- **الغرض:** حقل اختيار من قائمة ثابتة (FR-14: لا يكتب المستخدم قيمة جديدة). شكله مثل AppTextField، والضغط عليه يفتح نافذة سفلية بالخيارات.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AppSelectField` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `OptionTile` | سطر خيار عام: دائرة اختيار + نص، والمحدد بخلفية برتقالية خفيفة. |

- **أنواع داخلية/مساعدة:** `_OptionsSheet`
- **الحزم:** flutter، get
- **يعتمد على:** `option_model`، `app_color`

#### 31. `app_text_field.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\app_text_field.dart`
- **الأسطر:** 142
- **الغرض:** الحقل الموحّد في كل التطبيق. - العنوان فوق الحقل دائماً (لا يختفي عند الكتابة). - حدّ رمادي، يصير كحلياً سميكاً عند التركيز، وأحمر عند الخطأ. - الخطأ يظهر تحت الحقل نفسه.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AppTextField` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `PasswordToggle` | زر إظهار وإخفاء كلمة المرور، يوضع في [AppTextField.suffix]. |

- **الحزم:** flutter، get
- **يعتمد على:** `app_color`

#### 32. `form_error_banner.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\form_error_banner.dart`
- **الأسطر:** 41
- **الغرض:** خطأ عام للنموذج (ليس خاصاً بحقل واحد)، يُعلَن لقارئ الشاشة فور ظهوره.
- **الحزم:** flutter
- **يعتمد على:** `app_color`

#### 33. `info_note.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\info_note.dart`
- **الأسطر:** 39
- **الغرض:** ملاحظة رمادية هادئة بأيقونة (معلومة تساعد، لا تحذير).
- **الحزم:** flutter
- **يعتمد على:** `app_color`

#### 34. `language_sheet.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\language_sheet.dart`
- **الأسطر:** 65
- **الغرض:** A12 نافذة اللغة. تُفتح من تسجيل الدخول، ولاحقاً من "حسابي". اسم كل لغة مكتوب بلغته، والاختيار يقلب الواجهة واتجاهها فوراً.
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `locale_controller`، `app_select_field`

#### 35. `logo_picker_field.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\logo_picker_field.dart`
- **الأسطر:** 111
- **الغرض:** حقل شعار النشاط: مربع 72 يعرض الشعار الذي رفعه المستخدم، أو أيقونة "إضافة صورة". أثناء الرفع تظهر النسبة فوق الصورة. بعد الرفع: "تغيير" و"حذف".
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_image`

#### 36. `max_width.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\max_width.dart`
- **الأسطر:** 25
- **الغرض:** يحدّ عرض المحتوى ويضعه في المنتصف. على الهاتف لا يغيّر شيئاً، وعلى التابلت وWindows يمنع تمدد النماذج على كامل عرض الشاشة.
- **الحزم:** flutter
- **يعتمد على:** `app_layout`

#### 37. `notification_bell.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\notification_bell.dart`
- **الأسطر:** 36
- **الغرض:** جرس الإشعارات في رأس اللوحتين، مع نقطة برتقالية حين يوجد غير مقروء.
- **الحزم:** flutter، get
- **يعتمد على:** `user_model`، `app_color`، `app_routes`، `notification_center`

#### 38. `order_slip.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\order_slip.dart`
- **الأسطر:** 101
- **الغرض:** "قسيمة الطلب": العنصر المميّز لشاهبندر. بطاقة بيضاء لكل مورد، يفصل رأسها عن محتواها خط مثقّب بنصفي دائرة على الجانبين، كإيصال يُقتطع. تظهر في السلة والمراجعة وتأكيد الإرسال وتفاصيل الطلب.
- **أنواع داخلية/مساعدة:** `_Perforation`، `_DashPainter`
- **الحزم:** flutter
- **يعتمد على:** `app_color`

#### 39. `password_rules_view.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\password_rules_view.dart`
- **الأسطر:** 64
- **الغرض:** قائمة شروط كلمة المرور، تتحقق أثناء الكتابة (A3، A10). كل شرط يتحول من دائرة رمادية إلى علامة خضراء عند تحققه.
- **أنواع داخلية/مساعدة:** `_RuleRow`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `valid_input`

#### 40. `quantity_stepper.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\quantity_stepper.dart`
- **الأسطر:** 119
- **الغرض:** محدد الكمية: − العدد +. الضغط على العدد يفتح حقلاً لكتابة الكمية مباشرة، لأن كميات الجملة كبيرة (من 30 إلى 100 بالضغط وحده مرهق). الزر يتعطل عند الحد الأدنى أو الأعلى.
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_button`

#### 41. `state_views.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\state_views.dart`
- **الأسطر:** 102
- **الغرض:** مؤشر تحميل في منتصف المساحة.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `LoadingView` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `EmptyView` | حالة فارغة أو خطأ: أيقونة في دائرة، عنوان، شرح، وإجراء اختياري. |
| فئة | `ErrorView` | تعذّر التحميل، مع زر إعادة المحاولة. |

- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_button`

#### 42. `status_chip.dart`

- **المسار:** `C:\shahbandar\lib\core\shared\status_chip.dart`
- **الأسطر:** 77
- **الغرض:** شارة حالة الطلب الفرعي: لون + أيقونة + نص، حتى لا يعتمد المعنى على اللون وحده.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `StatusChip` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `PurchaseStatusChip` | شارة الحالة العامة لعملية الشراء (FR-54). |

- **أنواع داخلية/مساعدة:** `_Chip`
- **الحزم:** flutter، get
- **يعتمد على:** `order_model`، `app_color`

### data/model — نماذج البيانات

#### 43. `activity_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\activity_model.dart`
- **الأسطر:** 31
- **الغرض:** تصنيف السجل، لفلاتر "الطلبات" و"الحساب".

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `ActivityType` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| تعداد | `ActivityIcon` | أيقونة كل حدث. |
| فئة | `ActivityEntry` | حدث في سجل النشاط (FR-59). للعرض فقط، ولا يُعدَّل. |
| فئة | `DeletionRequest` | طلب حذف الحساب (FR-60). يراجعه الأدمن، ويبقى الحساب يعمل حتى الموافقة. |

#### 44. `admin_models.dart`

- **المسار:** `C:\shahbandar\lib\data\model\admin_models.dart`
- **الأسطر:** 246
- **الغرض:** نماذج لوحة الإدارة: المستخدم والمنتج والطلب والفئة وطلب الحذف وسطر التدقيق والمؤشرات، مع حالاتها (Enums).
- **أنواع داخلية/مساعدة:** `AdminUserStatus`، `AdminUser`، `AdminProductStatus`، `AdminProduct`، `AdminOrder`، `CategoryKind`، `AdminCategory`، `DeletionState`، `AdminDeletion`، `AuditType`، `AuditResult`، `AuditEntry`، `AdminStats`
- **يعتمد على:** `order_model`، `product_model`، `user_model`

#### 45. `auth_failure.dart`

- **المسار:** `C:\shahbandar\lib\data\model\auth_failure.dart`
- **الأسطر:** 22
- **الغرض:** أنواع الرفض في عمليات الحساب. المتحكم يحوّل كلاً منها إلى رسالة واضحة.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `AuthFailureType` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `AuthFailure` | تُرمى من مصدر البيانات (الوهمي الآن، والخادم لاحقاً). |

#### 46. `business_profile_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\business_profile_model.dart`
- **الأسطر:** 40
- **الغرض:** الملف التجاري (FR-11 إلى FR-14).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `BusinessProfileModel` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `BusinessProfileModel.hasContact` | وسيلة تواصل واحدة على الأقل (FR-13). |

#### 47. `cart_item_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\cart_item_model.dart`
- **الأسطر:** 52
- **الغرض:** صنف في السلة: المنتج + الكمية (FR-33 إلى FR-37).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `CartItemModel` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| تعداد | `CartIssueType` | مشكلة في صنف اكتُشفت عند إعادة التحقق قبل الطلب (FR-38 إلى FR-40). |
| فئة | `PriceChange` | تغيّر سعر منتج في السلة منذ إضافته (FR-39). |
| فئة | `CartValidation` | نتيجة إعادة التحقق من السلة. |

- **أنواع داخلية/مساعدة:** `CartIssue`
- **يعتمد على:** `product_model`

#### 48. `incoming_order_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\incoming_order_model.dart`
- **الأسطر:** 99
- **الغرض:** طلب وارد كما يراه المورد: الطلب الفرعي نفسه + بيانات التاجر + سجل المراحل. [sub] هو نفس كائن الطلب الفرعي عند التاجر، فأي تغيير هنا يظهر عنده.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `IncomingOrder` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `IncomingOrder.hasStock` | هل يكفي المخزون لهذا السطر؟ (null = لم يُحمَّل بعد) |
| فئة | `StockShortage` | صنف لا يكفي مخزونه لقبول الطلب (C5). |
| فئة | `AcceptFailure` | يُرمى من accept() حين لا يكفي المخزون. لا يُخصم شيء (FR-47). |
| فئة | `SupplierDashboard` | ملخص لوحة المورد (C1). |

- **يعتمد على:** `order_model`، `product_model`

#### 49. `notification_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\notification_model.dart`
- **الأسطر:** 38
- **الغرض:** نوع الإشعار، ومنه تُختار الأيقونة واللون.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `NotificationKind` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| تعداد | `NotificationTarget` | أين يذهب المستخدم عند الضغط على الإشعار. |
| فئة | `AppNotification` | إشعار داخل التطبيق (FR-56 إلى FR-58). النص مفاتيح ترجمة + قيم، حتى يتبع لغة الواجهة عند تغييرها. |

- **يعتمد على:** `user_model`

#### 50. `option_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\option_model.dart`
- **الأسطر:** 20
- **الغرض:** عنصر قائمة اختيار (نوع النشاط، المدينة...) باللغتين.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `OptionModel` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `OptionModel.label` | الاسم بلغة الواجهة الحالية. |

- **الحزم:** get

#### 51. `order_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\order_model.dart`
- **الأسطر:** 93
- **الغرض:** حالات الطلب الفرعي (FR-45).

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `SubOrderStatus` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `OrderLine` | سطر في الطلب: نسخة ثابتة من المنتج والسعر لحظة الطلب (FR-44). |
| فئة | `SubOrder` | طلب فرعي لمورد واحد (FR-42). |
| ↳ عضو | `SubOrder.canCancel` | FR-50: الإلغاء قبل قرار المورد فقط. |
| ↳ عضو | `SubOrder.isClosed` | انتهى بلا تنفيذ (FR-51: يبقى في السجل ولا يُعاد فتحه). |
| تعداد | `PurchaseStatus` | الحالة العامة لعملية الشراء، محسوبة من طلباتها الفرعية (FR-54). |
| فئة | `Purchase` | عملية الشراء الرئيسية (FR-42). |

- **يعتمد على:** `product_model`

#### 52. `picked_image.dart`

- **المسار:** `C:\shahbandar\lib\data\model\picked_image.dart`
- **الأسطر:** 15
- **الغرض:** صورة اختارها المستخدم من المعرض أو التقطها بالكاميرا، جاهزة للعرض والرفع. نحتفظ بالبايتات لا بالمسار، حتى تعمل على أندرويد وWindows والويب بنفس الطريقة.

#### 53. `product_draft.dart`

- **المسار:** `C:\shahbandar\lib\data\model\product_draft.dart`
- **الأسطر:** 37
- **الغرض:** ما يكتبه المورد في نموذج المنتج (C8 إضافة، C9 تعديل). [id] فارغ ← منتج جديد.
- **يعتمد على:** `product_model`

#### 54. `product_filter.dart`

- **المسار:** `C:\shahbandar\lib\data\model\product_filter.dart`
- **الأسطر:** 57
- **الغرض:** خيارات الترتيب (FR-29).

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `ProductSort` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `ProductFilter` | معايير البحث والفلترة مجتمعة (FR-26 إلى FR-28). |
| ↳ عضو | `ProductFilter.activeCount` | عدد الفلاتر المفعّلة (بدون البحث والترتيب). |
| ↳ عضو | `ProductFilter.cleared` | يبقي البحث والترتيب ويمسح الفلاتر. |

- **يعتمد على:** `product_model`

#### 55. `product_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\product_model.dart`
- **الأسطر:** 89
- **الغرض:** العملتان المعتمدتان. كل منتج بعملة يحددها مورده، ولا تحويل بينهما.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `Currency` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `ProductModel` | منتج كما يراه التاجر (FR-16، FR-17، FR-21). |
| ↳ عضو | `ProductModel.coverImage` | الصورة الأولى إن رفع المورد صوراً. |
| ↳ عضو | `ProductModel.orderable` | هل يمكن طلب الحد الأدنى من المخزون الحالي؟ |

#### 56. `request_failure.dart`

- **المسار:** `C:\shahbandar\lib\data\model\request_failure.dart`
- **الأسطر:** 10
- **الغرض:** رفض في عمليات الكتالوج والطلبات.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `RequestFailureType` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `RequestFailure` | تُرمى من مصادر البيانات (الوهمية الآن، والخادم لاحقاً). |

#### 57. `supplier_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\supplier_model.dart`
- **الأسطر:** 32
- **الغرض:** المورد كما يظهر في صفحته (FR-32).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SupplierModel` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `SupplierModel.initial` | الحرف الأول من الاسم بعد كلمة "شركة" أو "مؤسسة" أو "مجموعة"، للشعار المؤقت. |

#### 58. `user_model.dart`

- **المسار:** `C:\shahbandar\lib\data\model\user_model.dart`
- **الأسطر:** 92
- **الغرض:** حالة الحساب (FR-9).

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `AccountStatus` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| تعداد | `UserRole` | الأدوار داخل تطبيق الهاتف (FR-10). الأدمن في لوحة الويب فقط. |
| فئة | `UserModel` | بيانات المستخدم التي نحتاجها لتوجيهه بين الشاشات. |
| ↳ عضو | `UserModel.homeRole` | دور واحد ← هو. الدوران ← آخر وضع استخدمه، وإلا التاجر. |

### data/datasource — العقود ومصادر البيانات الوهمية

#### 59. `account_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\account_data.dart`
- **الأسطر:** 34
- **الغرض:** العقد للواجهات المشتركة (D): الإشعارات، الملف التجاري، الأدوار، السجل، كلمة المرور، وطلب الحذف. كلها للمستخدم الحالي في الجلسة. الآن MockAccountData، ولاحقاً RemoteAccountData بنفس الدوال.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AccountData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `AccountData.notifications` | D1 |
| ↳ عضو | `AccountData.businessProfile` | D3 (FR-11 إلى FR-14). null = لم يُكمل الملف بعد. |
| ↳ عضو | `AccountData.activateRole` | D4 (FR-10): إضافة دور للحساب الحالي. يرجع المستخدم بعد التحديث. |
| ↳ عضو | `AccountData.activity` | D5 (FR-59) |
| ↳ عضو | `AccountData.changePassword` | D7: ترمي AuthFailure(invalidCredentials) إن كانت الحالية خاطئة. |
| ↳ عضو | `AccountData.deletionRequest` | D6 (FR-60) |

- **يعتمد على:** `activity_model`، `business_profile_model`، `notification_model`، `user_model`

#### 60. `admin_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\admin_data.dart`
- **الأسطر:** 41
- **الغرض:** العقد للوحة الإدارة (E1 إلى E10). الآن MockAdminData، ولاحقاً RemoteAdminData بنفس الدوال. كل إجراء إداري يُسجَّل في سجل التدقيق من جهة الخادم (هنا: من البيانات الوهمية). عند الفشل تُرمى AuthFailure (الدخول) أو RequestFailure.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AdminData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `AdminData.login` | E1 (FR-61) |
| ↳ عضو | `AdminData.stats` | E2 |
| ↳ عضو | `AdminData.users` | E3 / E4 (FR-62، FR-63) |
| ↳ عضو | `AdminData.products` | E5 (FR-64) |
| ↳ عضو | `AdminData.orders` | E6 (FR-65): للعرض فقط، الإدارة لا تغيّر حالة الطلبات. |
| ↳ عضو | `AdminData.categories` | E7 / E8 (FR-66، FR-67) |
| ↳ عضو | `AdminData.deletions` | E9 (FR-68) |
| ↳ عضو | `AdminData.audit` | E10 (FR-69): للقراءة فقط. |

- **يعتمد على:** `admin_models`

#### 61. `auth_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\auth_data.dart`
- **الأسطر:** 44
- **الغرض:** "العقد" لكل عمليات الحساب والدخول.  المتحكمات تعرف هذا العقد فقط، ولا تعرف إن كانت البيانات وهمية أو من الخادم. الآن: MockAuthData. لاحقاً: RemoteAuthData بنفس الدوال، ونغيّر سطراً واحداً في core/services/services.dart دون لمس أي شاشة أو متحكم.  عند الفشل تُرمى [AuthFailure] (data/model/auth_failure.dart).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AuthData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `AuthData.restoreSession` | استعادة جلسة محفوظة عند فتح التطبيق (A1). null = لا جلسة صالحة. |
| ↳ عضو | `AuthData.login` | A2 (FR-4) |
| ↳ عضو | `AuthData.register` | A3 (FR-1, FR-2) |
| ↳ عضو | `AuthData.resendVerification` | A4: إعادة إرسال رابط التفعيل (FR-7) |
| ↳ عضو | `AuthData.verifyEmail` | A5: ما يحدث عند فتح رابط التفعيل (FR-3) |
| ↳ عضو | `AuthData.setRoles` | A6 (FR-10) |
| ↳ عضو | `AuthData.saveBusinessProfile` | A7 (FR-11 إلى FR-14) |
| ↳ عضو | `AuthData.requestPasswordReset` | A8 (FR-6) |
| ↳ عضو | `AuthData.resetPassword` | A10 (FR-6) |
| ↳ عضو | `AuthData.businessCategories` | قوائم الاختيار في A7. |

- **يعتمد على:** `business_profile_model`، `option_model`، `user_model`

#### 62. `catalog_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\catalog_data.dart`
- **الأسطر:** 25
- **الغرض:** العقد لكل ما يتصفحه التاجر: التصنيفات، البحث، المنتج، المورد. الآن MockCatalogData، ولاحقاً RemoteCatalogData بنفس الدوال. عند الفشل تُرمى RequestFailure.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `CatalogData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `CatalogData.categories` | تصنيفات المنتجات المفعّلة (FR-23). |
| ↳ عضو | `CatalogData.search` | البحث والفلترة والترتيب معاً (FR-26 إلى FR-29). المنتجات الموقوفة لا تظهر (FR-22). |
| ↳ عضو | `CatalogData.product` | FR-30 |
| ↳ عضو | `CatalogData.supplier` | FR-32 |
| ↳ عضو | `CatalogData.supplierProducts` | منتجات المورد النشطة، المتوفرة أولاً ثم النافدة (FR-32). |

- **يعتمد على:** `option_model`، `product_filter`، `product_model`، `supplier_model`

#### 63. `media_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\media_data.dart`
- **الأسطر:** 9
- **الغرض:** العقد لرفع الصور (صور المنتجات، شعار النشاط). الآن MockMediaData، ولاحقاً RemoteMediaData ترفع الملف للخادم وترجع رابطه.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `MediaData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `MediaData.uploadImage` | يرفع الصورة ويرجع رابطها. [onProgress] من 0 إلى 1. |

- **يعتمد على:** `picked_image`

#### 64. `mock_account_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\mock_account_data.dart`
- **الأسطر:** 272
- **الغرض:** بيانات وهمية للواجهات المشتركة، في الذاكرة.  الإشعارات والسجل لا تُكتب يدوياً فقط: البيانات الوهمية الأخرى تضيف إليها حين يحدث شيء (إرسال طلب، قبول، رفض، تغيّر سعر...) عبر [notify] و[log]. عند ربط الخادم يصنعها الخادم نفسه، وتختفي هذه الدالتان.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `MockAccountData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `MockAccountData._visible` | إشعارات التاجر مشتركة (لأن طلبات التاجر الوهمية مشتركة)، وإشعارات المورد لحساب "الأفق" فقط. |

- **الحزم:** get
- **يعتمد على:** `session_service`، `activity_model`، `business_profile_model`، `notification_model`، `user_model`، `account_data`، `auth_data`

#### 65. `mock_admin_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\mock_admin_data.dart`
- **الأسطر:** 448
- **الغرض:** بيانات وهمية للوحة الإدارة، مستقلة عن بيانات التطبيق (لوحة الويب تعمل كبرنامج منفصل، فلا تشارك ذاكرة الهاتف).  الدخول: admin@shahbandar.test بأي كلمة مرور ما عدا "wrong". أي بريد آخر يُرفض، فلا تسجيل ذاتي للإدارة.  للتجربة: - "رامي سليمان" عنده طلب مفتوح، فزر "موافقة وحذف" معطّل (E9). - كل إيقاف أو إخفاء أو تعديل تصنيف يظهر فوراً في سجل التدقيق (E10).
- **الحزم:** shared_preferences
- **يعتمد على:** `admin_models`، `auth_failure`، `order_model`، `product_model`، `request_failure`، `user_model`، `admin_data`

#### 66. `mock_auth_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\mock_auth_data.dart`
- **الأسطر:** 204
- **الغرض:** بيانات وهمية للحساب: لا شبكة ولا خادم.  تحفظ الحسابات في SharedPreferences حتى تبقى بعد إغلاق التطبيق، فتستطيع إنشاء حساب ثم الخروج والدخول به من جديد.  حسابات جاهزة للتجربة (أي كلمة مرور تعمل معها، ما عدا "wrong"): trader@shahbandar.test     ← تاجر جاهز supplier@shahbandar.test   ← مورد جاهز both@shahbandar.test       ← تاجر ومورد new@shahbandar.test        ← بريد غير مفعّل ← A4 expired@shahbandar.test    ← بريد غير مفعّل، ورابطه منتهٍ ← A5 norole@shahbandar.test     ← لم يختر دوراً ← A6 noprofile@shahbandar.test  ← لم يكمل الملف التجاري ← A7 disabled@shahbandar.test   ← حساب موقوف ← A11 locked@shahbandar.test     ← محاولات كثيرة (30 ثانية) offline@shahbandar.test    ← لا يوجد اتصال

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `MockAuthData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_Account` | حساب وهمي: المستخدم + كلمة المرور (null = أي كلمة مرور تقبل). |

- **الحزم:** shared_preferences
- **يعتمد على:** `auth_failure`، `business_profile_model`، `option_model`، `user_model`، `auth_data`، `mock_account_data`

#### 67. `mock_catalog_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\mock_catalog_data.dart`
- **الأسطر:** 211
- **الغرض:** كتالوج وهمي: 4 موردين و13 منتجاً، ومنتج موقوف لا يظهر أبداً (FR-22).  منتجات تُظهر حالات خاصة: عدس مجروش، سكر مكعبات ← نفدا من المخزون (يظهران مع شارة، ولا يُضافان للسلة) معكرونة ← يتغير سعرها عند فتح السلة (B9: تنبيه تغيّر السعر) رز بسمتي ← ينخفض مخزونه عند التحقق قبل الطلب (B10: صنف غير صالح)

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `MockCatalogData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `MockCatalogData.applyFilter` | منطق الفلترة نفسه متاح دون انتظار، حتى تعرض نافذة الفلترة عدد النتائج مباشرة. |
| ↳ عضو | `MockCatalogData._normalize` | توحيد أشكال الحروف العربية في البحث: أ إ آ ← ا، ة ← ه، ى ← ي. |
| ↳ عضو | `MockCatalogData.supplierById` | بيانات مورد دون انتظار (للوحة المورد الوهمية). |

- **يعتمد على:** `option_model`، `product_filter`، `product_model`، `request_failure`، `supplier_model`، `catalog_data`

#### 68. `mock_media_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\mock_media_data.dart`
- **الأسطر:** 20
- **الغرض:** رفع وهمي: يحاكي التقدم ثم يحفظ الصورة الحقيقية التي اختارها المستخدم في الذاكرة ويرجع عنوانها (local://)، فتظهر هي نفسها في التطبيق. الصور تُمسح عند إغلاق التطبيق، كبقية البيانات الوهمية.
- **يعتمد على:** `local_image_cache`، `picked_image`، `media_data`

#### 69. `mock_order_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\mock_order_data.dart`
- **الأسطر:** 269
- **الغرض:** طلبات وهمية في الذاكرة (تُمسح عند إغلاق التطبيق).  للتجربة: - فتح السلة وفيها المعكرونة ← يتغير سعرها مرة واحدة (B9). - طلب الرز البسمتي ← مخزونه ينخفض إلى 5 عند التحقق (B10). - أي سطر كميته 13 بالضبط ← يفشل الإرسال كأن الاتصال انقطع (B13). - بعد 20 ثانية من الإرسال يقبل أول مورد طلبه، لترى تغيّر الحالة.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `MockOrderData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `MockOrderData.subOrdersFor` | للوحة المورد الوهمية: الطلبات الفرعية التي أرسلها التاجر لهذا المورد. الكائن نفسه مشترك، فقبول المورد أو رفضه يظهر فوراً عند التاجر. |

- **يعتمد على:** `format_money`، `activity_model`، `cart_item_model`، `notification_model`، `order_model`، `product_model`، `request_failure`، `user_model`، `mock_account_data`، `mock_catalog_data`، `order_data`

#### 70. `mock_supplier_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\mock_supplier_data.dart`
- **الأسطر:** 342
- **الغرض:** لوحة مورد وهمية، مربوطة بكتالوج التاجر وطلباته: - المنتجات هي نفسها في كتالوج التاجر: أي تعديل أو إيقاف يظهر عنده فوراً. - الطلبات التي يرسلها التاجر لـ"الأفق" تصل هنا، وقرار المورد يظهر عند التاجر.  الحسابات: supplier@shahbandar.test ← شركة الأفق (منتجات وطلبات جاهزة) أي حساب آخر بدور مورد (both@shahbandar.test، أو تاجر فعّل دور المورد من D4) ← مؤسسة النخيل (بلا منتجات، لتجربة C10)  للتجربة: طلب "مطعم بيت الشام" يطلب 220 كيس سكر خشن والمتوفر 200، فيفشل قبوله (C5). حدّث المخزون من "تحديث المخزون" ثم اقبله.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `MockSupplierData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `MockSupplierData._sid` | supplier@shahbandar.test ← الأفق. أي حساب آخر فعّل دور المورد ← النخيل (بلا منتجات). |
| ↳ عضو | `MockSupplierData._afterChange` | السجل دائماً، والإشعار للتاجر فقط إن كان الطلب من طلبات التاجر الوهمية. |

- **الحزم:** get
- **يعتمد على:** `session_service`، `activity_model`، `incoming_order_model`، `notification_model`، `option_model`، `order_model`، `product_draft`، `product_model`، `request_failure`، `user_model`، `mock_account_data`، `mock_catalog_data`، `mock_order_data`، `supplier_data`

#### 71. `order_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\order_data.dart`
- **الأسطر:** 21
- **الغرض:** العقد لطلبات التاجر. الآن MockOrderData، ولاحقاً RemoteOrderData. عند الفشل تُرمى RequestFailure.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `OrderData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `OrderData.validateCart` | إعادة التحقق من السعر والمخزون والحالة والحد الأدنى (FR-38، FR-39). |
| ↳ عضو | `OrderData.placeOrder` | إنشاء عملية شراء وطلب فرعي لكل مورد في عملية واحدة (FR-41 إلى FR-43). [requestId] يمنع إنشاء الطلب مرتين عند إعادة الإرسال (FR-55). |
| ↳ عضو | `OrderData.purchases` | FR-52 |
| ↳ عضو | `OrderData.cancelSubOrder` | FR-50 |

- **يعتمد على:** `cart_item_model`، `order_model`

#### 72. `supplier_data.dart`

- **المسار:** `C:\shahbandar\lib\data\datasource\supplier_data.dart`
- **الأسطر:** 42
- **الغرض:** العقد لكل ما يفعله المورد: الطلبات الواردة ومنتجاته. الآن MockSupplierData، ولاحقاً RemoteSupplierData بنفس الدوال. عند الفشل تُرمى RequestFailure، وعند نقص المخزون AcceptFailure.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SupplierData` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `SupplierData.dashboard` | C1 |
| ↳ عضو | `SupplierData.orders` | C2: كل طلبات المورد. |
| ↳ عضو | `SupplierData.order` | C3 / C6: الطلب مع المخزون الحالي لكل صنف. |
| ↳ عضو | `SupplierData.accept` | FR-46، FR-47: يتحقق من المخزون ويخصمه مرة واحدة، أو يرمي AcceptFailure. |
| ↳ عضو | `SupplierData.reject` | FR-48: السبب اختياري. |
| ↳ عضو | `SupplierData.advance` | FR-49: مقبول ← قيد التجهيز ← مكتمل. |
| ↳ عضو | `SupplierData.myProducts` | C7: كل منتجات المورد، المنشورة والموقوفة. |
| ↳ عضو | `SupplierData.saveProduct` | C8 / C9 (FR-16 إلى FR-20) |
| ↳ عضو | `SupplierData.setActive` | نشر أو إيقاف (FR-22) |

- **يعتمد على:** `incoming_order_model`، `option_model`، `product_draft`، `product_model`

### controller — متحكمات عامة

#### 73. `home_placeholder_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\home_placeholder_controller.dart`
- **الأسطر:** 18
- **الغرض:** متحكم مؤقت للوحتي التاجر والمورد حتى نبنيهما. يسمح بتسجيل الخروج لتجربة رحلة الحساب من جديد.
- **الحزم:** get
- **يعتمد على:** `app_routes`، `session_service`

#### 74. `splash_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\splash_controller.dart`
- **الأسطر:** 39
- **الغرض:** A1: هل توجد جلسة محفوظة؟ وإلى أين نذهب؟

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SplashController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `SplashController._go` | نحذف شاشة البداية من السجل، فزر الرجوع لا يعيد إليها. |

- **الحزم:** flutter_native_splash، get
- **يعتمد على:** `app_routes`، `home_route`، `session_service`، `auth_data`

### controller/auth — متحكمات رحلة الحساب (A)

#### 75. `account_type_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\account_type_controller.dart`
- **الأسطر:** 45
- **الغرض:** A6 اختيار الأدوار (FR-10): دور أو الاثنين، بنفس الحساب.
- **الحزم:** get
- **يعتمد على:** `status_request`، `app_routes`، `show_message`، `session_service`، `auth_data`، `auth_failure`، `user_model`

#### 76. `business_setup_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\business_setup_controller.dart`
- **الأسطر:** 109
- **الغرض:** A7 الملف التجاري لأول مرة (FR-11 إلى FR-14).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `BusinessSetupController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `BusinessSetupController.hasContact` | FR-13: وسيلة تواصل واحدة على الأقل. |

- **الحزم:** flutter، get
- **يعتمد على:** `logo_picker_mixin`، `status_request`، `home_route`، `show_message`، `session_service`، `auth_data`، `auth_failure`، `business_profile_model`، `option_model`

#### 77. `check_email_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\check_email_controller.dart`
- **الأسطر:** 48
- **الغرض:** A4 تفعيل البريد: الرابط أُرسل (FR-3، FR-7).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `CheckEmailController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `CheckEmailController.openMailApp` | في مرحلة البيانات الوهمية: نحاكي أن المستخدم فتح الرابط من بريده. عند الربط الحقيقي: يفتح تطبيق البريد، والرابط يعيد المستخدم إلى A5. |
| ↳ عضو | `CheckEmailController.changeEmail` | يخرج من الحساب غير المفعّل ويعود لإنشاء حساب ببريد آخر. |

- **الحزم:** get
- **يعتمد على:** `countdown_mixin`، `app_routes`، `show_message`، `session_service`، `auth_data`

#### 78. `forgot_password_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\forgot_password_controller.dart`
- **الأسطر:** 56
- **الغرض:** A8 استعادة كلمة المرور: إدخال البريد (FR-6، جدول 9.13).
- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `app_routes`، `show_message`، `auth_data`، `auth_failure`

#### 79. `link_result_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\link_result_controller.dart`
- **الأسطر:** 61
- **الغرض:** حالات فتح رابط التفعيل.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `LinkState` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `LinkResultController` | A5 نتيجة فتح رابط التفعيل (FR-3). |
| ↳ عضو | `LinkResultController.onPrimary` | الزر الوحيد في الشاشة، ووظيفته حسب الحالة. |

- **الحزم:** get
- **يعتمد على:** `app_routes`، `home_route`، `session_service`، `auth_data`، `auth_failure`

#### 80. `login_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\login_controller.dart`
- **الأسطر:** 125
- **الغرض:** A2 تسجيل الدخول.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `LoginController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `LoginController.canSubmit` | قرار ب2: الزر معطّل حتى يُملأ الحقلان. |
| ↳ عضو | `LoginController.goToForgotPassword` | نمرر البريد المكتوب حتى لا يكتبه المستخدم مرتين. |

- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `app_routes`، `home_route`، `session_service`، `auth_data`، `auth_failure`

#### 81. `new_password_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\new_password_controller.dart`
- **الأسطر:** 61
- **الغرض:** A10 كلمة مرور جديدة (FR-6).
- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `app_routes`، `show_message`، `valid_input`، `session_service`، `auth_data`، `auth_failure`

#### 82. `register_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\register_controller.dart`
- **الأسطر:** 90
- **الغرض:** A3 إنشاء حساب (FR-1، FR-2).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `RegisterController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `RegisterController.canSubmit` | الزر معطّل حتى يُكتب البريد وتتحقق كل شروط كلمة المرور. |
| ↳ عضو | `RegisterController.validateEmail` | يجمع خطأ "مسجل مسبقاً" مع قواعد صيغة البريد. |

- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `app_routes`، `valid_input`، `session_service`، `auth_data`، `auth_failure`

#### 83. `reset_sent_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\auth\reset_sent_controller.dart`
- **الأسطر:** 36
- **الغرض:** A9 رابط الاستعادة أُرسل.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `ResetSentController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `ResetSentController.openMailApp` | في مرحلة البيانات الوهمية: نحاكي فتح رابط الاستعادة من البريد. |

- **الحزم:** get
- **يعتمد على:** `countdown_mixin`، `app_routes`، `show_message`، `auth_data`

### controller/trader — متحكمات التاجر (B)

#### 84. `cart_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\cart_controller.dart`
- **الأسطر:** 146
- **الغرض:** B9 السلة، B10 الأصناف غير الصالحة، B11 المراجعة، ثم الإرسال إلى B12 أو B13.  قبل المراجعة وقبل الإرسال نعيد التحقق من السعر والمخزون والحد الأدنى (FR-38، FR-39). أي صنف فيه مشكلة يمنع المتابعة حتى يُعدَّل أو يُحذف (FR-40).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `CartController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `CartController.useAvailable` | B10: "تعديل الكمية إلى المتوفر". |
| ↳ عضو | `CartController.maxFor` | الحد الأعلى للكمية في المحدد: المخزون، ولا يقل عن الكمية الحالية حتى لا يتجمد المحدد. |
| ↳ عضو | `CartController.minFor` | المحدد يسمح بالنزول للحد الأدنى فقط. |
| ↳ عضو | `CartController.canUseAvailable` | هل يمكن حل المشكلة بتعديل الكمية؟ (المتوفر لا يقل عن الحد الأدنى) |
| ↳ عضو | `CartController.goToReview` | B9 ← B11 |
| ↳ عضو | `CartController.placeOrder` | B11 ← B12 أو B13. وتُستدعى أيضاً من "إعادة المحاولة" في B13. |
| ↳ عضو | `CartController.backToCart` | من B13: الرجوع للسلة دون فقدان شيء. |

- **الحزم:** get
- **يعتمد على:** `app_routes`، `cart_service`، `order_data`، `cart_item_model`، `order_model`، `request_failure`

#### 85. `category_products_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\category_products_controller.dart`
- **الأسطر:** 59
- **الغرض:** B5 — منتجات تصنيف واحد (FR-23)، مع الفلترة والترتيب. يُنشأ لكل صفحة على حدة (لا يُسجَّل عاماً)، لذلك يأخذ التصنيف في الإنشاء.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `CategoryProductsController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `CategoryProductsController.activeFilters` | عدد الفلاتر المفعّلة غير التصنيف نفسه. |

- **الحزم:** get
- **يعتمد على:** `status_request`، `catalog_data`، `option_model`، `product_filter`، `product_model`، `filter_sheet`، `sort_sheet`

#### 86. `orders_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\orders_controller.dart`
- **الأسطر:** 60
- **الغرض:** فلاتر قائمة الطلبات.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `OrdersFilter` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `OrdersController` | B14 — طلباتي (FR-52): كل عمليات الشراء، الأحدث أولاً. |

- **الحزم:** get
- **يعتمد على:** `status_request`، `app_routes`، `order_data`، `order_model`

#### 87. `product_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\product_controller.dart`
- **الأسطر:** 88
- **الغرض:** B6 — تفاصيل المنتج (FR-30): الكمية، الإضافة للسلة (FR-33)، والمقارنة (FR-31).
- **الحزم:** get
- **يعتمد على:** `status_request`، `app_routes`، `show_message`، `cart_service`، `compare_service`، `catalog_data`، `product_model`، `request_failure`

#### 88. `purchase_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\purchase_controller.dart`
- **الأسطر:** 63
- **الغرض:** B15 — تفاصيل عملية الشراء وطلباتها الفرعية، وB17 حين يكون الطلب مرفوضاً أو ملغى. B16 — تأكيد الإلغاء.
- **الحزم:** get
- **يعتمد على:** `status_request`، `show_message`، `order_data`، `order_model`، `request_failure`، `cancel_dialog`

#### 89. `supplier_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\supplier_controller.dart`
- **الأسطر:** 50
- **الغرض:** B7 — صفحة المورد (FR-32): بياناته ومنتجاته النشطة.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SupplierController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `SupplierController.copy` | لا اتصال داخل التطبيق في النسخة الأولى: ننسخ الرقم أو البريد ليستخدمه التاجر. |

- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `show_message`، `catalog_data`، `product_model`، `supplier_model`

#### 90. `trader_home_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\trader_home_controller.dart`
- **الأسطر:** 61
- **الغرض:** B1 — الرئيسية: التصنيفات، أحدث المنتجات، وآخر طلب مفتوح.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `TraderHomeController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `TraderHomeController.greetingKey` | تحية حسب وقت اليوم. |

- **الحزم:** get
- **يعتمد على:** `status_request`، `catalog_data`، `order_data`، `option_model`، `order_model`، `product_filter`، `product_model`، `first_where_or_null`، `notification_center`، `user_model`

#### 91. `trader_search_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\trader_search_controller.dart`
- **الأسطر:** 99
- **الغرض:** B2 — البحث، مع B3 الفلترة وB4 الترتيب (FR-26 إلى FR-29). البحث يبدأ بعد توقف الكتابة 350ms، حتى لا يُرسل طلب مع كل حرف.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `TraderSearchController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `TraderSearchController.apply` | إزالة فلتر واحد من شرائح الفلاتر المفعّلة. |

- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `catalog_data`، `option_model`، `product_filter`، `product_model`، `filter_sheet`، `sort_sheet`، `first_where_or_null`

#### 92. `trader_shell_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\trader\trader_shell_controller.dart`
- **الأسطر:** 58
- **الغرض:** تبويبات لوحة التاجر.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `TraderTab` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `TraderShellController` | هيكل لوحة التاجر: التبويب الحالي، والتنقل بين التبويبات، وتسجيل الخروج. |
| ↳ عضو | `TraderShellController.openSearch` | من حقل البحث في الرئيسية: الانتقال لتبويب البحث مع فتح لوحة المفاتيح. |
| ↳ عضو | `TraderShellController.goHome` | العودة للرئيسية من شاشة نجاح الطلب. |

- **الحزم:** get
- **يعتمد على:** `app_routes`، `cart_service`، `compare_service`، `session_service`، `cart_controller`، `orders_controller`، `trader_home_controller`، `trader_search_controller`

### controller/supplier — متحكمات المورد (C)

#### 93. `incoming_order_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\supplier\incoming_order_controller.dart`
- **الأسطر:** 142
- **الغرض:** C3 طلب وارد (قبول/رفض)، C4 الرفض، C5 فشل القبول، C6 تحديث الحالة. شاشة واحدة يتغير محتواها حسب حالة الطلب.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `IncomingOrderController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `IncomingOrderController.advanceLabelKey` | الخطوة التالية في C6: "بدء التجهيز" ثم "تم التسليم". |
| ↳ عضو | `IncomingOrderController._onShortage` | C5: لا يكفي المخزون. "تحديث المخزون" يفتح المنتج، ثم نعيد تحميل الطلب. |
| ↳ عضو | `IncomingOrderController.openReject` | C4 |
| ↳ عضو | `IncomingOrderController.advance` | C6 |

- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `app_routes`، `show_message`، `supplier_data`، `incoming_order_model`، `order_model`، `request_failure`، `accept_failed_dialog`، `reject_sheet`

#### 94. `product_form_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\supplier\product_form_controller.dart`
- **الأسطر:** 243
- **الغرض:** صورة في النموذج: مرفوعة (لها رابط) أو جارٍ رفعها (لها نسبة تقدّم). [preview] هي الصورة التي اختارها المستخدم، تظهر فوراً قبل اكتمال الرفع.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `FormImage` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `ProductFormController` | C8 إضافة منتج، C9 تعديل منتج (FR-16 إلى FR-20). [productId] فارغ ← إضافة.  القاعدة كبقية النماذج: الأزرار معطّلة حتى تُملأ الحقول المطلوبة، والأخطاء التفصيلية تظهر بعد أول ضغطة حفظ فقط. النشر يحتاج صورة واحدة على الأقل، ولا يتاح أثناء رفع صورة. |
| ↳ عضو | `ProductFormController.addImage` | يفتح المعرض أو الكاميرا، ويرفع كل صورة مختارة (حتى يكتمل العدد 5). الصور تظهر فوراً، والرفع يجري لكل واحدة على حدة. |
| ↳ عضو | `ProductFormController.requiredFilled` | كل الحقول المطلوبة مكتوبة (بلا فحص صحتها بعد). |
| ↳ عضو | `ProductFormController.save` | C8: "نشر المنتج" (publish = true) أو "حفظ كموقوف". C9: "حفظ التعديلات". |

- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `pick_image`، `show_message`، `media_data`، `supplier_data`، `option_model`، `picked_image`، `product_draft`، `product_model`

#### 95. `supplier_home_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\supplier\supplier_home_controller.dart`
- **الأسطر:** 40
- **الغرض:** C1 — لوحة المورد: الطلبات المنتظرة، الأعداد حسب الحالة، ملخص المنتجات، آخر الطلبات.
- **الحزم:** get
- **يعتمد على:** `status_request`، `supplier_data`، `incoming_order_model`، `supplier_shell_controller`، `notification_center`، `user_model`

#### 96. `supplier_orders_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\supplier\supplier_orders_controller.dart`
- **الأسطر:** 68
- **الغرض:** فلاتر الطلبات الواردة. "مغلق" = مرفوض أو ألغاه التاجر.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `SupplierOrdersFilter` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `SupplierOrdersController` | C2 — الطلبات الواردة (FR-45). المنتظرة: الأقدم أولاً، لأن التاجر الذي ينتظر أطول أولى بالرد. البقية: الأحدث أولاً. |

- **الحزم:** get
- **يعتمد على:** `status_request`، `supplier_data`، `incoming_order_model`، `order_model`، `supplier_shell_controller`

#### 97. `supplier_products_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\supplier\supplier_products_controller.dart`
- **الأسطر:** 93
- **الغرض:** تبويبات "منتجاتي".

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `ProductsTab` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `SupplierProductsController` | C7 — منتجاتي، وC10 حين لا توجد منتجات. مفتاح النشر بجانب كل منتج يوقفه أو ينشره فوراً (FR-22). |

- **الحزم:** get
- **يعتمد على:** `status_request`، `app_routes`، `show_message`، `supplier_data`، `product_model`، `supplier_shell_controller`

#### 98. `supplier_shell_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\supplier\supplier_shell_controller.dart`
- **الأسطر:** 74
- **الغرض:** تبويبات لوحة المورد.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `SupplierTab` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `SupplierShellController` | هيكل لوحة المورد: التبويب الحالي، عدّاد الطلبات المنتظرة، وتسجيل الخروج. |
| ↳ عضو | `SupplierShellController.refreshAll` | بعد الرجوع من شاشة طلب أو منتج: تحديث كل التبويبات بصمت. |
| ↳ عضو | `SupplierShellController.openOrders` | من بطاقات اللوحة: فتح "الطلبات" على حالة معيّنة. |

- **الحزم:** get
- **يعتمد على:** `app_routes`، `session_service`، `supplier_home_controller`، `supplier_orders_controller`، `supplier_products_controller`

### controller/shared — متحكمات الواجهات المشتركة (D)

#### 99. `account_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\shared\account_controller.dart`
- **الأسطر:** 118
- **الغرض:** D2 — حسابي، مشتركة بين اللوحتين. [role] هو الوضع الحالي. الحساب بدور واحد ← بطاقة تفعيل الدور الآخر (D4). الحساب بالدورين ← بطاقة التبديل بين الوضعين.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AccountController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `AccountController.switchMode` | الدوران مفعّلان: الانتقال للوضع الآخر. |
| ↳ عضو | `AccountController.activateOther` | D4: تأكيد ثم تفعيل الدور الآخر، والانتقال إليه. |

- **الحزم:** get
- **يعتمد على:** `status_request`، `app_routes`، `home_route`، `show_message`، `locale_controller`، `cart_service`، `compare_service`، `notification_center`، `session_service`، `account_data`، `business_profile_model`، `user_model`، `activate_role_sheet`

#### 100. `activity_log_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\shared\activity_log_controller.dart`
- **الأسطر:** 55
- **الغرض:** D5 — سجل نشاطي (FR-59): للعرض فقط، مجمّع حسب اليوم.
- **أنواع داخلية/مساعدة:** `ActivityFilter`
- **الحزم:** get
- **يعتمد على:** `status_request`، `account_data`، `activity_model`

#### 101. `business_profile_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\shared\business_profile_controller.dart`
- **الأسطر:** 145
- **الغرض:** D3 — تعديل الملف التجاري (FR-11 إلى FR-14). نفس قواعد A7: الاسم والنشاط والمدينة مطلوبة، ووسيلة تواصل واحدة على الأقل. الزر معطّل حتى يتغير شيء وتكتمل الحقول المطلوبة، والأخطاء بعد أول حفظ.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `BusinessProfileController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `BusinessProfileController.validatePhone` | نفس تحقق A7 للهاتف والبريد. |

- **الحزم:** flutter، get
- **يعتمد على:** `logo_picker_mixin`، `status_request`، `first_where_or_null`، `show_message`، `valid_input`، `account_data`، `auth_data`، `business_profile_model`، `option_model`

#### 102. `change_password_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\shared\change_password_controller.dart`
- **الأسطر:** 81
- **الغرض:** D7 — تغيير كلمة المرور. نفس شروط A3/A10، وشرط إضافي: مختلفة عن الحالية. الزر معطّل حتى تُكتب الحالية وتتحقق كل الشروط.
- **الحزم:** flutter، get
- **يعتمد على:** `app_routes`، `show_message`، `valid_input`، `account_data`، `auth_failure`

#### 103. `delete_account_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\shared\delete_account_controller.dart`
- **الأسطر:** 110
- **الغرض:** D6 — طلب حذف الحساب (FR-60). لا يُحذف شيء فوراً: يُرسل طلب يراجعه الأدمن، ويبقى الحساب يعمل حتى الموافقة. إن كانت هناك طلبات مفتوحة نُنبّه أن الحذف يتأجل حتى تُغلق. الإرسال يحتاج تأكيد "أفهم أن الحذف نهائي".
- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `show_message`، `session_service`، `account_data`، `order_data`، `supplier_data`، `activity_model`، `order_model`، `user_model`

#### 104. `notifications_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\shared\notifications_controller.dart`
- **الأسطر:** 110
- **الغرض:** مجموعات الإشعارات حسب الوقت.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `NotificationGroup` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `NotificationsController` | D1 — الإشعارات: الكل / غير المقروءة، "تعليم الكل كمقروء"، والضغط على إشعار يعلّمه مقروءاً ويفتح ما يخصه. |

- **الحزم:** get
- **يعتمد على:** `status_request`، `app_routes`، `account_data`، `notification_model`، `user_model`، `supplier_shell_controller`، `trader_shell_controller`

### controller/admin — متحكمات الإدارة (E)

#### 105. `admin_login_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\admin\admin_login_controller.dart`
- **الأسطر:** 61
- **الغرض:** E1 — دخول الإدارة (FR-61). لا تسجيل ذاتي: الحسابات يُنشئها الفريق. الزر معطّل حتى يُكتب البريد وكلمة المرور، والخطأ رسالة واحدة لا تكشف أيهما الخاطئ.
- **الحزم:** flutter، get
- **يعتمد على:** `app_routes`، `admin_data`، `auth_failure`

#### 106. `admin_section_controllers.dart`

- **المسار:** `C:\shahbandar\lib\controller\admin\admin_section_controllers.dart`
- **الأسطر:** 526
- **الغرض:** أساس مشترك: حالة التحميل + بحث نصي.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `_AdminListController` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| ↳ عضو | `_AdminListController.onFilterChanged` | مثلاً لإعادة الصفحة إلى الأولى. |
| فئة | `AdminUserController` |  |
| ↳ عضو | `AdminUserController.toggleStatus` | إيقاف أو تفعيل (FR-63). الإيقاف يُخرج المستخدم فوراً ولا يمس طلباته. |
| فئة | `AdminProductsController` |  |
| ↳ عضو | `AdminProductsController.toggleHidden` | FR-64: إخفاء منتج مخالف أو إعادته. |
| فئة | `AdminCategoriesController` |  |
| ↳ عضو | `AdminCategoriesController.ordered` | الآباء بعد أبنائهم مباشرة، لعرض الشجرة في الجدول. |
| ↳ عضو | `AdminCategoriesController.parentOptions` | يصلح أباً: تصنيف رئيسي مفعّل، وليس هو نفسه. |

- **أنواع داخلية/مساعدة:** `AdminDashboardController`، `UserRoleFilter`، `UserStatusFilter`، `AdminUsersController`، `ProductStatusFilter`، `AdminOrderFilter`، `AdminOrdersController`، `AdminDeletionController`، `AuditPeriod`، `AdminAuditController`
- **الحزم:** flutter، get
- **يعتمد على:** `status_request`، `show_message`، `admin_data`، `admin_models`، `order_model`، `request_failure`، `user_model`، `admin_parts`، `admin_shell_controller`

#### 107. `admin_shell_controller.dart`

- **المسار:** `C:\shahbandar\lib\controller\admin\admin_shell_controller.dart`
- **الأسطر:** 68
- **الغرض:** أقسام الإدارة بترتيب الشريط الجانبي.

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `AdminSection` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `AdminShellController` | هيكل لوحة الإدارة: القسم الحالي، المستخدم المفتوح (E4)، وعدّاد طلبات الحذف. |

- **الحزم:** get
- **يعتمد على:** `app_routes`، `locale_controller`، `admin_data`، `admin_models`

### view/screen — شاشات عامة

#### 108. `home_placeholder.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\home_placeholder.dart`
- **الأسطر:** 49
- **الغرض:** شاشة مؤقتة للوحتي التاجر والمورد حتى نبنيهما. زر تسجيل الخروج يسمح بتجربة رحلة الحساب من جديد.
- **الحزم:** flutter، get
- **يعتمد على:** `home_placeholder_controller`، `app_color`، `app_button`، `auth_body`، `auth_title`

#### 109. `splash.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\splash.dart`
- **الأسطر:** 30
- **الغرض:** A1 شاشة البداية: ترسم الشعار فقط، والقرار في SplashController.
- **الحزم:** flutter، get
- **يعتمد على:** `splash_controller`، `app_color`، `splash_logo`

### view/screen/auth — شاشات الحساب (A)

#### 110. `account_disabled.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\account_disabled.dart`
- **الأسطر:** 95
- **الغرض:** A11 حساب موقوف (FR-9). نبرة محايدة بلا لوم، وطريق واضح للتواصل. بلا متحكم: لا حالة ولا بيانات، فقط عرض.
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_routes`، `show_message`، `app_button`، `auth_body`، `auth_illustration`، `auth_title`

#### 111. `account_type.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\account_type.dart`
- **الأسطر:** 69
- **الغرض:** A6 اختيار الأدوار: المرحلة 3 من 4. خانتا اختيار لا ثلاثة خيارات، لأن "الاثنين معاً" جمع للخيارين.
- **الحزم:** flutter، get
- **يعتمد على:** `account_type_controller`، `app_button`، `info_note`، `user_model`، `auth_body`، `auth_title`، `auth_top_bar`، `role_option_card`، `steps_indicator`

#### 112. `business_setup.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\business_setup.dart`
- **الأسطر:** 164
- **الغرض:** A7 الملف التجاري لأول مرة: المرحلة 4 من 4 (FR-11 إلى FR-14). الرجوع مسموح هنا لتعديل الأدوار.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `BusinessSetupScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_ContactSection` | FR-13: الهاتف أو البريد، واحد على الأقل. الخطأ يظهر للمجموعة كلها. |

- **الحزم:** flutter، get
- **يعتمد على:** `business_setup_controller`، `app_color`، `valid_input`، `app_button`، `app_select_field`، `app_text_field`، `logo_picker_field`، `auth_body`، `auth_title`، `auth_top_bar`، `steps_indicator`

#### 113. `check_email.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\check_email.dart`
- **الأسطر:** 78
- **الغرض:** A4 تفعيل البريد: المرحلة 2 من 4. بلا زر رجوع: الحساب أُنشئ، و"تغيير البريد" هو طريق العودة الصحيح.
- **الحزم:** flutter، get
- **يعتمد على:** `check_email_controller`، `app_color`، `app_button`، `auth_body`، `auth_illustration`، `auth_title`، `auth_top_bar`، `steps_indicator`

#### 114. `forgot_password.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\forgot_password.dart`
- **الأسطر:** 77
- **الغرض:** A8 استعادة كلمة المرور: إدخال البريد.
- **الحزم:** flutter، get
- **يعتمد على:** `forgot_password_controller`، `app_color`، `valid_input`، `app_button`، `app_text_field`، `auth_body`، `auth_title`، `auth_top_bar`

#### 115. `link_result.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\link_result.dart`
- **الأسطر:** 67
- **الغرض:** A5 نتيجة فتح رابط التفعيل: ثلاث حالات، لكل منها إجراء واحد.
- **الحزم:** flutter، get
- **يعتمد على:** `link_result_controller`، `app_color`، `app_button`، `auth_body`، `auth_illustration`، `auth_title`

#### 116. `login.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\login.dart`
- **الأسطر:** 134
- **الغرض:** A2 تسجيل الدخول: الجزء الكحلي بالأعلى، وفوقه ورقة فاتحة بزوايا 24.
- **أنواع داخلية/مساعدة:** `_LoginForm`
- **الحزم:** flutter، get
- **يعتمد على:** `login_controller`، `app_color`، `valid_input`، `app_button`، `app_text_field`، `form_error_banner`، `max_width`، `auth_body`، `auth_header`، `auth_title`

#### 117. `new_password.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\new_password.dart`
- **الأسطر:** 54
- **الغرض:** A10 كلمة مرور جديدة. تُفتح من رابط البريد، فلا زر رجوع.
- **الحزم:** flutter، get
- **يعتمد على:** `new_password_controller`، `app_button`، `app_text_field`، `password_rules_view`، `auth_body`، `auth_title`

#### 118. `register.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\register.dart`
- **الأسطر:** 129
- **الغرض:** A3 إنشاء حساب: المرحلة 1 من 4.
- **الحزم:** flutter، get
- **يعتمد على:** `register_controller`، `app_color`، `app_button`، `app_text_field`، `form_error_banner`، `password_rules_view`، `auth_body`، `auth_title`، `auth_top_bar`، `steps_indicator`

#### 119. `reset_sent.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\auth\reset_sent.dart`
- **الأسطر:** 70
- **الغرض:** A9 رابط الاستعادة أُرسل. نفس قالب A4 حتى يعرفه المستخدم من أول نظرة.
- **الحزم:** flutter، get
- **يعتمد على:** `reset_sent_controller`، `app_color`، `app_button`، `info_note`، `auth_body`، `auth_illustration`، `auth_title`، `auth_top_bar`

### view/screen/trader — شاشات التاجر (B)

#### 120. `category_products.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\category_products.dart`
- **الأسطر:** 86
- **الغرض:** B5 — منتجات تصنيف: شبكة مع الفلترة والترتيب في شريط العنوان. المتحكم محلي لهذه الصفحة (global: false)، فيمكن فتح أكثر من تصنيف فوق بعضها.
- **الحزم:** flutter، get
- **يعتمد على:** `category_products_controller`، `status_request`، `app_color`، `app_layout`، `compare_service`، `max_width`، `state_views`، `option_model`، `product_card`، `trader_parts`

#### 121. `compare.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\compare.dart`
- **الأسطر:** 167
- **الغرض:** B8 — المقارنة (FR-31): أعمدة بعرض ثابت، والصفوف متطابقة (السعر، المورد، المدينة، المخزون، الحد الأدنى). تمرير أفقي على الهاتف حين لا تتسع الأعمدة. شارة "الأقل سعراً" فقط حين تكون كل المنتجات بعملة واحدة.
- **أنواع داخلية/مساعدة:** `_Table`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_routes`، `format_money`، `compare_service`، `info_note`، `state_views`، `product_model`، `product_thumb`

#### 122. `order_failed.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\order_failed.dart`
- **الأسطر:** 75
- **الغرض:** B13 — تعذّر إرسال الطلب. يطمئن التاجر أن سلته محفوظة وأنه لم يُنشأ أي طلب، ويعرض إعادة المحاولة. إعادة المحاولة تستخدم نفس معرّف الطلب، فلا يتكرر إن كان قد وصل فعلاً (FR-55).
- **الحزم:** flutter، get
- **يعتمد على:** `cart_controller`، `app_color`، `app_button`، `info_note`، `max_width`، `request_failure`

#### 123. `order_review.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\order_review.dart`
- **الأسطر:** 138
- **الغرض:** B11 — مراجعة الطلب قبل الإرسال. قراءة فقط: قسيمة لكل مورد بأصنافها، المجاميع لكل عملة، وتنبيه أن كل مورد يقرر وحده. التعديل يكون بالرجوع للسلة.
- **أنواع داخلية/مساعدة:** `_ReviewSlip`
- **الحزم:** flutter، get
- **يعتمد على:** `cart_controller`، `app_color`، `format_money`، `app_button`، `info_note`، `max_width`، `order_slip`، `cart_item_model`، `trader_parts`

#### 124. `order_sent.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\order_sent.dart`
- **الأسطر:** 111
- **الغرض:** B12 — تم إرسال الطلب. رقم عملية الشراء، وقسيمة تسرد الموردين وكلٌّ "بانتظار الرد"، وما سيحدث بعد ذلك.
- **الحزم:** flutter، get
- **يعتمد على:** `trader_shell_controller`، `app_color`، `app_routes`، `format_money`، `app_button`، `max_width`، `order_slip`، `status_chip`، `order_model`

#### 125. `product_details.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\product_details.dart`
- **الأسطر:** 266
- **الغرض:** B6 — تفاصيل المنتج. الصورة، الاسم والسعر، المخزون والحد الأدنى، الوصف، بطاقة المورد، وفي الأسفل: الكمية + "أضف إلى السلة". على الشاشات العريضة الصورة بجانب التفاصيل.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `ProductDetailsScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_Body` |  |
| ↳ عضو | `_Body._initial` | الحرف الأول من اسم المورد دون "شركة/مؤسسة/مجموعة" وأداة التعريف. |
| فئة | `_AddBar` | شريط الإضافة: محدد الكمية + الزر. النافد أو الأقل من الحد الأدنى ← الزر معطّل مع السبب. |

- **أنواع داخلية/مساعدة:** `_Fact`
- **الحزم:** flutter، get
- **يعتمد على:** `product_controller`، `status_request`، `app_color`، `format_money`، `app_button`، `max_width`، `quantity_stepper`، `state_views`، `product_model`، `product_card`، `product_thumb`، `trader_parts`

#### 126. `purchase_details.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\purchase_details.dart`
- **الأسطر:** 251
- **الغرض:** B15 — تفاصيل عملية الشراء: قسيمة لكل مورد مع متتبّع المراحل وأصنافه. B17 — حين يُرفض طلب أو يُلغى: تظهر حالته النهائية وسبب الرفض (إن كتبه المورد)، ويبقى في السجل بلا إجراءات (FR-51). إلغاء الطلب (B16) متاح فقط وهو "بانتظار الرد".

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `PurchaseDetailsScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_ClosedNote` | B17: سبب الرفض أو تاريخ الإلغاء، بخلفية الحالة. |

- **أنواع داخلية/مساعدة:** `_Body`، `_SubOrderSlip`
- **الحزم:** flutter، get
- **يعتمد على:** `purchase_controller`، `status_request`، `app_color`، `format_money`، `app_button`، `max_width`، `order_slip`، `state_views`، `status_chip`، `order_model`، `product_thumb`، `order_tracker`، `trader_parts`

#### 127. `supplier_page.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\supplier_page.dart`
- **الأسطر:** 138
- **الغرض:** B7 — صفحة المورد: البطاقة التعريفية، وسائل التواصل (للنسخ)، ومنتجاته النشطة.
- **أنواع داخلية/مساعدة:** `_Profile`، `_ContactRow`
- **الحزم:** flutter، get
- **يعتمد على:** `supplier_controller`، `status_request`، `app_color`، `app_layout`، `max_width`، `state_views`، `supplier_model`، `product_card`، `trader_parts`

#### 128. `trader_account.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\trader_account.dart`
- **الأسطر:** 13
- **الغرض:** تبويب "حسابي" في لوحة التاجر: شاشة D2 المشتركة بوضع التاجر.
- **الحزم:** flutter
- **يعتمد على:** `user_model`، `account`

#### 129. `trader_cart.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\trader_cart.dart`
- **الأسطر:** 374
- **الغرض:** B9 — السلة، وB10 حين يكون فيها أصناف غير صالحة. قسيمة لكل مورد، لأن كل مورد يصله طلب منفصل. المجاميع لكل عملة على حدة.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `TraderCartScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_CheckoutBar` | المجاميع لكل عملة + زر المتابعة، معطّل حتى تُحل كل المشاكل. |

- **أنواع داخلية/مساعدة:** `_CartBody`، `InfoNoteLine`، `_SupplierSlip`، `_CartLine`، `_Banner`
- **الحزم:** flutter، get
- **يعتمد على:** `cart_controller`، `trader_shell_controller`، `app_color`، `app_layout`، `app_routes`، `format_money`، `cart_service`، `app_button`، `max_width`، `order_slip`، `quantity_stepper`، `state_views`، `cart_item_model`، `product_thumb`، `trader_parts`

#### 130. `trader_home.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\trader_home.dart`
- **الأسطر:** 243
- **الغرض:** B1 — الرئيسية. من الأعلى: التحية والإشعارات، حقل البحث، الطلب المفتوح (إن وجد)، التصنيفات، وصل حديثاً.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `TraderHomeScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_SearchEntry` | يبدو كحقل بحث، والضغط عليه ينقل لتبويب البحث. |
| فئة | `_ActiveOrderCard` | اختصار لآخر طلب مفتوح: رقمه، حالته، وعدد الموردين. |
| فئة | `_Categories` | التصنيفات: بطاقات متساوية تلتف حسب عرض الشاشة. |

- **الحزم:** flutter، get
- **يعتمد على:** `trader_home_controller`، `trader_shell_controller`، `status_request`، `app_color`، `app_layout`، `app_routes`، `format_money`، `max_width`، `state_views`، `status_chip`، `option_model`، `order_model`، `product_card`، `trader_parts`، `notification_bell`، `user_model`

#### 131. `trader_orders.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\trader_orders.dart`
- **الأسطر:** 173
- **الغرض:** B14 — طلباتي: عمليات الشراء مع حالة كل مورد بنظرة واحدة.
- **أنواع داخلية/مساعدة:** `_Filters`، `_PurchaseCard`
- **الحزم:** flutter، get
- **يعتمد على:** `orders_controller`، `trader_shell_controller`، `status_request`، `app_color`، `app_layout`، `format_money`، `max_width`، `state_views`، `status_chip`، `order_model`، `trader_parts`

#### 132. `trader_search.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\trader_search.dart`
- **الأسطر:** 237
- **الغرض:** B2 — البحث (FR-26) مع شريط الفلترة (B3) والترتيب (B4). الفلاتر المفعّلة تظهر شرائح يمكن إزالتها بضغطة، وعدد النتائج ظاهر دائماً.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `TraderSearchScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_ToolsRow` | زرّا الفلترة والترتيب، مع عدد الفلاتر المفعّلة على زر الفلترة. |
| فئة | `_ActiveFilters` | الفلاتر المفعّلة كشرائح قابلة للإزالة. |

- **أنواع داخلية/مساعدة:** `_SearchField`، `_ToolButton`
- **الحزم:** flutter، get
- **يعتمد على:** `trader_search_controller`، `status_request`، `app_color`، `app_layout`، `format_money`، `compare_service`، `max_width`، `state_views`، `product_filter`، `product_card`، `trader_parts`

#### 133. `trader_shell.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\trader\trader_shell.dart`
- **الأسطر:** 88
- **الغرض:** هيكل لوحة التاجر: خمسة تبويبات تحتفظ بحالتها (IndexedStack). الهاتف: شريط تنقل سفلي. الشاشات العريضة (تابلت، Windows): شريط جانبي، والمحتوى في المنتصف.
- **الحزم:** flutter، get
- **يعتمد على:** `trader_shell_controller`، `app_color`، `app_layout`، `trader_parts`، `trader_account`، `trader_cart`، `trader_home`، `trader_orders`، `trader_search`

### view/screen/supplier — شاشات المورد (C)

#### 134. `incoming_order.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\supplier\incoming_order.dart`
- **الأسطر:** 296
- **الغرض:** C3 — طلب وارد (بانتظار القرار): التاجر، الأصناف مع المخزون المتوفر لكل صنف، القيمة، ملاحظة التاجر، وزرّا "رفض" و"قبول الطلب". C6 — بعد القبول: مراحل الطلب، الأصناف، التواصل، وزر الخطوة التالية. المرفوض والمكتمل: للعرض فقط.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `IncomingOrderScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_Actions` | الشريط السفلي حسب الحالة: بانتظار القرار: رفض + قبول الطلب. مقبول/قيد التجهيز: الخطوة التالية + تلميح. غير ذلك: لا شيء. |

- **أنواع داخلية/مساعدة:** `_Body`، `_TraderCard`، `_Line`، `_Note`
- **الحزم:** flutter، get
- **يعتمد على:** `incoming_order_controller`، `status_request`، `app_color`، `format_money`، `app_button`، `max_width`، `order_slip`، `state_views`، `status_chip`، `incoming_order_model`، `order_model`، `order_timeline`، `trader_parts`

#### 135. `product_form.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\supplier\product_form.dart`
- **الأسطر:** 492
- **الغرض:** C8 — إضافة منتج، C9 — تعديل منتج. من الأعلى: الصور (حتى 5، الأولى غلاف)، الاسم، التصنيف، الوصف، السعر والعملة، المخزون والحد الأدنى، و(في التعديل) مفتاح النشر.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `ProductFormScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_Images` | الصور: الغلاف أولاً، ثم البقية، ثم زر الإضافة. الضغط على صورة يعرض خياراتها. |
| فئة | `_Price` | سعر الوحدة + العملة. السعر بأرقام لاتينية من اليسار. |
| فئة | `_Bar` | الشريط السفلي: سبب تعطيل النشر (إن وجد) ثم الأزرار. |

- **أنواع داخلية/مساعدة:** `_Form`، `_ImageTile`، `_AddTile`، `_Description`
- **الحزم:** flutter، get
- **يعتمد على:** `product_form_controller`، `status_request`، `app_color`، `first_where_or_null`، `format_money`، `app_button`، `app_image`، `app_select_field`، `app_text_field`، `max_width`، `state_views`، `product_model`، `trader_parts`

#### 136. `supplier_account.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\supplier\supplier_account.dart`
- **الأسطر:** 13
- **الغرض:** تبويب "حسابي" في لوحة المورد: شاشة D2 المشتركة بوضع المورد.
- **الحزم:** flutter
- **يعتمد على:** `user_model`، `account`

#### 137. `supplier_home.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\supplier\supplier_home.dart`
- **الأسطر:** 296
- **الغرض:** C1 — لوحة المورد. من الأعلى: الطلبات بانتظار القرار (الأهم)، الأعداد حسب الحالة، ملخص المنتجات، آخر الطلبات.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SupplierHomeScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_Content` | محتوى اللوحة بعد التحميل. |
| فئة | `_AwaitingCard` | البطاقة الداكنة: عدد الطلبات المنتظرة وعمر أقدمها. |
| فئة | `_StatusGrid` | أعداد الطلبات في أربع خانات، والضغط يفتح القائمة على تلك الحالة. |
| فئة | `_ProductsCard` | ملخص المنتجات: منشور، موقوف، نفد، مع شريط نسبة المنشور إلى الموقوف. |

- **الحزم:** flutter، get
- **يعتمد على:** `supplier_home_controller`، `supplier_orders_controller`، `supplier_shell_controller`، `status_request`، `app_color`، `app_layout`، `format_money`، `max_width`، `state_views`، `status_chip`، `incoming_order_model`، `order_model`، `supplier_parts`، `trader_parts`، `notification_bell`، `user_model`

#### 138. `supplier_orders.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\supplier\supplier_orders.dart`
- **الأسطر:** 170
- **الغرض:** C2 — الطلبات الواردة: شرائح الحالات مع أعدادها، ثم القائمة. في "بانتظار قرارك" الأقدم أولاً، ومدة الانتظار ملوّنة حسب طولها.
- **أنواع داخلية/مساعدة:** `_Filters`، `_FilterChip`
- **الحزم:** flutter، get
- **يعتمد على:** `supplier_orders_controller`، `status_request`، `app_color`، `app_layout`، `max_width`، `state_views`، `supplier_parts`

#### 139. `supplier_products.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\supplier\supplier_products.dart`
- **الأسطر:** 282
- **الغرض:** C7 — منتجاتي: تبويبات (الكل، منشور، موقوف، نفد)، صف لكل منتج مع مفتاح النشر، وزر "إضافة منتج" عائم. الضغط على المنتج يفتح التعديل (C9). C10 — حين لا توجد منتجات أصلاً: دعوة لإضافة أول منتج مع ثلاث نصائح.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SupplierProductsScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_NoProducts` | C10 — لا منتجات بعد. |

- **أنواع داخلية/مساعدة:** `_Tabs`، `_ProductRow`
- **الحزم:** flutter، get
- **يعتمد على:** `supplier_products_controller`، `status_request`، `app_color`، `app_layout`، `format_money`، `app_button`، `max_width`، `state_views`، `product_model`، `supplier_parts`، `product_thumb`

#### 140. `supplier_shell.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\supplier\supplier_shell.dart`
- **الأسطر:** 93
- **الغرض:** هيكل لوحة المورد: أربعة تبويبات تحتفظ بحالتها. الهاتف: شريط سفلي. الشاشات العريضة (تابلت، Windows): شريط جانبي. عدّاد الطلبات المنتظرة يظهر على تبويب "الطلبات".
- **الحزم:** flutter، get
- **يعتمد على:** `supplier_shell_controller`، `app_color`، `app_layout`، `supplier_account`، `supplier_home`، `supplier_orders`، `supplier_products`

### view/screen/shared — الشاشات المشتركة (D)

#### 141. `account.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\shared\account.dart`
- **الأسطر:** 282
- **الغرض:** D2 — حسابي، نفسها في لوحتي التاجر والمورد. الرأس (الشعار، الاسم، البريد، الأدوار)، ثم بطاقة الدور الآخر (تفعيل أو تبديل)، ثم ثلاث مجموعات: الملف والإشعارات والسجل / اللغة وكلمة المرور / الخروج، وأخيراً رابط طلب الحذف بالأحمر بعيداً عن الاستخدام اليومي.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AccountScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_RoleCard` | بطاقة برتقالية الإطار: تفعيل الدور الآخر (D4)، أو التبديل إليه إن كان مفعّلاً. |

- **أنواع داخلية/مساعدة:** `_Header`، `_Group`، `_Item`
- **الحزم:** flutter، get
- **يعتمد على:** `account_controller`، `status_request`، `app_color`، `notification_center`، `app_image`، `language_sheet`، `max_width`، `state_views`، `user_model`

#### 142. `activity_log.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\shared\activity_log.dart`
- **الأسطر:** 152
- **الغرض:** D5 — سجل نشاطي: فلاتر (الكل، الطلبات، الحساب)، ومجموعات حسب اليوم. للعرض فقط، مع تنبيه أمني في الأسفل.
- **أنواع داخلية/مساعدة:** `_Row`
- **الحزم:** flutter، get
- **يعتمد على:** `activity_log_controller`، `status_request`، `app_color`، `format_money`، `max_width`، `state_views`، `activity_model`

#### 143. `business_profile.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\shared\business_profile.dart`
- **الأسطر:** 169
- **الغرض:** D3 — الملف التجاري: نفس حقول A7، للتعديل في أي وقت. يظهر للطرف الآخر: التاجر في الطلبات الواردة، والمورد في صفحته.
- **أنواع داخلية/مساعدة:** `_Form`
- **الحزم:** flutter، get
- **يعتمد على:** `business_profile_controller`، `status_request`، `app_color`، `app_button`، `app_select_field`، `app_text_field`، `logo_picker_field`، `max_width`، `state_views`، `trader_parts`

#### 144. `change_password.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\shared\change_password.dart`
- **الأسطر:** 83
- **الغرض:** D7 — تغيير كلمة المرور. الحالية مع "نسيتها؟"، الجديدة مع الشروط الحية (ومنها: مختلفة عن الحالية)، وتوضيح أننا نبقيك داخلاً على هذا الجهاز ونُخرجك من الأجهزة الأخرى.
- **الحزم:** flutter، get
- **يعتمد على:** `change_password_controller`، `app_color`، `app_button`، `app_text_field`، `max_width`، `password_rules_view`، `trader_parts`

#### 145. `delete_account.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\shared\delete_account.dart`
- **الأسطر:** 190
- **الغرض:** D6 — طلب حذف الحساب. قبل الإرسال: تنبيه الطلبات المفتوحة، ماذا يحدث بعد الإرسال، سبب اختياري، وتأكيد إلزامي. بعد الإرسال: الطلب قيد المراجعة، مع إمكانية إلغائه.
- **أنواع داخلية/مساعدة:** `_Form`، `_Pending`
- **الحزم:** flutter، get
- **يعتمد على:** `delete_account_controller`، `status_request`، `app_color`، `format_money`، `app_button`، `max_width`، `state_views`، `trader_parts`

#### 146. `notifications.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\shared\notifications.dart`
- **الأسطر:** 247
- **الغرض:** D1 — الإشعارات. تبويبا "الكل" و"غير المقروءة"، ومجموعات حسب الوقت. غير المقروء: خلفية دافئة ونقطة برتقالية وعنوان عريض.
- **أنواع داخلية/مساعدة:** `_Tabs`، `_List`، `_Item`
- **الحزم:** flutter، get
- **يعتمد على:** `notifications_controller`، `status_request`، `app_color`، `format_money`، `max_width`، `state_views`، `notification_model`، `user_model`

### view/screen/admin — شاشات الإدارة (E)

#### 147. `admin_audit.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_audit.dart`
- **الأسطر:** 82
- **الغرض:** E10 — سجل التدقيق (FR-69): للقراءة فقط. بحث بالمنفّذ أو الكيان، فلتر نوع العملية، وفترة زمنية.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AdminAuditScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `AuditTable` | جدول السجل، مشترك مع المؤشرات (E2). |

- **الحزم:** flutter، get
- **يعتمد على:** `admin_section_controllers`، `status_request`، `app_color`، `state_views`، `admin_models`، `admin_chips`، `admin_parts`، `admin_table`، `admin_dashboard`

#### 148. `admin_categories.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_categories.dart`
- **الأسطر:** 188
- **الغرض:** E7 — تصنيفات المنتجات (مع تصنيف أب)، E8 — تصنيفات الأنشطة التجارية (بلا أب). نموذج إضافة/تعديل في الأعلى، وجدول تحته. لا حذف: الإيقاف يخفي التصنيف من الاختيار ويُبقي المنتجات والحسابات الحالية عليه.
- **أنواع داخلية/مساعدة:** `_Link`، `_Form`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_section_controllers`، `status_request`، `app_color`، `app_button`، `app_text_field`، `state_views`، `admin_models`، `admin_parts`، `admin_table`

#### 149. `admin_dashboard.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_dashboard.dart`
- **الأسطر:** 233
- **الغرض:** E2 — المؤشرات: ثلاث بطاقات أرقام، توزيع الطلبات على الحالات، وأحدث الأحداث. كل بطاقة تفتح قسمها.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AdminDashboardScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_OrdersBar` | شريط أفقي مقسّم بنسبة كل حالة، مع مفتاح ألوان بالأرقام (المعنى لا يعتمد على اللون وحده). |
| فئة | `AuditTableColumns` | يُستخدم هنا وفي سجل التدقيق. |
| دالة | `auditResult` | نتيجة العملية بلون وأيقونة. |

- **أنواع داخلية/مساعدة:** `_Kpis`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_section_controllers`، `admin_shell_controller`، `status_request`، `app_color`، `state_views`، `status_chip`، `admin_models`، `order_model`، `admin_chips`، `admin_parts`، `admin_table`، `admin_audit`

#### 150. `admin_deletion.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_deletion.dart`
- **الأسطر:** 140
- **الغرض:** E9 — طلبات حذف الحسابات (FR-68). "موافقة وحذف" معطّلة ما دام للمستخدم طلب مفتوح، مع السبب تحت الزر.
- **أنواع داخلية/مساعدة:** `_Decision`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_section_controllers`، `admin_shell_controller`، `status_request`، `app_color`، `state_views`، `admin_models`، `admin_chips`، `admin_parts`، `admin_table`

#### 151. `admin_login.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_login.dart`
- **الأسطر:** 112
- **الغرض:** E1 — دخول الإدارة. عريض: لوح كحلي بالهوية والتنبيه، وبجانبه النموذج. ضيق: اللوح فوق النموذج.
- **أنواع داخلية/مساعدة:** `_Form`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_login_controller`، `app_color`، `app_button`، `app_text_field`، `form_error_banner`، `admin_brand`

#### 152. `admin_orders.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_orders.dart`
- **الأسطر:** 140
- **الغرض:** E6 — مراجعة الطلبات (FR-65): جدول الطلبات الفرعية، وبجانبه مراحل الطلب المحدد وأصنافه. للعرض فقط: الإدارة لا تغيّر حالة الطلب.
- **أنواع داخلية/مساعدة:** `_Panel`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_section_controllers`، `status_request`، `app_color`، `format_money`، `state_views`، `admin_models`، `order_model`، `admin_chips`، `admin_parts`، `admin_table`

#### 153. `admin_products.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_products.dart`
- **الأسطر:** 123
- **الغرض:** E5 — مراجعة المنتجات (FR-64): جدول وبجانبه تفاصيل المنتج المحدد مع زر الإخفاء. "أوقفه المورد" غير "مخفي من الإدارة": الأول قرار المورد، والثاني لا يلغيه إلا الأدمن.
- **أنواع داخلية/مساعدة:** `_Panel`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_section_controllers`، `admin_shell_controller`، `status_request`، `app_color`، `format_money`، `app_button`، `state_views`، `admin_models`، `admin_chips`، `admin_parts`، `admin_table`، `product_thumb`

#### 154. `admin_shell.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_shell.dart`
- **الأسطر:** 197
- **الغرض:** هيكل لوحة الإدارة: شريط جانبي كحلي ثابت والمحتوى بجانبه (E2 إلى E10). على الشاشات الضيقة يصبح الشريط قائمة منزلقة من زر في الأعلى.
- **أنواع داخلية/مساعدة:** `_Sidebar`، `_NavItem`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_shell_controller`، `app_color`، `admin_models`، `admin_brand`، `admin_audit`، `admin_categories`، `admin_dashboard`، `admin_deletion`، `admin_orders`، `admin_products`، `admin_users`

#### 155. `admin_users.dart`

- **المسار:** `C:\shahbandar\lib\view\screen\admin\admin_users.dart`
- **الأسطر:** 293
- **الغرض:** E3 — المستخدمون: بحث، فلتر الدور والحالة، جدول بصفحات. الضغط على صف يفتح E4 داخل نفس القسم.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AdminUsersScreen` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `AdminUserDetailScreen` | E4 — تفاصيل مستخدم: الحساب، الملف التجاري، آخر النشاط، ولوحة الإيقاف (أو إعادة التفعيل) بإطار أحمر وسبب داخلي اختياري. |

- **أنواع داخلية/مساعدة:** `_StatusPanel`
- **الحزم:** flutter، get
- **يعتمد على:** `admin_section_controllers`، `admin_shell_controller`، `status_request`، `app_color`، `app_button`، `state_views`، `admin_models`، `admin_chips`، `admin_parts`، `admin_table`

### view/widget/splash

#### 156. `splash_logo.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\splash\splash_logo.dart`
- **الأسطر:** 57
- **الغرض:** شعار شاشة البداية (A1).  المربع البرتقالي في مركز الشاشة تماماً، في نفس مكان شعار شاشة النظام، فلا "يقفز" عند الانتقال. لذلك فوقه مساحة شفافة تعادل (المسافة + اسم التطبيق).
- **الحزم:** flutter، flutter_svg، get
- **يعتمد على:** `app_color`، `image_asset`

### view/widget/auth — أجزاء شاشات الحساب

#### 157. `auth_body.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\auth\auth_body.dart`
- **الأسطر:** 51
- **الغرض:** الهيكل المتكرر في شاشات الحساب: محتوى قابل للتمرير في الأعلى، وأزرار [bottom] ملتصقة بأسفل الشاشة عندما يتسع المكان، وتنزل تحت المحتوى بالتمرير عندما تظهر لوحة المفاتيح.
- **الحزم:** flutter
- **يعتمد على:** `max_width`

#### 158. `auth_header.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\auth\auth_header.dart`
- **الأسطر:** 93
- **الغرض:** الجزء الكحلي أعلى شاشة الدخول (A2): زر اللغة، الشعار، والاسم.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AuthHeader` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `_LanguageButton` | يعرض اسم اللغة الأخرى بلغتها، ويفتح نافذة اللغة (A12). |

- **الحزم:** flutter، flutter_svg، get
- **يعتمد على:** `app_color`، `image_asset`، `locale_controller`، `language_sheet`

#### 159. `auth_illustration.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\auth\auth_illustration.dart`
- **الأسطر:** 67
- **الغرض:** الرمز الكبير في وسط شاشات الحالة (A4، A5، A9، A11).  [circle] = true: دائرة ملوّنة بلون الحالة (نجاح، تنبيه، موقوف). [circle] = false: مربع أبيض بحدّ رمادي (بريد، قفل). [badge]: علامة برتقالية صغيرة في الزاوية (أُرسل الرابط).
- **الحزم:** flutter
- **يعتمد على:** `app_color`

#### 160. `auth_title.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\auth\auth_title.dart`
- **الأسطر:** 44
- **الغرض:** العنوان والوصف أعلى شاشات الحساب، بنفس السلّم في كل الشاشات.
- **الحزم:** flutter
- **يعتمد على:** `app_color`

#### 161. `auth_top_bar.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\auth\auth_top_bar.dart`
- **الأسطر:** 43
- **الغرض:** الشريط العلوي البسيط: زر رجوع (اختياري) وعنوان. سهم الرجوع ينعكس تلقائياً مع اتجاه اللغة.
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `max_width`

#### 162. `role_option_card.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\auth\role_option_card.dart`
- **الأسطر:** 97
- **الغرض:** بطاقة اختيار دور في A6: خانة اختيار + عنوان + وصف + أيقونة. المحددة بحدّ برتقالي، وغير المحددة بحدّ رمادي.
- **الحزم:** flutter
- **يعتمد على:** `app_color`

#### 163. `steps_indicator.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\auth\steps_indicator.dart`
- **الأسطر:** 77
- **الغرض:** مؤشر مراحل التسجيل الأربع (قرارنا أ1 في A3): الحساب ← تأكيد البريد ← الأدوار ← الملف التجاري. المنجزة كحلية، الحالية برتقالية، القادمة رمادية.
- **أنواع داخلية/مساعدة:** `_Step`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `max_width`

### view/widget/trader — أجزاء شاشات التاجر

#### 164. `cancel_dialog.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\trader\cancel_dialog.dart`
- **الأسطر:** 57
- **الغرض:** B16 — تأكيد إلغاء طلب فرعي (FR-50). يوضّح أن الإلغاء يخص هذا المورد فقط، وأنه لا يُعكس. يرجع true عند التأكيد.
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_button`

#### 165. `filter_sheet.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\trader\filter_sheet.dart`
- **الأسطر:** 204
- **الغرض:** B3 — الفلترة (FR-27، FR-28). التعديلات هنا مؤقتة، ولا تُطبَّق إلا عند "عرض النتائج". الإغلاق بالسحب يلغيها. [lockCategory]: في صفحة التصنيف (B5) يبقى التصنيف ثابتاً فلا نعرض اختياره.
- **أنواع داخلية/مساعدة:** `_FilterSheet`، `_FilterSheetState`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `format_money`، `app_button`، `option_model`، `product_filter`، `product_model`

#### 166. `order_tracker.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\trader\order_tracker.dart`
- **الأسطر:** 88
- **الغرض:** متتبّع مراحل الطلب الفرعي: بانتظار الرد ← مقبول ← قيد التجهيز ← مكتمل. الطلب المرفوض أو الملغى لا يُرسم له مسار، بل تظهر حالته النهائية فقط.
- **أنواع داخلية/مساعدة:** `_Step`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `status_chip`، `order_model`

#### 167. `product_card.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\trader\product_card.dart`
- **الأسطر:** 115
- **الغرض:** بطاقة منتج في الشبكة: الصورة، الاسم، المورد ومدينته، السعر، والحد الأدنى. المنتج النافد يبقى ظاهراً مع شارة "نفد" (FR-21).

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `ProductCard` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `ProductSliverGrid` | شبكة منتجات متجاوبة: عمودان على الهاتف، وأكثر كلما اتسعت الشاشة. |

- **أنواع داخلية/مساعدة:** `OutOfStockBadge`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_routes`، `format_money`، `product_model`، `product_thumb`

#### 168. `product_thumb.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\trader\product_thumb.dart`
- **الأسطر:** 61
- **الغرض:** صورة المنتج. إن رفع المورد صورة تظهر هي، وإلا رسم مؤقت (أيقونة على لون هادئ) حسب نوع المنتج، حتى تبقى الشبكة مرتبة ومقروءة قبل وصول الصور الحقيقية.
- **الحزم:** flutter
- **يعتمد على:** `app_image`

#### 169. `sort_sheet.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\trader\sort_sheet.dart`
- **الأسطر:** 51
- **الغرض:** B4 — الترتيب: نافذة سفلية بأربعة خيارات، والاختيار يطبَّق فوراً ويغلقها.
- **أنواع داخلية/مساعدة:** `_Handle`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_select_field`، `product_filter`

#### 170. `trader_parts.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\trader\trader_parts.dart`
- **الأسطر:** 187
- **الغرض:** عنوان قسم مع رابط اختياري ("عرض الكل").

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `SectionHeader` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `SupplierAvatar` | دائرة بالحرف الأول من اسم المورد (حتى يرفع شعاره). |
| فئة | `CurrencyTotals` | المجاميع لكل عملة في أسطر منفصلة: لا نجمع الدولار مع الليرة أبداً. |
| فئة | `CartBadgeIcon` | أيقونة السلة مع عدّاد الأصناف، تتحدث تلقائياً. |
| فئة | `CompareShortcut` | زر المقارنة العائم أعلى القوائم حين يكون في المقارنة منتجان أو أكثر. |
| فئة | `SurfaceCard` | حاوية بيضاء بزوايا 20، للأقسام داخل الصفحات. |
| فئة | `BottomActionBar` | شريط سفلي ثابت للإجراء الرئيسي، فوق المحتوى بخط فاصل. |
| دالة | `categoryIcon` | أيقونة كل تصنيف (حتى تُضاف صور التصنيفات من لوحة الأدمن). |

- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_routes`، `format_money`، `cart_service`، `product_model`

### view/widget/supplier — أجزاء شاشات المورد

#### 171. `accept_failed_dialog.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\supplier\accept_failed_dialog.dart`
- **الأسطر:** 90
- **الغرض:** C5 — تعذّر قبول الطلب لأن المخزون لا يكفي. يطمئن المورد أن شيئاً لم يُخصم، ويعرض الحلّين: تحديث المخزون أو الرفض.
- **أنواع داخلية/مساعدة:** `AcceptFailedChoice`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `format_money`، `app_button`، `incoming_order_model`

#### 172. `order_timeline.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\supplier\order_timeline.dart`
- **الأسطر:** 133
- **الغرض:** C6 — مراحل الطلب عمودياً عند المورد: استُلم ← قبلتَه ← قيد التجهيز ← مكتمل، مع وقت كل مرحلة. المرحلة التالية بحلقة برتقالية و"الخطوة التالية". المرفوض والملغى ينتهيان عند حالتهما.
- **أنواع داخلية/مساعدة:** `_State`، `_Step`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `format_money`، `incoming_order_model`، `order_model`

#### 173. `reject_sheet.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\supplier\reject_sheet.dart`
- **الأسطر:** 162
- **الغرض:** أسباب الرفض الجاهزة. كلها اختيارية (FR-48).

| النوع | الاسم | الوصف |
|---|---|---|
| تعداد | `RejectReason` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| دالة | `showRejectSheet` | C4 — رفض الطلب. يرجع null عند "تراجع"، أو نص السبب الذي يراه التاجر (قد يكون فارغاً). |
| فئة | `_RejectSheetState` |  |
| ↳ عضو | `_RejectSheetState._compose` | السبب كما يصل للتاجر: عنوان السبب ثم التفاصيل. |

- **أنواع داخلية/مساعدة:** `_RejectSheet`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_button`

#### 174. `supplier_parts.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\supplier\supplier_parts.dart`
- **الأسطر:** 108
- **الغرض:** منذ متى ينتظر التاجر. اللون يشتد كلما طال الانتظار: أقل من 30 دقيقة رمادي، حتى 90 دقيقة أصفر، وبعدها أحمر.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AgeChip` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `IncomingOrderRow` | صف طلب في القوائم: اسم التاجر، الرقم وعدد الأصناف والقيمة، والحالة أو مدة الانتظار. |
| فئة | `RowsCard` | قائمة صفوف داخل بطاقة بيضاء واحدة بفواصل. |

- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `format_money`، `status_chip`، `incoming_order_model`، `order_model`

### view/widget/shared — أجزاء مشتركة

#### 175. `activate_role_sheet.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\shared\activate_role_sheet.dart`
- **الأسطر:** 101
- **الغرض:** D4 — تفعيل دور على نفس الحساب (FR-10). يشرح ما سيحصل، ويطمئن أن الطلبات الحالية تبقى، وأن التفعيل لا يمنح صلاحيات إدارية. يرجع true عند "تفعيل".
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_button`، `user_model`

### view/widget/admin — أجزاء لوحة الإدارة

#### 176. `admin_brand.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\admin\admin_brand.dart`
- **الأسطر:** 38
- **الغرض:** شعار شاهبندر في مربع برتقالي، مع اسم اللوحة بالأبيض (فوق الكحلي).
- **الحزم:** flutter، flutter_svg، get
- **يعتمد على:** `app_color`، `image_asset`

#### 177. `admin_chips.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\admin\admin_chips.dart`
- **الأسطر:** 72
- **الغرض:** "تاجر"، "مورد"، أو "تاجر ومورد".

| النوع | الاسم | الوصف |
|---|---|---|
| دالة | `rolesLabel` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| دالة | `shortDate` | تاريخ قصير للجداول: 29/10/2026 |
| دالة | `shortDateTime` | وقت قصير: 31/10 22:04 |

- **أنواع داخلية/مساعدة:** `OrderStatusChip`، `UserStatusChip`، `ProductStatusChip`
- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `status_chip`، `admin_models`، `order_model`، `user_model`، `admin_parts`

#### 178. `admin_parts.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\admin\admin_parts.dart`
- **الأسطر:** 331
- **الغرض:** عنوان الصفحة، مع نص فرعي أو عدّاد على الجهة الأخرى.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AdminPageHeader` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `FilterPill` | زر فلتر دائري: أبيض، أو كحلي حين يكون مختاراً. |
| فئة | `AdminSearchField` | حقل البحث في رأس الجداول. |
| فئة | `AdminChip` | شارة حالة صغيرة بلون ونص. |
| فئة | `AdminBox` | بطاقة بيضاء بعنوان اختياري. |
| فئة | `KeyValueList` | قائمة "مفتاح: قيمة" بعمودين. |
| فئة | `LtrText` | نص لاتيني (بريد، هاتف) يبقى ملاصقاً لبداية الخلية في الاتجاهين. |
| فئة | `FilterBar` | صف فلاتر يلتف على الشاشات الضيقة. |
| دالة | `confirmAdminAction` | تأكيد إجراء إداري. يرجع true عند التأكيد. |
| فئة | `AdminPage` | صفحة قسم: قائمة قابلة للتمرير بهوامش تتسع مع الشاشة، ومسافة 18 بين الأجزاء. |
| فئة | `TableWithPanel` | لوحة جانبية بجانب الجدول على الشاشات العريضة، وتحته على الضيقة. |

- **الحزم:** flutter، get
- **يعتمد على:** `app_color`، `app_button`

#### 179. `admin_table.dart`

- **المسار:** `C:\shahbandar\lib\view\widget\admin\admin_table.dart`
- **الأسطر:** 113
- **الغرض:** عمود في جدول الإدارة: العنوان ونسبة العرض.

| النوع | الاسم | الوصف |
|---|---|---|
| فئة | `AdminColumn` | (الفئة الرئيسية — انظر الغرض أعلاه) |
| فئة | `AdminTable` | جدول الإدارة: رأس رمادي فاتح، صفوف بفاصل، تمرير أفقي حين يضيق العرض. الصف المحدد بخلفية دافئة، والضغط على الصف يستدعي [onTap]. |

- **الحزم:** flutter
- **يعتمد على:** `app_color`

---

**نهاية التقرير** — 179 ملفاً في `C:\shahbandar\lib`.
