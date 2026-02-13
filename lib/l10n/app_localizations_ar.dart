import 'app_localizations.dart';

// ignore_for_file: type=lint

/// Arabic translations for AppLocalizations
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([super.locale = 'ar']);

  // ═══════════════════════════════════════════════════════════════════════════
  // Basic App Info
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get appName => 'هندام';
  @override
  String get hindam => 'هندام';
  @override
  String get menTailoringShopsApp => 'تطبيق خياط الرجال والتجار';
  @override
  String get bestTailorsInOnePlace => 'أفضل الخياطين والمحلات في مكان واحد';

  // ═══════════════════════════════════════════════════════════════════════════
  // Navigation
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get home => 'الرئيسية';
  @override
  String get orders => 'الطلبات';
  @override
  String get cart => 'السلة';
  @override
  String get profile => 'حسابي';
  @override
  String get more => 'المزيد';
  @override
  String get catalog => 'الكتالوج';

  // ═══════════════════════════════════════════════════════════════════════════
  // Greetings
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get goodMorning => 'صباح الخير';
  @override
  String get goodAfternoon => 'مساء الخير';
  @override
  String get goodEvening => 'مساء الخير';
  @override
  String get goodNight => 'تصبح على خير';
  @override
  String get hello => 'مرحباً 👋';
  @override
  String get dearCustomer => 'عميلنا العزيز';
  @override
  String get welcomeTitle => 'أهلاً وسهلاً';
  @override
  String get welcomeBack => 'أهلاً بعودتك';

  // ═══════════════════════════════════════════════════════════════════════════
  // Auth
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get login => 'تسجيل الدخول';
  @override
  String get logout => 'تسجيل الخروج';
  @override
  String get signup => 'إنشاء حساب';
  @override
  String get createNewAccount => 'إنشاء حساب جديد';
  @override
  String get continueAsGuest => 'المتابعة كزائر';
  @override
  String get browseAsGuest => 'تصفح كزائر';
  @override
  String get logoutFromAccount => 'إنهاء الجلسة الحالية';
  @override
  String get logoutConfirmation => 'هل تريد تسجيل الخروج من حسابك؟';
  @override
  String get logoutSuccess => 'تم تسجيل الخروج بنجاح';
  @override
  String get pleaseLoginFirst => 'يرجى تسجيل الدخول أولاً';
  @override
  String get pleaseLoginToViewOrders => 'يرجى تسجيل الدخول لعرض طلباتك';
  @override
  String get joinUsAndEnjoy => 'انضم إلينا واستمتع بتجربة تسوق فريدة';
  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';
  @override
  String get email => 'البريد الإلكتروني';
  @override
  String get password => 'كلمة المرور';
  @override
  String get confirmPassword => 'تأكيد كلمة المرور';
  @override
  String get name => 'الاسم';
  @override
  String get phoneNumber => 'رقم الهاتف';
  @override
  String get rememberMe => 'تذكرني';
  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';
  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get favorites => 'المفضلة';
  @override
  String get myFavorites => 'المفضلة';
  @override
  String get favoriteProducts => 'منتجات مفضلة';
  @override
  String get viewFavoriteProducts => 'عرض المنتجات المفضلة';
  @override
  String get noFavoritesYet => 'لا توجد منتجات مفضلة بعد';
  @override
  String get addedToFavorites => 'تمت الإضافة إلى المفضلة';
  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myAddresses => 'عناويني';
  @override
  String get manageSavedAddresses => 'إدارة العناوين المحفوظة';
  @override
  String get addAddress => 'إضافة عنوان';
  @override
  String get editAddress => 'تعديل العنوان';
  @override
  String get deleteAddress => 'حذف العنوان';
  @override
  String get noAddressesYet => 'لا توجد عناوين محفوظة بعد';
  @override
  String get addressTitle => 'عنوان المنزل';
  @override
  String get city => 'المدينة';
  @override
  String get street => 'الشارع';
  @override
  String get building => 'المبنى';
  @override
  String get apartment => 'الشقة';
  @override
  String get defaultAddress => 'العنوان الافتراضي';
  @override
  String get setAsDefault => 'تعيين كعنوان افتراضي';

  // ═══════════════════════════════════════════════════════════════════════════
  // Orders
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myOrders => 'طلباتي';
  @override
  String get allOrders => 'الكل';
  @override
  String get pendingOrders => 'قيد الانتظار';
  @override
  String get acceptedOrders => 'مقبولة';
  @override
  String get inProgressOrders => 'قيد التنفيذ';
  @override
  String get completedOrdersTab => 'مكتملة';
  @override
  String get rejectedOrders => 'مرفوضة';
  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';
  @override
  String get startShoppingNow => 'ابدأ التسوق الآن!';
  @override
  String get browseProducts => 'تصفح المنتجات';
  @override
  String get orderDetails => 'تفاصيل الطلب';
  @override
  String get orderStatus => 'حالة الطلب';
  @override
  String get orderDate => 'تاريخ الطلب';
  @override
  String get orderNumber => 'رقم الطلب';
  @override
  String get trackOrder => 'تتبع الطلب';
  @override
  String get cancelOrder => 'إلغاء الطلب';
  @override
  String get reorder => 'طلب مرة أخرى';
  @override
  String customerOrdersTitle(String name) => 'طلبات $name';
  @override
  String get noOrdersCurrently => 'لا توجد طلبات حالياً';
  @override
  String get noOrdersYetDescription => 'لم تقم بإرسال أي طلبات حتى الآن';
  @override
  String get latestOrder => 'أحدث طلب';
  @override
  String get track => 'تتبع';
  @override
  String get orderStatistics => 'إحصائيات الطلبات';
  @override
  String get searchOrdersHint => 'البحث في الطلبات...';
  @override
  String noOrdersForStatus(String status) => 'لا توجد طلبات $status';
  @override
  String ordersForStatusAppearHere(String status) =>
      'الطلبات $status ستظهر هنا';
  @override
  String get revenue => 'الإيرادات';
  @override
  String get errorLoadingOrders => 'حدث خطأ في تحميل الطلبات';
  @override
  String get featureComingSoon => 'سيتم إضافة هذه الميزة قريباً';
  @override
  String get processingStatus => 'قيد المعالجة';
  @override
  String get shippingStatus => 'قيد الشحن';
  @override
  String get deliveredStatus => 'تم التسليم';
  @override
  String get accept => 'قبول';
  @override
  String get reject => 'رفض';
  @override
  String get startProcessing => 'بدء التنفيذ';
  @override
  String get complete => 'إكمال';
  @override
  String get orderAcceptedSuccess => 'تم قبول الطلب';
  @override
  String get orderAcceptedFailed => 'فشل في قبول الطلب';
  @override
  String get rejectOrderTitle => 'رفض الطلب';
  @override
  String get rejectOrderPrompt => 'يرجى إدخال سبب الرفض:';
  @override
  String get orderRejectedSuccess => 'تم رفض الطلب';
  @override
  String get orderRejectedFailed => 'فشل في رفض الطلب';
  @override
  String get orderStartedSuccess => 'تم بدء تنفيذ الطلب';
  @override
  String get orderStartedFailed => 'فشل في بدء تنفيذ الطلب';
  @override
  String get orderCompletedFailed => 'فشل في إكمال الطلب';

  // ═══════════════════════════════════════════════════════════════════════════
  // Profile & Account
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get account => 'الحساب';
  @override
  String get myAccount => 'حسابي';
  @override
  String get manageYourDataAndOrders => 'إدارة بياناتك وطلباتك';
  @override
  String get personalInfo => 'المعلومات الشخصية';
  @override
  String get editProfile => 'تعديل الملف الشخصي';
  @override
  String get editNameAndPhone => 'تعديل الاسم والهاتف';
  @override
  String get profilePhotoUpdated => 'تم تحديث صورة الملف الشخصي';
  @override
  String get failedToUploadPhoto => 'فشل رفع الصورة';
  @override
  String get changeProfilePhoto => 'تغيير صورة الملف الشخصي';
  @override
  String get chooseFromGallery => 'اختر من المعرض';
  @override
  String get takePhoto => 'التقط صورة';
  @override
  String get useCamera => 'استخدام الكاميرا';

  // ═══════════════════════════════════════════════════════════════════════════
  // Statistics
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myStatistics => 'إحصائياتي';
  @override
  String get totalOrders => 'إجمالي الطلبات';
  @override
  String get allOrdersMade => 'كل الطلبات التي قمت بها';
  @override
  String get activeOrders => 'طلبات نشطة';
  @override
  String get currentlyTracking => 'قيد المتابعة حالياً';
  @override
  String get completedOrders => 'طلبات مكتملة';
  @override
  String get successfullyDelivered => 'تم تسليمها بنجاح';
  @override
  String get cancelledRejected => 'ملغاة / مرفوضة';
  @override
  String get cancelledOrRejected => 'تم إلغاؤها أو رفضها';

  // ═══════════════════════════════════════════════════════════════════════════
  // Settings
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get settings => 'الإعدادات';
  @override
  String get personalSettings => 'الإعدادات الشخصية';
  @override
  String get notifications => 'الإشعارات';
  @override
  String get orderStatusAlerts => 'تنبيهات حالة الطلب';
  @override
  String get orderStatusAndOffersAlerts => 'تنبيهات حالة الطلب والعروض';
  @override
  String get offersAndDiscounts => 'العروض والخصومات';
  @override
  String get receiveExclusiveOffers => 'استلام العروض الحصرية';
  @override
  String get language => 'اللغة';
  @override
  String get accountManagement => 'إدارة الحساب';
  @override
  String get viewAndTrackOrders => 'عرض ومتابعة الطلبات';
  @override
  String get paymentMethods => 'طرق الدفع';
  @override
  String get manageCardsAndPayment => 'إدارة البطاقات والدفع';
  @override
  String get noSavedPaymentMethods => 'لا توجد طرق دفع محفوظة';
  @override
  String get addPaymentMethodLater =>
      'أضف بطاقة أو طريقة دفع عند إتمام طلبك في المرة القادمة';
  @override
  String get addPaymentMethod => 'إضافة طريقة دفع';
  @override
  String get privacyAndSecurity => 'الخصوصية والأمان';
  @override
  String get securityAndPrivacySettings => 'إعدادات الأمان والخصوصية';
  @override
  String get changePassword => 'تغيير كلمة المرور';
  @override
  String get updatePasswordRegularly => 'تحديث كلمة المرور بشكل دوري';
  @override
  String get dataWeCollect => 'البيانات التي نجمعها';
  @override
  String get howWeUseYourData => 'كيف نستخدم بياناتك';
  @override
  String get privacyPolicy => 'سياسة الخصوصية';
  @override
  String get readFullPrivacyPolicy => 'قراءة سياسة الخصوصية الكاملة';
  @override
  String get helpAndSupport => 'المساعدة والدعم';
  @override
  String get helpCenter => 'مركز المساعدة';
  @override
  String get faqAndSupport => 'الأسئلة الشائعة والدعم';
  @override
  String get faqTitle => 'الأسئلة الشائعة';
  @override
  String get faqSubtitle => 'إجابات على أكثر الأسئلة شيوعاً';
  @override
  String get contactUs => 'تواصل معنا';
  @override
  String get supportAndInquiries => 'الدعم الفني والاستفسارات';
  @override
  String get phone => 'الهاتف';
  @override
  String get supportAvailableAnytime => 'نسعد بمساعدتك على مدار الساعة';
  @override
  String get aboutApp => 'عن التطبيق';
  @override
  String get appVersionAndInfo => 'إصدار التطبيق ومعلومات إضافية';
  @override
  String get appVersionLabel => 'الإصدار';
  @override
  String appVersion(String version) => 'الإصدار $version';
  @override
  String get aboutAppDescription =>
      'تطبيق هندام يربطك بأفضل محلات الخياطة الرجالية في السلطنة. اطلب دشداشاتك، عباياتك، وتفصيلاتك بسهولة مع متابعة الطلبات والتوصيل.';
  @override
  String get website => 'الموقع';
  @override
  String get infoAndAccount => 'المعلومات والحساب';
  @override
  String get notificationsAndOffers => 'الإشعارات والعروض';
  @override
  String get appLanguage => 'لغة التطبيق';

  // ═══════════════════════════════════════════════════════════════════════════
  // Language
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get chooseLanguage => 'اختر اللغة';
  @override
  String get automatic => 'تلقائي';
  @override
  String get useDeviceLanguage => 'استخدام لغة الجهاز';
  @override
  String get languageChangedToDevice => 'تم تغيير اللغة إلى لغة الجهاز';
  @override
  String get arabic => 'العربية';
  @override
  String get languageChangedToArabic => 'تم تغيير اللغة إلى العربية';
  @override
  String get english => 'English';
  @override
  String get languageChangedToEnglish => 'Language changed to English';

  // ═══════════════════════════════════════════════════════════════════════════
  // Measurements
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get enterMeasurements => 'أدخل القياسات';
  @override
  String get saveExperimental => 'حفظ (تجريبي)';

  // ═══════════════════════════════════════════════════════════════════════════
  // Home Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get categories => 'الأقسام';
  @override
  String get menTailor => 'الخياط الرجالي';
  @override
  String get abayas => 'العبايات';
  @override
  String get merchants => 'التجّار';
  @override
  String get nearbyTailors => 'خياطون بالقرب منك';
  @override
  String get viewAll => 'عرض الكل';
  @override
  String get searchTailorOrService => 'ابحث عن خياط أو خدمة...';
  @override
  String get discount40 => 'خصم 40%';
  @override
  String get onAllMensTailoring => 'على جميع خدمات التفصيل الرجالي';
  @override
  String get limitedOffer => 'عرض محدود';
  @override
  String get freeDelivery => 'توصيل مجاني';
  @override
  String get forOrdersAbove50 => 'للطلبات فوق 50 ريال';
  @override
  String get newLabel => 'جديد';
  @override
  String get eidThobe => 'دشداشة العيد';
  @override
  String get exclusiveCollection => 'تشكيلة حصرية بأجود الأقمشة';
  @override
  String get exclusive => 'حصري';
  @override
  String get menTailoring => 'الخياطة الرجالية';
  @override
  String get exclusiveOffer => 'عرض حصري';
  @override
  String get saveUpTo => 'وفّر حتى';
  @override
  String get discoverNow => 'اكتشف الآن';
  @override
  String get noTailorShopsRegistered => 'لا توجد محلات مسجلة حالياً';
  @override
  String get unableToLoadTailorShops => 'تعذر تحميل محلات الخياطة';
  @override
  String get onThobeTailoring => 'على خياطة الدشداشة';
  @override
  String get discoverNewShopsOrTry =>
      'اكتشف محلات جديدة أو جرّب خياطين ما طلبت منهم من فترة';
  @override
  String get riyal3 => '٣ ر.ع';
  @override
  String get rating4Plus => '4.0+ تقييم';
  @override
  String get refreshing => 'جاري التحديث...';
  @override
  String shopsListUpdatedSuccess(int count) =>
      'تم تحديث قائمة المحلات بنجاح (عدد المحلات: $count)';
  @override
  String get failedToRefreshList => 'فشل في تحديث القائمة';
  @override
  String get store => 'متجر';
  @override
  String get refreshList => 'تحديث القائمة';
  @override
  String get yesCancel => 'نعم، إلغاء';
  @override
  String get continueToRecipientInfo => 'متابعة لبيانات المستلم';
  @override
  String get sendingOrder => 'جاري الإرسال...';
  @override
  String get sendGiftRequest => 'إرسال طلب الهدية';
  @override
  String get addNewFabricSoon => 'سيتم تنفيذ إضافة قماش جديد قريباً';
  @override
  String get editFabricSoon => 'سيتم تنفيذ تعديل القماش قريباً';
  @override
  String get openNowFilter => 'مفتوح الآن';
  @override
  String get deliveryFilter => 'توصيل';
  @override
  String get priceUp => 'السعر ↑';
  @override
  String get priceDown => 'السعر ↓';
  @override
  String get productAddedToCart => 'تمت إضافة المنتج إلى السلة';
  @override
  String get confirmCancelOrder => 'هل أنت متأكد من إلغاء هذا الطلب؟';
  @override
  String get chooseFabricType => 'اختر نوع القماش';
  @override
  String get browseAvailableFabrics => 'تصفح الأقمشة المتوفرة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Features
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get fastDelivery => 'توصيل سريع';
  @override
  String get toAllOman => 'لجميع أنحاء السلطنة';
  @override
  String get guaranteedQuality => 'جودة مضمونة';
  @override
  String get originalProducts100 => 'منتجات أصلية 100%';
  @override
  String get continuousSupport => 'دعم متواصل';
  @override
  String get customerService247 => 'خدمة عملاء على مدار الساعة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Details
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get tailorDetails => 'تفاصيل الخياط';
  @override
  String get services => 'الخدمات';
  @override
  String get fabrics => 'الأقمشة';
  @override
  String get reviews => 'التقييمات';
  @override
  String get open => 'مفتوح';
  @override
  String get closed => 'مغلق';
  @override
  String get openNow => 'مفتوح الآن';
  @override
  String get closedNow => 'مغلق الآن';
  @override
  String get km => 'كم';
  @override
  String get fastDeliveryTag => 'تسليم سريع';
  @override
  String get menDishdasha => 'دشداشة رجالي';
  @override
  String get omaniEmbroidery => 'تطريز عُماني';
  @override
  String get homeMeasurement => 'قياس منزلي';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get tailoringDesign => 'تصميم التفصيل';
  @override
  String get chooseFabric => 'اختر القماش';
  @override
  String get chooseDesign => 'اختر التصميم';
  @override
  String get reviewOrder => 'مراجعة الطلب';
  @override
  String get measurements => 'المقاسات';
  @override
  String get length => 'الطول';
  @override
  String get shoulder => 'الكتف';
  @override
  String get neck => 'الرقبة';
  @override
  String get armLength => 'طول اليد';
  @override
  String get wristWidth => 'عرض المعصم';
  @override
  String get chestWidth => 'عرض الصدر';
  @override
  String get bottomWidth => 'عرض الأسفل';
  @override
  String get embroideryLength => 'طول التطريز';
  @override
  String get embroideryDesign => 'نوع التطريز';
  @override
  String get selectEmbroidery => 'اختر التطريز';
  @override
  String get noEmbroidery => 'بدون تطريز';
  @override
  String get continueButton => 'متابعة';
  @override
  String get back => 'رجوع';
  @override
  String get next => 'التالي';
  @override
  String get estimatedCost => 'التكلفة التقديرية';
  @override
  String get submitOrder => 'تأكيد الطلب';

  // ═══════════════════════════════════════════════════════════════════════════
  // Cart
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get shoppingCart => 'سلة التسوق';
  @override
  String get cartEmpty => 'السلة فارغة';
  @override
  String get cartEmptyMessage => 'لم تضف أي منتجات إلى السلة بعد';
  @override
  String get startShopping => 'ابدأ التسوق';
  @override
  String get total => 'الإجمالي';
  @override
  String get subtotal => 'المجموع الفرعي';
  @override
  String get deliveryFee => 'رسوم التوصيل';
  @override
  String get checkout => 'إتمام الشراء';
  @override
  String get removeFromCart => 'إزالة من السلة';
  @override
  String get quantity => 'الكمية';
  @override
  String get updateCart => 'تحديث السلة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Common Actions
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cancel => 'إلغاء';
  @override
  String get confirm => 'تأكيد';
  @override
  String get save => 'حفظ';
  @override
  String get delete => 'حذف';
  @override
  String get edit => 'تعديل';
  @override
  String get done => 'تم';
  @override
  String get ok => 'حسناً';
  @override
  String get close => 'إغلاق';
  @override
  String get retry => 'إعادة المحاولة';
  @override
  String get loading => 'جاري التحميل...';
  @override
  String get search => 'بحث';
  @override
  String get filter => 'تصفية';
  @override
  String get sort => 'ترتيب';
  @override
  String get apply => 'تطبيق';
  @override
  String get reset => 'إعادة ضبط';
  @override
  String get clear => 'مسح';
  @override
  String get refresh => 'تحديث';
  @override
  String get seeMore => 'عرض المزيد';
  @override
  String get seeLess => 'عرض أقل';
  @override
  String get select => 'اختر';
  @override
  String get selected => 'محدد';
  @override
  String get add => 'إضافة';
  @override
  String get remove => 'إزالة';
  @override
  String get update => 'تحديث';
  @override
  String get submit => 'إرسال';
  @override
  String get send => 'إرسال';
  @override
  String get share => 'مشاركة';
  @override
  String get copy => 'نسخ';
  @override
  String get copied => 'تم النسخ';

  // ═══════════════════════════════════════════════════════════════════════════
  // Errors & Messages
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get error => 'خطأ';
  @override
  String get success => 'نجاح';
  @override
  String get warning => 'تحذير';
  @override
  String get info => 'معلومات';
  @override
  String get noData => 'لا توجد بيانات';
  @override
  String get noResults => 'لا توجد نتائج';
  @override
  String get somethingWentWrong => 'حدث خطأ ما';
  @override
  String get tryAgain => 'حاول مرة أخرى';
  @override
  String get connectionError => 'خطأ في الاتصال';
  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';
  @override
  String get serverError => 'خطأ في الخادم';
  @override
  String get sessionExpired => 'انتهت الجلسة';
  @override
  String get invalidInput => 'إدخال غير صالح';
  @override
  String get requiredField => 'هذا الحقل مطلوب';
  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';
  @override
  String get invalidPhone => 'رقم هاتف غير صالح';
  @override
  String get passwordTooShort => 'كلمة المرور قصيرة جداً';
  @override
  String get passwordsDontMatch => 'كلمات المرور غير متطابقة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Time
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String minutesAgo(int n) {
    if (n == 1) return 'منذ دقيقة';
    if (n == 2) return 'منذ دقيقتين';
    if (n >= 3 && n <= 10) return 'منذ $n دقائق';
    return 'منذ $n دقيقة';
  }

  @override
  String hoursAgo(int n) {
    if (n == 1) return 'منذ ساعة';
    if (n == 2) return 'منذ ساعتين';
    if (n >= 3 && n <= 10) return 'منذ $n ساعات';
    return 'منذ $n ساعة';
  }

  @override
  String get yesterday => 'أمس';
  @override
  String daysAgo(int n) {
    if (n == 1) return 'منذ يوم';
    if (n == 2) return 'منذ يومين';
    if (n >= 3 && n <= 10) return 'منذ $n أيام';
    return 'منذ $n يوم';
  }

  @override
  String get justNow => 'الآن';
  @override
  String get today => 'اليوم';
  @override
  String get tomorrow => 'غداً';

  // ═══════════════════════════════════════════════════════════════════════════
  // Currency
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String currency(String value) => '$value ر.ع';
  @override
  String get omr => 'ر.ع';

  // ═══════════════════════════════════════════════════════════════════════════
  // Validation
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get pleaseEnterValue => 'يرجى إدخال قيمة';
  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صالح';
  @override
  String get pleaseEnterValidPhone => 'يرجى إدخال رقم هاتف صالح';
  @override
  String get pleaseEnterValidPassword => 'يرجى إدخال كلمة مرور صالحة';
  @override
  String get pleaseEnterName => 'يرجى إدخال الاسم';
  @override
  String get enterValidMeasurement => 'أدخل قيمة صحيحة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Confirmation Dialogs
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get confirmLogout => 'تأكيد تسجيل الخروج';
  @override
  String get confirmDelete => 'تأكيد الحذف';
  @override
  String get confirmCancel => 'تأكيد الإلغاء';
  @override
  String get areYouSure => 'هل أنت متأكد؟';
  @override
  String get yes => 'نعم';
  @override
  String get no => 'لا';

  // ═══════════════════════════════════════════════════════════════════════════
  // Empty States
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get emptyCart => 'السلة فارغة';
  @override
  String get emptyOrders => 'لا توجد طلبات';
  @override
  String get emptyFavorites => 'لا توجد منتجات مفضلة';
  @override
  String get emptyAddresses => 'لا توجد عناوين محفوظة';
  @override
  String get noTailorsNearby => 'لا يوجد خياطون بالقرب منك';
  @override
  String get noServicesAvailable => 'لا توجد خدمات متاحة';
  @override
  String get noFabricsAvailable => 'لا توجد أقمشة متاحة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Login Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get welcomeBackTitle => 'مرحباً بك مرة أخرى!';
  @override
  String get loginToAccessAccount => 'سجل دخولك للوصول إلى حسابك';
  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';
  @override
  String get enterYourPassword => 'أدخل كلمة المرور';
  @override
  String get loginSuccessful => 'تم تسجيل الدخول بنجاح!';
  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  // ═══════════════════════════════════════════════════════════════════════════
  // Signup Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get joinHindam => 'انضم إلى هندام!';
  @override
  String get createAccountAndEnjoy =>
      'أنشئ حسابك الجديد واستمتع بتجربة تسوق مميزة';
  @override
  String get fullName => 'الاسم الكامل';
  @override
  String get enterFullName => 'أدخل اسمك الكامل';
  @override
  String get phoneOptional => 'رقم الهاتف (اختياري)';
  @override
  String get reEnterPassword => 'أعد إدخال كلمة المرور';
  @override
  String get accountCreatedSuccessfully => 'تم إنشاء الحساب بنجاح!';
  @override
  String get accountCreationFailed => 'فشل إنشاء الحساب';
  @override
  String get pleaseEnterFullName => 'الرجاء إدخال الاسم الكامل';
  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
  @override
  String get pleaseConfirmPassword => 'الرجاء تأكيد كلمة المرور';

  // ═══════════════════════════════════════════════════════════════════════════
  // Cart Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get clearAll => 'مسح الكل';
  @override
  String get addProductsToStart => 'أضف بعض المنتجات لتبدأ التسوق';
  @override
  String get completeOrder => 'إتمام الطلب';
  @override
  String get clearCart => 'مسح السلة';
  @override
  String get clearCartConfirmation =>
      'هل أنت متأكد من مسح جميع العناصر من السلة؟';
  @override
  String get cartCleared => 'تم مسح السلة';
  @override
  String get orderTotalAmount => 'إجمالي الطلب';
  @override
  String get confirmOrder => 'تأكيد الطلب';
  @override
  String get orderSentSuccessfully => 'تم إرسال الطلب بنجاح';
  @override
  String get color => 'اللون';
  @override
  String get notes => 'ملاحظات';

  // ═══════════════════════════════════════════════════════════════════════════
  // Forgot Password Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get resetPassword => 'استعادة كلمة المرور';
  @override
  String get enterEmailToReset => 'أدخل بريدك الإلكتروني لاستعادة كلمة المرور';
  @override
  String get sendResetLink => 'إرسال رابط الاستعادة';
  @override
  String get resetLinkSent => 'تم إرسال رابط الاستعادة إلى بريدك الإلكتروني';
  @override
  String get resetLinkFailed => 'فشل إرسال رابط الاستعادة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Edit Profile Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get saveChanges => 'حفظ التغييرات';
  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';
  @override
  String get profileUpdateFailed => 'فشل تحديث الملف الشخصي';

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get addNewAddress => 'إضافة عنوان جديد';
  @override
  String get addressName => 'اسم العنوان';
  @override
  String get fullAddress => 'العنوان الكامل';
  @override
  String get addressAddedSuccessfully => 'تم إضافة العنوان بنجاح';
  @override
  String get addressDeletedSuccessfully => 'تم حذف العنوان بنجاح';
  @override
  String get confirmDeleteAddress => 'هل أنت متأكد من حذف هذا العنوان؟';
  @override
  String get addressSavedSuccessfully => 'تم حفظ العنوان بنجاح';

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get addToCart => 'أضف للسلة';
  @override
  String get itemRemovedFromFavorites => 'تم إزالة المنتج من المفضلة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Status Labels
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get pending => 'معلقة';
  @override
  String get accepted => 'مقبولة';
  @override
  String get inProgress => 'قيد التنفيذ';
  @override
  String get completed => 'مكتملة';
  @override
  String get rejected => 'مرفوضة';
  @override
  String get cancelled => 'ملغية';
  @override
  String get orderRejectionReason => 'سبب الرفض';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Details
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get fabricDetails => 'تفاصيل القماش';
  @override
  String get fabricName => 'اسم القماش';
  @override
  String get fabricType => 'نوع القماش';
  @override
  String get fabricColor => 'لون القماش';
  @override
  String get totalPrice => 'السعر الإجمالي';
  @override
  String get tailorInfo => 'معلومات الخياط';
  @override
  String get shopName => 'اسم المحل';
  @override
  String get customerName => 'اسم العميل';
  @override
  String get additionalNotes => 'ملاحظات إضافية';
  @override
  String get rejectionReason => 'سبب الرفض';
  @override
  String get lastUpdate => 'آخر تحديث';
  @override
  String get orderNotFound => 'الطلب غير موجود';

  // ═══════════════════════════════════════════════════════════════════════════
  // Measurements
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get shoulderWidth => 'عرض الكتف';
  @override
  String get chestCircumference => 'محيط الصدر';
  @override
  String get waistCircumference => 'محيط الخصر';
  @override
  String get hipCircumference => 'محيط الورك';
  @override
  String get sleeveLength => 'طول الكم';
  @override
  String get neckCircumference => 'محيط الرقبة';
  @override
  String get armLength2 => 'طول الذراع';
  @override
  String get cm => 'سم';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get eleganceTailor => 'خياط الأناقة';
  @override
  String get eliteCenter => 'مركز النخبة';
  @override
  String get fashionTouch => 'لمسة الأزياء';
  @override
  String get softTailoring => 'الخياطة الناعمة';

  // ═══════════════════════════════════════════════════════════════════════════
  // Product & Service Actions
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get addedToCart => 'تمت الإضافة للسلة';
  @override
  String get orderNow => 'اطلب الآن';
  @override
  String get buyNow => 'اشتري الآن';
  @override
  String get sortBy => 'ترتيب حسب';
  @override
  String get priceHighToLow => 'السعر: من الأعلى للأقل';
  @override
  String get priceLowToHigh => 'السعر: من الأقل للأعلى';
  @override
  String get newest => 'الأحدث';
  @override
  String get rating => 'التقييم';

  // ═══════════════════════════════════════════════════════════════════════════
  // Permission Dialogs
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cameraPermissionRequired => 'مطلوب إذن الكاميرا';
  @override
  String get cameraAccessNeeded => 'نحتاج إلى استخدام الكاميرا لالتقاط صورة للملف الشخصي.';
  @override
  String get galleryPermissionRequired => 'مطلوب إذن الوصول للمعرض';
  @override
  String get galleryAccessNeeded => 'نحتاج إلى الوصول لمعرض الصور لاختيار صورة للملف الشخصي.';
  @override
  String get permissionDenied => 'تم رفض الإذن';
  @override
  String get openSettings => 'فتح الإعدادات';

  // ═══════════════════════════════════════════════════════════════════════════
  // Error Page
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get pageNotFound => 'الصفحة غير موجودة';
  @override
  String get goToHome => 'الذهاب للرئيسية';

  // ═══════════════════════════════════════════════════════════════════════════
  // Cancel Order
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cancelOrderConfirmation => 'هل أنت متأكد من إلغاء هذا الطلب؟';
  @override
  String get yesCancelOrder => 'نعم، إلغاء الطلب';
  @override
  String get orderCancelledSuccessfully => 'تم إلغاء الطلب بنجاح';
  @override
  String get orderCancellationFailed => 'فشل إلغاء الطلب';
  @override
  String get cancelledByCustomer => 'ملغي من العميل';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get selectFabricFirst => 'يرجى اختيار القماش أولاً';
  @override
  String get selectDesignFirst => 'يرجى اختيار التصميم أولاً';
  @override
  String get enterMeasurementsFirst => 'يرجى إدخال المقاسات أولاً';
  @override
  String get fabricPrice => 'سعر القماش';
  @override
  String get tailoringCost => 'تكلفة الخياطة';
  @override
  String get embroideryCost => 'تكلفة التطريز';
  @override
  String get orderReview => 'مراجعة الطلب';
  @override
  String get selectedFabric => 'القماش المختار';
  @override
  String get selectedDesign => 'التصميم المختار';
  @override
  String get embroideryType => 'نوع التطريز';

  // ═══════════════════════════════════════════════════════════════════════════
  // Forgot Password Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get emailSent => 'تم إرسال البريد!';
  @override
  String get resetLinkSentDescription =>
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. يرجى التحقق من صندوق البريد الوارد.';
  @override
  String get enterEmailForReset =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور';
  @override
  String get sendResetLinkButton => 'إرسال رابط إعادة التعيين';
  @override
  String get backToLogin => 'العودة لتسجيل الدخول';
  @override
  String get resend => 'إعادة الإرسال';
  @override
  String get emailSendFailed => 'فشل إرسال البريد';

  // ═══════════════════════════════════════════════════════════════════════════
  // Edit Profile Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get noUserLoggedIn => 'لا يوجد مستخدم مسجل';
  @override
  String get emailCannotBeChanged => 'لا يمكن تعديل البريد الإلكتروني';
  @override
  String get errorOccurred => 'حدث خطأ';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Details Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get muscat => 'مسقط';
  @override
  String get type => 'النوع';
  @override
  String get lines => 'الخطوط';
  @override
  String get fastDeliveryLabel => 'تسليم سريع';
  @override
  String get menDishdashaTailoring => 'دشداشة رجالي';
  @override
  String get serviceFee => 'رسوم الخدمة';
  @override
  String get time => 'الوقت';
  @override
  String get minutes => 'دقيقة';
  @override
  String get availableServices => 'الخدمات المتاحة';
  @override
  String get loginRequired => 'تسجيل الدخول مطلوب';
  @override
  String get loginToOrderService =>
      'لطلب الخدمة، يرجى تسجيل الدخول أولاً.\nيمكنك إنشاء حساب جديد في ثوانٍ.';
  @override
  String get orderNowButton => 'اطلب الآن';
  @override
  String get duration => 'المدة';
  @override
  String get menDishdashaTailoringService => 'تفصيل دشداشة رجالي';
  @override
  String get shorteningAlteration => 'تقصير/تعديل بسيط';
  @override
  String get wideningNarrowing => 'توسيع/تضييق';
  @override
  String get days => 'أيام';
  @override
  String get sameDay => 'نفس اليوم';
  @override
  String get oneDay => 'يوم واحد';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cmLabel => 'سم';
  @override
  String get inchLabel => 'إنش';
  @override
  String get pleaseSelectFabricType => 'يرجى اختيار نوع القماش';
  @override
  String get pleaseEnterMeasurementsCorrectly =>
      'يرجى إدخال المقاسات بشكل صحيح';
  @override
  String get pleaseSelectFabric => 'يرجى اختيار القماش';
  @override
  String get pleaseLoginToOrder => 'يرجى تسجيل الدخول';
  @override
  String get orderSubmissionError => 'حدث خطأ في إرسال الطلب';
  @override
  String get fabricStep => 'القماش';
  @override
  String get measurementsAndColor => 'المقاسات و اللون';
  @override
  String get embroideryStep => 'التطريز';
  @override
  String get viewOrder => 'عرض الطلب';
  @override
  String get continueText => 'استمرار';
  @override
  String get selectFabricType => 'اختر نوع القماش';
  @override
  String get browseFabricsAvailable => 'تصفح الأقمشة المتوفرة';
  @override
  String get noFabricsAvailableNow => 'لا توجد أقمشة متاحة';
  @override
  String get fabric => 'قماش';
  @override
  String get change => 'تغيير';
  @override
  String get measurementUnit => 'وحدة القياس';
  @override
  String get additionalNotesLabel => 'ملاحظات إضافية';
  @override
  String get enterAdditionalDetails => 'أدخل أي تفاصيل إضافية...';
  @override
  String get embroideryThreadColor => 'لون خيط التطريز';
  @override
  String get decorativeLines => 'الخطوط الزخرفية';
  @override
  String get noDesignsAvailable => 'لا توجد تصاميم متاحة';
  @override
  String get embroideryDesigns => 'تصاميم التطريز';
  @override
  String get selectEmbroideryDesign => 'اختر تصميم التطريز';
  @override
  String get none => 'لا يوجد';
  @override
  String get orderSentSuccess => 'تم إرسال الطلب بنجاح';
  @override
  String get orderNumberLabel => 'رقم الطلب';
  @override
  String get tailorLabel => 'الخياط';
  @override
  String get totalLabel => 'الإجمالي';
  @override
  String get willContactYouSoon => 'سيتم التواصل معك قريباً';
  @override
  String get okButton => 'موافق';
  @override
  String get reviewOrderTitle => 'مراجعة الطلب';
  @override
  String get nameLabel => 'الاسم';
  @override
  String get cityLabel => 'المدينة';
  @override
  String get fabricTypeLabel => 'النوع';
  @override
  String get designLabel => 'التصميم';
  @override
  String get threadColorLabel => 'لون الخيط';
  @override
  String get linesLabel => 'الخطوط';
  @override
  String get measurementsLabel => 'المقاسات';
  @override
  String get lengthLabel => 'الطول';
  @override
  String get shoulderLabel => 'الكتف';
  @override
  String get neckLabel => 'الرقبة';
  @override
  String get armLengthLabel => 'طول الذراع';
  @override
  String get wristWidthLabel => 'عرض المعصم';
  @override
  String get chestWidthWithSides => 'عرض الصدر مع الجانبين';
  @override
  String get patternLength => 'طول النقشة';
  @override
  String get backButton => 'رجوع';
  @override
  String get confirmSubmit => 'تأكيد الإرسال';

  // ═══════════════════════════════════════════════════════════════════════════
  // Color Names
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get colorNavy => 'كحلي';
  @override
  String get colorBlue => 'أزرق';
  @override
  String get colorGray => 'رمادي';
  @override
  String get colorGreen => 'أخضر';
  @override
  String get colorGold => 'ذهبي';
  @override
  String get colorBrown => 'بني';
  @override
  String get colorPurple => 'بنفسجي';
  @override
  String get colorBlack => 'أسود';
  @override
  String get colorSilver => 'فضي';
  @override
  String get colorWhite => 'أبيض';
  @override
  String get colorTeal => 'أخضر زيتي';
  @override
  String get colorBurgundy => 'خمري';
  @override
  String get customColor => 'لون مخصص';

  // ═══════════════════════════════════════════════════════════════════════════
  // Gift Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get giftLabel => 'هدية';
  @override
  String get giftRecipientData => 'بيانات المستلم';
  @override
  String get selectFabricForGift => 'اختر نوع القماش للهدية';
  @override
  String get enterGiftRecipientMeasurements => 'أدخل مقاسات مستلم الهدية';
  @override
  String get canAskRecipientForMeasurements =>
      'يمكنك طلب المقاسات من مستلم الهدية أو تخمينها';
  @override
  String get required => 'مطلوب';
  @override
  String get enterValidNumber => 'أدخل رقماً صحيحاً';
  @override
  String get selectThreadColorAndCount =>
      'يرجى اختيار لون الخيط وعدد الخيوط للمتابعة';
  @override
  String get threadColor => 'لون الخيط';
  @override
  String get noColorsAvailable => 'لا توجد ألوان متاحة';
  @override
  String get threadCount => 'عدد الخيوط';
  @override
  String get thread => 'خيط';
  @override
  String get threadsLimit => 'الحد';
  @override
  String get failedToLoadDesigns => 'فشل تحميل التصاميم';
  @override
  String get retryButton => 'إعادة المحاولة';
  @override
  String get giftRecipientInfo => 'بيانات مستلم الهدية';
  @override
  String get enterGiftRecipientDetails =>
      'أدخل معلومات الشخص الذي سيستلم الهدية';
  @override
  String get recipientName => 'اسم المستلم';
  @override
  String get enterRecipientName => 'أدخل اسم مستلم الهدية';
  @override
  String get recipientNameRequired => 'اسم المستلم مطلوب';
  @override
  String get recipientPhoneOptional => 'رقم هاتف المستلم (اختياري)';
  @override
  String get forDeliveryCoordination => 'للتنسيق عند التسليم';
  @override
  String get giftMessageOptional => 'رسالة الهدية (اختياري)';
  @override
  String get writeShortMessageToRecipient => 'اكتب رسالة قصيرة للمستلم...';
  @override
  String get deliveryNotesOptional => 'ملاحظات التوصيل (اختياري)';
  @override
  String get deliveryNotesExample => 'مثال: تسليم بتاريخ معين، تغليف خاص...';
  @override
  String get totalAmount => 'الإجمالي';
  @override
  String get sending => 'جاري الإرسال...';
  @override
  String get sendGiftOrder => 'إرسال طلب الهدية';
  @override
  String get clickToSelect => 'اضغط لاختيار';
  @override
  String get totalPriceLabel => 'السعر الإجمالي';
  @override
  String get continueToRecipientData => 'متابعة لبيانات المستلم';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Store Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get tailoringServices => 'الخدمات';
  @override
  String get giftSection => 'هدية';
  @override
  String get menDishdashaTailoringTitle => 'تفصيل دشداشة رجالي';
  @override
  String get childrenDishdashaTailoring => 'تفصيل دشداشة أطفال';
  @override
  String get premiumSummerFabric => 'قماش صيفي فاخر';
  @override
  String get japaneseCottonFabric => 'قماش قطني ياباني';
  @override
  String get searchInSection => 'ابحث داخل';
  @override
  String get priceLabel => 'السعر';
  @override
  String get quantityLabel => 'الكمية';
  @override
  String get addedToCartMessage => 'أُضيف إلى السلة';
  @override
  String get addToCartButton => 'إضافة إلى السلة';
  @override
  String get viewAllButton => 'عرض الكل';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Fabric Admin Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get manageFabricsFor => 'إدارة أقمشة';
  @override
  String get searchInFabrics => 'البحث في الأقمشة...';
  @override
  String get addFabric => 'إضافة قماش';
  @override
  String get fabricStatistics => 'إحصائيات الأقمشة';
  @override
  String get totalFabrics => 'إجمالي الأقمشة';
  @override
  String get tailorFabrics => 'أقمشة هذا الخياط';
  @override
  String get errorLoadingFabrics => 'حدث خطأ في تحميل الأقمشة';
  @override
  String get noFabricsForTailor => 'لا توجد أقمشة لهذا الخياط';
  @override
  String get addFirstFabric => 'إضافة أول قماش';
  @override
  String get searchError => 'حدث خطأ في البحث';
  @override
  String get noSearchResults => 'لا توجد نتائج للبحث';
  @override
  String get typeNotSpecified => 'غير محدد';
  @override
  String get perMeter => '/متر';
  @override
  String get addFabricComingSoon => 'سيتم تنفيذ إضافة قماش جديد قريباً';
  @override
  String get editFabricComingSoon => 'سيتم تنفيذ تعديل القماش قريباً';
  @override
  String get deleteFabric => 'حذف القماش';
  @override
  String get confirmDeleteFabric => 'هل أنت متأكد من حذف';
  @override
  String get fabricDeletedSuccess => 'تم حذف القماش بنجاح';
  @override
  String get fabricDeleteFailed => 'فشل في حذف القماش';

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myFavoritesTitle => 'مفضلتي';
  @override
  String get browseAndKeepFavorites => 'تصفح وحافظ على عناصر تحبها';
  @override
  String get errorLoadingFavorites => 'حدث خطأ في تحميل المفضلات';
  @override
  String get noFavoritesCurrently => 'لا توجد مفضلات حالياً';
  @override
  String get startAddingFavorites => 'ابدأ بإضافة منتجات للمفضلة';
  @override
  String get tailorType => 'خياط';
  @override
  String get abayaType => 'عباية';
  @override
  String get favoriteType => 'مفضل';
  @override
  String get ratingLabel => 'تقييم';
  @override
  String get removeFromFavorites => 'إزالة من المفضلة';
  @override
  String get item => 'عنصر';

  // ═══════════════════════════════════════════════════════════════════════════
  // Abayas Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get allFilter => 'الكل';
  @override
  String get abayasFilter => 'عبايات';
  @override
  String get fabricsFilter => 'أقمشة';
  @override
  String get setsFilter => 'أطقم';
  @override
  String get accessoriesFilter => 'إكسسوارات';
  @override
  String get abayasTitle => 'العبايات';
  @override
  String get modelTab => 'نموذج';
  @override
  String get productTab => 'منتج';
  @override
  String get delivery => 'توصيل';
  @override
  String get abayaFallback => 'عباية';
  @override
  String get lengthMeasure => 'الطول';
  @override
  String get sleeveMeasure => 'الكم';
  @override
  String get widthMeasure => 'العرض';
  @override
  String get productsAvailable => 'منتج متاح';
  @override
  String get productDetails => 'تفاصيل المنتج';
  @override
  String get results => 'نتيجة';
  @override
  String get measurementGuide => 'دليل القياس';
  @override
  String get lengthTip => 'الطول: قيسي من أعلى الكتف حتى أسفل العباية المطلوب.';
  @override
  String get sleeveTip =>
      'الكم: من بداية فتحة الرقبة مرورًا بالكتف حتى نهاية الكم.';
  @override
  String get widthTip => 'العرض: المسافة الأفقية بين الجانبين عند مستوى الصدر.';
  @override
  String get basicMeasurements => 'المقاسات الأساسية';
  @override
  String get allMeasurementsInInch => 'جميع المقاسات بالإنش (inch)';
  @override
  String get exampleLength => 'مثال: 54';
  @override
  String get exampleSleeve => 'مثال: 23';
  @override
  String get exampleWidth => 'مثال: 24';
  @override
  String get sleeveLengthLabel => 'طول الكم';
  @override
  String get noShopsAvailable => 'لا توجد محلات';
  @override
  String get abayaShopsTitle => 'محلات العبايات';
  @override
  String get searchForShop => 'ابحث عن محل…';
  @override
  String get noDelivery => 'لا يوجد توصيل';
  @override
  String get deliveryAvailable => 'توصيل متاح';
  @override
  String servicesCount(int count) => '$count خدمة';
  @override
  String get noProductsAvailable => 'لا توجد منتجات متاحة';
  @override
  String get tryCategoryOrSearch => 'جرب تغيير الفئة أو البحث';
  @override
  String addedItemToCart(String item) => 'تمت إضافة $item إلى السلة';
  @override
  String errorWithDetails(String error) => 'حدث خطأ: $error';
  @override
  String get pleaseSignInFirst => 'يرجى تسجيل الدخول أولاً';
  @override
  String get ratingFilterLabel => '4.0+ تقييم';
  @override
  String get productNotFound => 'المنتج غير موجود';
  @override
  String get errorLoadingProduct => 'حدث خطأ في تحميل المنتج';
  @override
  String get selectColorFirst => 'يرجى اختيار اللون أولاً';
  @override
  String get taxIncluded => 'شامل الضريبة';
  @override
  String get availableColors => 'الألوان المتاحة';
  @override
  String get qualityGuaranteed => 'جودة عالية مضمونة';
  @override
  String get returnWithinDays => 'استرجاع خلال 14 يوم';
  @override
  String get abayaLabel => 'عباية';
  @override
  String get menSuppliesShops => 'محلات المستلزمات الرجالية';
  @override
  String get searchMenShop => 'ابحث عن محل رجالي…';
  @override
  String get failedToLoadStores => 'فشل في تحميل المتاجر';
  @override
  String get noStoresAvailable => 'لا توجد متاجر';
  @override
  String get tryChangingSearchCriteria => 'جرب تغيير معايير البحث';
  @override
  String searchInShop(String shopName) => 'ابحث داخل $shopName…';
  @override
  String get sortLabel => 'فرز';
  @override
  String get failedToLoadProducts => 'فشل في تحميل المنتجات';
  @override
  String get productLabel => 'منتج';
  @override
  String get clothes => 'ملابس';
  @override
  String get shoes => 'أحذية';
  @override
  String get accessories => 'إكسسوارات';
  @override
  String get sandals => 'النعلان';
  @override
  String get headwear => 'المصار';
  @override
  String get abayaStore => 'متجر العبايات';
  @override
  String measurementsInInch(String length, String sleeve, String width) =>
      'المقاسات بالإنش: الطول $length in، الكم $sleeve in، العرض $width in';
  @override
  String get failedToSendOrder => 'فشل إرسال الطلب. يرجى المحاولة مرة أخرى.';
  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';
  @override
  String addedWithMeasurements(String item) =>
      'تمت إضافة $item للسلة مع اللون والمقاسات';
  @override
  String get abayaMeasurements => 'مقاسات العباية';
  @override
  String get enterMeasurementsInInch => 'أدخل المقاسات بالإنش';
  @override
  String get guideImageNotAvailable => 'صورة الدليل غير متوفرة';
  @override
  String get pleaseEnterValidValue => 'يرجى إدخال قيمة صحيحة';
  @override
  String get valueTooLarge => 'القيمة كبيرة جداً';
  @override
  String get optionalLabel => '(اختياري)';
  @override
  String get measurementsHintExample =>
      'مثال: أريدها واسعة قليلاً من الأكمام...';
  @override
  String get confirmMeasurementsAddCart => 'تأكيد المقاسات وإضافة للسلة';
  @override
  String get confirmMeasurementsProceed => 'تأكيد المقاسات ومتابعة الطلب';

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myAddressesTitle => 'عناويني';
  @override
  String get pleaseLoginToManageAddresses => 'يرجى تسجيل الدخول لإدارة عناوينك';
  @override
  String get addAndEditAddresses => 'أضف وعدّل عناوين الشحن والاستلام';
  @override
  String get errorFetchingAddresses => 'حدث خطأ في جلب العناوين';
  @override
  String get noAddressesYetTitle => 'لا توجد عناوين بعد';
  @override
  String get addAddressForDelivery => 'أضف عنوانك لتسهيل عملية التوصيل والدفع';
  @override
  String get deleteAddressTitle => 'حذف العنوان';
  @override
  String get confirmDeleteAddressMessage => 'هل أنت متأكد من حذف هذا العنوان؟';
  @override
  String get addressDeleted => 'تم حذف العنوان';
  @override
  String get addressAddedSuccess => 'تم إضافة العنوان بنجاح';
  @override
  String get addressUpdatedSuccess => 'تم تحديث العنوان بنجاح';
  @override
  String get addAddressButton => 'إضافة عنوان';
  @override
  String get defaultLabel => 'افتراضي';
  @override
  String get editLabel => 'تعديل';
  @override
  String get setAsDefaultLabel => 'تعيين كافتراضي';
  @override
  String get deleteLabel => 'حذف';
  @override
  String get addNewAddressTitle => 'إضافة عنوان جديد';
  @override
  String get editAddressTitle => 'تعديل العنوان';
  @override
  String get enterAccurateAddressData => 'يرجى إدخال بيانات عنوان دقيقة';
  @override
  String get addressLabelExample => 'اسم العنوان (مثال: المنزل، المكتب)';
  @override
  String get recipientNameLabel => 'اسم المستلم';
  @override
  String get phoneNumberLabel => 'رقم الهاتف';
  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';
  @override
  String get invalidPhoneNumber => 'رقم غير صالح';
  @override
  String get cityProvinceLabel => 'المدينة / المحافظة';
  @override
  String get areaWilayaLabel => 'المنطقة / الولاية';
  @override
  String get streetApartmentLabel => 'الشارع / الشقة';
  @override
  String get buildingHouseNumberOptional => 'المبنى / رقم المنزل (اختياري)';
  @override
  String get additionalDirectionsOptional => 'إرشادات إضافية (اختياري)';
  @override
  String get setAsDefaultAddress => 'تعيين كعنوان افتراضي';
  @override
  String get saveAddress => 'حفظ العنوان';
  @override
  String get updateAddress => 'تحديث العنوان';
  @override
  String get thisFieldRequired => 'هذا الحقل مطلوب';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Tracking Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get orderReceivedWaiting => 'تم استلام الطلب وهو في انتظار المراجعة';
  @override
  String get orderAcceptedPreparing => 'تم قبول الطلب وبدء التحضير';
  @override
  String get orderInProgressProcessing => 'الطلب قيد التنفيذ والتجهيز';
  @override
  String get orderCompletedSuccess => 'تم إكمال الطلب بنجاح';
  @override
  String get waitingStatus => 'في الانتظار';
  @override
  String get acceptedStatus => 'مقبول';
  @override
  String get inProgressStatus => 'قيد التنفيذ';
  @override
  String get completedStatus => 'مكتمل';

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional Order Tracking Keys
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get trackOrderTitle => 'تتبع الطلب';
  @override
  String get errorLoadingOrder => 'حدث خطأ في تحميل بيانات الطلب';
  @override
  String get cannotFindOrder => 'لا يمكن العثور على الطلب المطلوب';
  @override
  String get additionalInfo => 'معلومات إضافية';
  @override
  String get completionDate => 'تاريخ الإكمال';
  @override
  String get order => 'طلب';
  @override
  String get orderRejected => 'الطلب مرفوض';
  @override
  String get orderCancelled => 'الطلب ملغي';
  @override
  String get tailor => 'الخياط';
  @override
  String get homeLabel => 'المنزل';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Success Dialog
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get orderSubmittedSuccessfully => 'تم إرسال طلبك بنجاح!';
  @override
  String get continueShopping => 'متابعة التسوق';
  @override
  String get viewOrders => 'عرض الطلبات';
  @override
  String get guest => 'زائر';

  // ═══════════════════════════════════════════════════════════════════════════
  // Gift Feature - Send as Gift
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get sendAsGift => 'إرسال كهدية';
  @override
  String get thisOrderIsAGift => 'هذا الطلب هدية';
  @override
  String get recipientCity => 'المدينة / المحافظة';
  @override
  String get recipientAddress => 'العنوان الكامل';
  @override
  String get hidePriceFromRecipient => 'لا تعرض السعر للمستلم (مفاجأة)';
  @override
  String get giftRecipientSummary => 'بيانات المستلم';
  @override
  String get enterCityOrGovernorate => 'أدخل المدينة أو المحافظة';
  @override
  String get enterFullAddress => 'أدخل العنوان الكامل';
  @override
  String get cityRequired => 'المدينة مطلوبة';
  @override
  String get addressRequired => 'العنوان مطلوب';
  @override
  String get invalidPhoneFormat => 'صيغة رقم الهاتف غير صحيحة';
  @override
  String get editRecipient => 'تعديل';
  @override
  String get saveRecipient => 'حفظ بيانات المستلم';
  @override
  String get giftOptionEnabled => 'تم تفعيل خيار الهدية';
  @override
  String get giftInfoSaved => 'تم حفظ بيانات المستلم';

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional Keys for Remaining Hardcoded Strings
  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor names/labels
  @override
  String get tailorElegance => 'خياط الأناقة';
  @override
  String get fineTailoring => 'خياطة ناعمة';
  
  // Shop/Store related
  @override
  String get failedToUpdateList => 'فشل في تحديث القائمة';
  @override
  String get errorLoadingShops => 'حدث خطأ أثناء تحميل المحلات';
  @override
  String get noRegisteredShops => 'لا توجد محلات مسجلة حالياً';
  @override
  String get threeOMR => '٣ ر.ع';
  @override
  String get onTailoring => 'على التفصيل';
  @override
  String get discoverNewTailors => 'اكتشف خياطين جدد أو جرّب محلات ما طلبت منها من فترة';
  @override
  String get currentlyClosed => 'مغلق حالياً';
  @override
  String get theStore => 'المتجر';
  @override
  String get callLabel => 'اتصال';
  @override
  String get mapLabel => 'خريطة';
  
  // Measurements form
  @override
  String get showTraditionalForm => 'عرض النموذج التقليدي';
  @override
  String get showBodyMap => 'عرض خريطة الجسم';
  @override
  String get totalLength => 'الطول الكلي';
  @override
  String get upperSleeve => 'محيط الكم العلوي';
  @override
  String get lowerSleeve => 'محيط الكم السفلي';
  @override
  String get chest => 'الصدر';
  @override
  String get waist => 'الخصر';
  @override
  String get frontEmbroidery => 'التطريز الامامي';
  @override
  String get addNotesHint => 'أضف أي ملاحظات أو متطلبات خاصة...';
  @override
  String get measurementsSavedSuccess => 'تم حفظ المقاسات بنجاح';
  @override
  String get errorSaving => 'خطأ في الحفظ';
  @override
  String get saveMeasurements => 'حفظ المقاسات';
  @override
  String get tapPartToEnterMeasurement => 'اضغط على الجزء لإدخال المقاس';
  @override
  String get inch => 'إنش';
  @override
  String get measurementsForm => 'استمارة المقاسات';
  @override
  String get enterAtLeastOneMeasurement => 'يرجى إدخال مقاس واحد على الأقل';
  @override
  String get bottomCircumference => 'المحيط السفلي';
  
  // Embroidery
  @override
  String get selectEmbroideryColor => 'اختر لون التطريز';
  @override
  String get embroideryLinesCount => 'عدد خطوط التطريز';
  @override
  String get oneLine => 'خط واحد';
  @override
  String get twoLines => 'خطان';
  @override
  String get threeLines => 'ثلاثة خطوط';
  @override
  String get errorLoadingEmbroideryDesigns => 'حدث خطأ في تحميل تصاميم التطريز';
  @override
  String get noEmbroideryDesignsAvailable => 'لا توجد تصاميم تطريز متاحة';
  @override
  String get embroideryLabel => 'تطريز';
  
  // Fabrics
  @override
  String get searchFabricHint => 'ابحث عن نوع القماش أو الاسم';
  @override
  String get price => 'السعر';
  @override
  String get kidsDishdashaService => 'تفصيل دشداشة أطفال';
  @override
  String get searchInside => 'ابحث داخل';
  @override
  String get specialButtons => 'أزرار مميزة';
  @override
  String get readyCollars => 'ياقات جاهزة';
  @override
  String get classicCottonFabric => 'قماش قطني كلاسيك';
  @override
  String get manageFabrics => 'إدارة أقمشة';
  @override
  String get colorsLabel => 'الألوان';
  @override
  String get addColor => 'إضافة لون';
  @override
  String get noFabricsRegistered => 'لا توجد أقمشة مسجلة';
  @override
  String get pressAddToAddFabric => 'اضغط على زر الإضافة لإضافة قماش جديد';
  @override
  String get errorLoadingColors => 'حدث خطأ في تحميل الألوان';
  @override
  String get colorLabel => 'لون';
  @override
  String get colorOliveGreen => 'أخضر زيتي';
  
  // Abaya measurements
  @override
  String get notesExample => 'مثال: أريدها واسعة قليلًا، وإضافة جيوب داخلية';
  @override
  String get confirmMeasurementsAndProceed => 'تأكيد المقاسات ومتابعة الطلب';
  @override
  String get imageNotFound => 'لم يتم العثور على الصورة';
  @override
  String get measurementGuideZoom => 'دليل القياس — تكبير';
  @override
  String get enlargeImage => 'تكبير الصورة';
}
