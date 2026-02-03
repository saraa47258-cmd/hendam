import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'هندام'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get orders;

  /// No description provided for @cart.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء النور'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلة سعيدة'**
  String get goodNight;

  /// No description provided for @dearCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميلنا العزيز'**
  String get dearCustomer;

  /// No description provided for @hindam.
  ///
  /// In ar, this message translates to:
  /// **'هندام'**
  String get hindam;

  /// No description provided for @menTailoringShopsApp.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق محلات الخياطة الرجالية'**
  String get menTailoringShopsApp;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @createNewAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createNewAccount;

  /// No description provided for @continueAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'متابعة كزائر'**
  String get continueAsGuest;

  /// No description provided for @browseAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'تصفح كزائر'**
  String get browseAsGuest;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @myFavorites.
  ///
  /// In ar, this message translates to:
  /// **'مفضلاتي'**
  String get myFavorites;

  /// No description provided for @favoriteProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات مفضلة'**
  String get favoriteProducts;

  /// No description provided for @viewFavoriteProducts.
  ///
  /// In ar, this message translates to:
  /// **'عرض المنتجات المفضلة'**
  String get viewFavoriteProducts;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تسجيل الدخول أولاً'**
  String get pleaseLoginFirst;

  /// No description provided for @myAddresses.
  ///
  /// In ar, this message translates to:
  /// **'عناويني'**
  String get myAddresses;

  /// No description provided for @manageSavedAddresses.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العناوين المحفوظة'**
  String get manageSavedAddresses;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @allOrders.
  ///
  /// In ar, this message translates to:
  /// **'جميع الطلبات'**
  String get allOrders;

  /// No description provided for @pendingOrders.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get pendingOrders;

  /// No description provided for @acceptedOrders.
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get acceptedOrders;

  /// No description provided for @inProgressOrders.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get inProgressOrders;

  /// No description provided for @completedOrdersTab.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completedOrdersTab;

  /// No description provided for @rejectedOrders.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get rejectedOrders;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} دقيقة'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} ساعة'**
  String hoursAgo(int n);

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} يوم'**
  String daysAgo(int n);

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'{value} ر.ع'**
  String currency(String value);

  /// No description provided for @myOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myOrders;

  /// No description provided for @pleaseLoginToViewOrders.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تسجيل الدخول لعرض الطلبات'**
  String get pleaseLoginToViewOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بعد'**
  String get noOrdersYet;

  /// No description provided for @startShoppingNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق الآن'**
  String get startShoppingNow;

  /// No description provided for @browseProducts.
  ///
  /// In ar, this message translates to:
  /// **'تصفح المنتجات'**
  String get browseProducts;

  /// No description provided for @myAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myAccount;

  /// No description provided for @manageYourDataAndOrders.
  ///
  /// In ar, this message translates to:
  /// **'إدارة بياناتك وطلباتك'**
  String get manageYourDataAndOrders;

  /// No description provided for @myStatistics.
  ///
  /// In ar, this message translates to:
  /// **'إحصائياتي'**
  String get myStatistics;

  /// No description provided for @totalOrders.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get totalOrders;

  /// No description provided for @allOrdersMade.
  ///
  /// In ar, this message translates to:
  /// **'كل الطلبات التي قمت بها'**
  String get allOrdersMade;

  /// No description provided for @activeOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات نشطة'**
  String get activeOrders;

  /// No description provided for @currentlyTracking.
  ///
  /// In ar, this message translates to:
  /// **'قيد المتابعة حالياً'**
  String get currentlyTracking;

  /// No description provided for @completedOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات مكتملة'**
  String get completedOrders;

  /// No description provided for @successfullyDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليمها بنجاح'**
  String get successfullyDelivered;

  /// No description provided for @cancelledRejected.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة / مرفوضة'**
  String get cancelledRejected;

  /// No description provided for @cancelledOrRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاؤها أو رفضها'**
  String get cancelledOrRejected;

  /// No description provided for @personalSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات الشخصية'**
  String get personalSettings;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @orderStatusAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات حالة الطلب والعروض'**
  String get orderStatusAlerts;

  /// No description provided for @offersAndDiscounts.
  ///
  /// In ar, this message translates to:
  /// **'عروض وتخفيضات'**
  String get offersAndDiscounts;

  /// No description provided for @receiveExclusiveOffers.
  ///
  /// In ar, this message translates to:
  /// **'استقبال العروض الحصرية'**
  String get receiveExclusiveOffers;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @accountManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الحساب'**
  String get accountManagement;

  /// No description provided for @viewAndTrackOrders.
  ///
  /// In ar, this message translates to:
  /// **'عرض ومتابعة الطلبات'**
  String get viewAndTrackOrders;

  /// No description provided for @paymentMethods.
  ///
  /// In ar, this message translates to:
  /// **'طرق الدفع'**
  String get paymentMethods;

  /// No description provided for @manageCardsAndPayment.
  ///
  /// In ar, this message translates to:
  /// **'إدارة البطاقات والدفع'**
  String get manageCardsAndPayment;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية والأمان'**
  String get privacyAndSecurity;

  /// No description provided for @securityAndPrivacySettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الأمان والخصوصية'**
  String get securityAndPrivacySettings;

  /// No description provided for @helpAndSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpAndSupport;

  /// No description provided for @helpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get helpCenter;

  /// No description provided for @faqAndSupport.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة والدعم'**
  String get faqAndSupport;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @appVersionAndInfo.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق ومعلومات إضافية'**
  String get appVersionAndInfo;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @welcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get welcomeTitle;

  /// No description provided for @joinUsAndEnjoy.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلينا واستمتع بتجربة تسوق مميزة'**
  String get joinUsAndEnjoy;

  /// No description provided for @fastDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل سريع'**
  String get fastDelivery;

  /// No description provided for @toAllOman.
  ///
  /// In ar, this message translates to:
  /// **'لجميع أنحاء عُمان'**
  String get toAllOman;

  /// No description provided for @guaranteedQuality.
  ///
  /// In ar, this message translates to:
  /// **'جودة مضمونة'**
  String get guaranteedQuality;

  /// No description provided for @originalProducts100.
  ///
  /// In ar, this message translates to:
  /// **'منتجات أصلية 100%'**
  String get originalProducts100;

  /// No description provided for @continuousSupport.
  ///
  /// In ar, this message translates to:
  /// **'دعم متواصل'**
  String get continuousSupport;

  /// No description provided for @customerService247.
  ///
  /// In ar, this message translates to:
  /// **'خدمة عملاء 24/7'**
  String get customerService247;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutFromAccount.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من حسابك'**
  String get logoutFromAccount;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logoutConfirmation;

  /// No description provided for @logoutSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج بنجاح'**
  String get logoutSuccess;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get chooseLanguage;

  /// No description provided for @automatic.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get automatic;

  /// No description provided for @useDeviceLanguage.
  ///
  /// In ar, this message translates to:
  /// **'استخدام لغة الجهاز'**
  String get useDeviceLanguage;

  /// No description provided for @languageChangedToDevice.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة إلى لغة الجهاز'**
  String get languageChangedToDevice;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @languageChangedToArabic.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة إلى العربية'**
  String get languageChangedToArabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageChangedToEnglish.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة إلى الإنجليزية'**
  String get languageChangedToEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
