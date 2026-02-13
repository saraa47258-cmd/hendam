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
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // Basic App Info
  // ═══════════════════════════════════════════════════════════════════════════
  String get appName;
  String get hindam;
  String get menTailoringShopsApp;
  String get bestTailorsInOnePlace;

  // ═══════════════════════════════════════════════════════════════════════════
  // Navigation
  // ═══════════════════════════════════════════════════════════════════════════
  String get home;
  String get orders;
  String get cart;
  String get profile;
  String get more;
  String get catalog;

  // ═══════════════════════════════════════════════════════════════════════════
  // Greetings
  // ═══════════════════════════════════════════════════════════════════════════
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get goodNight;
  String get hello;
  String get dearCustomer;
  String get welcomeTitle;
  String get welcomeBack;

  // ═══════════════════════════════════════════════════════════════════════════
  // Auth
  // ═══════════════════════════════════════════════════════════════════════════
  String get login;
  String get logout;
  String get signup;
  String get createNewAccount;
  String get continueAsGuest;
  String get browseAsGuest;
  String get logoutFromAccount;
  String get logoutConfirmation;
  String get logoutSuccess;
  String get pleaseLoginFirst;
  String get pleaseLoginToViewOrders;
  String get joinUsAndEnjoy;
  String get forgotPassword;
  String get email;
  String get password;
  String get confirmPassword;
  String get name;
  String get phoneNumber;
  String get rememberMe;
  String get dontHaveAccount;
  String get alreadyHaveAccount;

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites
  // ═══════════════════════════════════════════════════════════════════════════
  String get favorites;
  String get myFavorites;
  String get favoriteProducts;
  String get viewFavoriteProducts;
  String get noFavoritesYet;
  String get addedToFavorites;
  String get removedFromFavorites;

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses
  // ═══════════════════════════════════════════════════════════════════════════
  String get myAddresses;
  String get manageSavedAddresses;
  String get addAddress;
  String get editAddress;
  String get deleteAddress;
  String get noAddressesYet;
  String get addressTitle;
  String get city;
  String get street;
  String get building;
  String get apartment;
  String get defaultAddress;
  String get setAsDefault;

  // ═══════════════════════════════════════════════════════════════════════════
  // Orders
  // ═══════════════════════════════════════════════════════════════════════════
  String get myOrders;
  String get allOrders;
  String get pendingOrders;
  String get acceptedOrders;
  String get inProgressOrders;
  String get completedOrdersTab;
  String get rejectedOrders;
  String get noOrdersYet;
  String get startShoppingNow;
  String get browseProducts;
  String get orderDetails;
  String get orderStatus;
  String get orderDate;
  String get orderNumber;
  String get trackOrder;
  String get cancelOrder;
  String get reorder;
  String customerOrdersTitle(String name);
  String get noOrdersCurrently;
  String get noOrdersYetDescription;
  String get latestOrder;
  String get track;
  String get orderStatistics;
  String get searchOrdersHint;
  String noOrdersForStatus(String status);
  String ordersForStatusAppearHere(String status);
  String get revenue;
  String get errorLoadingOrders;
  String get featureComingSoon;
  String get processingStatus;
  String get shippingStatus;
  String get deliveredStatus;
  String get accept;
  String get reject;
  String get startProcessing;
  String get complete;
  String get orderAcceptedSuccess;
  String get orderAcceptedFailed;
  String get rejectOrderTitle;
  String get rejectOrderPrompt;
  String get orderRejectedSuccess;
  String get orderRejectedFailed;
  String get orderStartedSuccess;
  String get orderStartedFailed;
  String get orderCompletedFailed;

  // ═══════════════════════════════════════════════════════════════════════════
  // Profile & Account
  // ═══════════════════════════════════════════════════════════════════════════
  String get account;
  String get myAccount;
  String get manageYourDataAndOrders;
  String get personalInfo;
  String get editProfile;
  String get editNameAndPhone;
  String get profilePhotoUpdated;
  String get failedToUploadPhoto;
  String get changeProfilePhoto;
  String get chooseFromGallery;
  String get takePhoto;
  String get useCamera;

  // ═══════════════════════════════════════════════════════════════════════════
  // Statistics
  // ═══════════════════════════════════════════════════════════════════════════
  String get myStatistics;
  String get totalOrders;
  String get allOrdersMade;
  String get activeOrders;
  String get currentlyTracking;
  String get completedOrders;
  String get successfullyDelivered;
  String get cancelledRejected;
  String get cancelledOrRejected;

  // ═══════════════════════════════════════════════════════════════════════════
  // Settings
  // ═══════════════════════════════════════════════════════════════════════════
  String get settings;
  String get personalSettings;
  String get notifications;
  String get orderStatusAlerts;
  String get orderStatusAndOffersAlerts;
  String get offersAndDiscounts;
  String get receiveExclusiveOffers;
  String get language;
  String get accountManagement;
  String get viewAndTrackOrders;
  String get paymentMethods;
  String get manageCardsAndPayment;
  String get noSavedPaymentMethods;
  String get addPaymentMethodLater;
  String get addPaymentMethod;
  String get privacyAndSecurity;
  String get securityAndPrivacySettings;
  String get changePassword;
  String get updatePasswordRegularly;
  String get dataWeCollect;
  String get howWeUseYourData;
  String get privacyPolicy;
  String get readFullPrivacyPolicy;
  String get helpAndSupport;
  String get helpCenter;
  String get faqAndSupport;
  String get faqTitle;
  String get faqSubtitle;
  String get contactUs;
  String get supportAndInquiries;
  String get phone;
  String get supportAvailableAnytime;
  String get aboutApp;
  String get appVersionAndInfo;
  String get appVersionLabel;
  String appVersion(String version);
  String get aboutAppDescription;
  String get website;
  String get infoAndAccount;
  String get notificationsAndOffers;
  String get appLanguage;

  // ═══════════════════════════════════════════════════════════════════════════
  // Language
  // ═══════════════════════════════════════════════════════════════════════════
  String get chooseLanguage;
  String get automatic;
  String get useDeviceLanguage;
  String get languageChangedToDevice;
  String get arabic;
  String get languageChangedToArabic;
  String get english;
  String get languageChangedToEnglish;

  // ═══════════════════════════════════════════════════════════════════════════
  // Measurements
  // ═══════════════════════════════════════════════════════════════════════════
  String get enterMeasurements;
  String get saveExperimental;

  // ═══════════════════════════════════════════════════════════════════════════
  // Home Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get categories;
  String get menTailor;
  String get abayas;
  String get merchants;
  String get nearbyTailors;
  String get viewAll;
  String get searchTailorOrService;
  String get discount40;
  String get onAllMensTailoring;
  String get limitedOffer;
  String get freeDelivery;
  String get forOrdersAbove50;
  String get newLabel;
  String get eidThobe;
  String get exclusiveCollection;
  String get exclusive;
  String get menTailoring;
  String get exclusiveOffer;
  String get saveUpTo;
  String get discoverNow;
  String get noTailorShopsRegistered;
  String get unableToLoadTailorShops;
  String get onThobeTailoring;
  String get discoverNewShopsOrTry;
  String get riyal3;
  String get rating4Plus;
  String get refreshing;
  String shopsListUpdatedSuccess(int count);
  String get failedToRefreshList;
  String get store;
  String get refreshList;
  String get yesCancel;
  String get continueToRecipientInfo;
  String get sendingOrder;
  String get sendGiftRequest;
  String get addNewFabricSoon;
  String get editFabricSoon;
  String get openNowFilter;
  String get deliveryFilter;
  String get priceUp;
  String get priceDown;
  String get productAddedToCart;
  String get confirmCancelOrder;
  String get chooseFabricType;
  String get browseAvailableFabrics;

  // ═══════════════════════════════════════════════════════════════════════════
  // Features
  // ═══════════════════════════════════════════════════════════════════════════
  String get fastDelivery;
  String get toAllOman;
  String get guaranteedQuality;
  String get originalProducts100;
  String get continuousSupport;
  String get customerService247;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Details
  // ═══════════════════════════════════════════════════════════════════════════
  String get tailorDetails;
  String get services;
  String get fabrics;
  String get reviews;
  String get open;
  String get closed;
  String get openNow;
  String get closedNow;
  String get km;
  String get fastDeliveryTag;
  String get menDishdasha;
  String get omaniEmbroidery;
  String get homeMeasurement;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design
  // ═══════════════════════════════════════════════════════════════════════════
  String get tailoringDesign;
  String get chooseFabric;
  String get chooseDesign;
  String get reviewOrder;
  String get measurements;
  String get length;
  String get shoulder;
  String get neck;
  String get armLength;
  String get wristWidth;
  String get chestWidth;
  String get bottomWidth;
  String get embroideryLength;
  String get embroideryDesign;
  String get selectEmbroidery;
  String get noEmbroidery;
  String get continueButton;
  String get back;
  String get next;
  String get estimatedCost;
  String get submitOrder;

  // ═══════════════════════════════════════════════════════════════════════════
  // Cart
  // ═══════════════════════════════════════════════════════════════════════════
  String get shoppingCart;
  String get cartEmpty;
  String get cartEmptyMessage;
  String get startShopping;
  String get total;
  String get subtotal;
  String get deliveryFee;
  String get checkout;
  String get removeFromCart;
  String get quantity;
  String get updateCart;

  // ═══════════════════════════════════════════════════════════════════════════
  // Common Actions
  // ═══════════════════════════════════════════════════════════════════════════
  String get cancel;
  String get confirm;
  String get save;
  String get delete;
  String get edit;
  String get done;
  String get ok;
  String get close;
  String get retry;
  String get loading;
  String get search;
  String get filter;
  String get sort;
  String get apply;
  String get reset;
  String get clear;
  String get refresh;
  String get seeMore;
  String get seeLess;
  String get select;
  String get selected;
  String get add;
  String get remove;
  String get update;
  String get submit;
  String get send;
  String get share;
  String get copy;
  String get copied;

  // ═══════════════════════════════════════════════════════════════════════════
  // Errors & Messages
  // ═══════════════════════════════════════════════════════════════════════════
  String get error;
  String get success;
  String get warning;
  String get info;
  String get noData;
  String get noResults;
  String get somethingWentWrong;
  String get tryAgain;
  String get connectionError;
  String get noInternet;
  String get serverError;
  String get sessionExpired;
  String get invalidInput;
  String get requiredField;
  String get invalidEmail;
  String get invalidPhone;
  String get passwordTooShort;
  String get passwordsDontMatch;

  // ═══════════════════════════════════════════════════════════════════════════
  // Time
  // ═══════════════════════════════════════════════════════════════════════════
  String minutesAgo(int n);
  String hoursAgo(int n);
  String get yesterday;
  String daysAgo(int n);
  String get justNow;
  String get today;
  String get tomorrow;

  // ═══════════════════════════════════════════════════════════════════════════
  // Currency
  // ═══════════════════════════════════════════════════════════════════════════
  String currency(String value);
  String get omr;

  // ═══════════════════════════════════════════════════════════════════════════
  // Validation
  // ═══════════════════════════════════════════════════════════════════════════
  String get pleaseEnterValue;
  String get pleaseEnterValidEmail;
  String get pleaseEnterValidPhone;
  String get pleaseEnterValidPassword;
  String get pleaseEnterName;
  String get enterValidMeasurement;

  // ═══════════════════════════════════════════════════════════════════════════
  // Confirmation Dialogs
  // ═══════════════════════════════════════════════════════════════════════════
  String get confirmLogout;
  String get confirmDelete;
  String get confirmCancel;
  String get areYouSure;
  String get yes;
  String get no;

  // ═══════════════════════════════════════════════════════════════════════════
  // Empty States
  // ═══════════════════════════════════════════════════════════════════════════
  String get emptyCart;
  String get emptyOrders;
  String get emptyFavorites;
  String get emptyAddresses;
  String get noTailorsNearby;
  String get noServicesAvailable;
  String get noFabricsAvailable;

  // ═══════════════════════════════════════════════════════════════════════════
  // Login Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get welcomeBackTitle;
  String get loginToAccessAccount;
  String get enterYourEmail;
  String get enterYourPassword;
  String get loginSuccessful;
  String get loginFailed;

  // ═══════════════════════════════════════════════════════════════════════════
  // Signup Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get joinHindam;
  String get createAccountAndEnjoy;
  String get fullName;
  String get enterFullName;
  String get phoneOptional;
  String get reEnterPassword;
  String get accountCreatedSuccessfully;
  String get accountCreationFailed;
  String get pleaseEnterFullName;
  String get passwordMinLength;
  String get pleaseConfirmPassword;

  // ═══════════════════════════════════════════════════════════════════════════
  // Cart Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get clearAll;
  String get addProductsToStart;
  String get completeOrder;
  String get clearCart;
  String get clearCartConfirmation;
  String get cartCleared;
  String get orderTotalAmount;
  String get confirmOrder;
  String get orderSentSuccessfully;
  String get color;
  String get notes;

  // ═══════════════════════════════════════════════════════════════════════════
  // Forgot Password Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get resetPassword;
  String get enterEmailToReset;
  String get sendResetLink;
  String get resetLinkSent;
  String get resetLinkFailed;

  // ═══════════════════════════════════════════════════════════════════════════
  // Edit Profile Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get saveChanges;
  String get profileUpdatedSuccessfully;
  String get profileUpdateFailed;

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get addNewAddress;
  String get addressName;
  String get fullAddress;
  String get addressAddedSuccessfully;
  String get addressDeletedSuccessfully;
  String get confirmDeleteAddress;
  String get addressSavedSuccessfully;

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get addToCart;
  String get itemRemovedFromFavorites;

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Status Labels
  // ═══════════════════════════════════════════════════════════════════════════
  String get pending;
  String get accepted;
  String get inProgress;
  String get completed;
  String get rejected;
  String get cancelled;
  String get orderRejectionReason;

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Details
  // ═══════════════════════════════════════════════════════════════════════════
  String get fabricDetails;
  String get fabricName;
  String get fabricType;
  String get fabricColor;
  String get totalPrice;
  String get tailorInfo;
  String get shopName;
  String get customerName;
  String get additionalNotes;
  String get rejectionReason;
  String get lastUpdate;
  String get orderNotFound;

  // ═══════════════════════════════════════════════════════════════════════════
  // Measurements
  // ═══════════════════════════════════════════════════════════════════════════
  String get shoulderWidth;
  String get chestCircumference;
  String get waistCircumference;
  String get hipCircumference;
  String get sleeveLength;
  String get neckCircumference;
  String get armLength2;
  String get cm;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get eleganceTailor;
  String get eliteCenter;
  String get fashionTouch;
  String get softTailoring;

  // ═══════════════════════════════════════════════════════════════════════════
  // Product & Service Actions
  // ═══════════════════════════════════════════════════════════════════════════
  String get addedToCart;
  String get orderNow;
  String get buyNow;
  String get sortBy;
  String get priceHighToLow;
  String get priceLowToHigh;
  String get newest;
  String get rating;

  // ═══════════════════════════════════════════════════════════════════════════
  // Permission Dialogs
  // ═══════════════════════════════════════════════════════════════════════════
  String get cameraPermissionRequired;
  String get cameraAccessNeeded;
  String get galleryPermissionRequired;
  String get galleryAccessNeeded;
  String get permissionDenied;
  String get openSettings;

  // ═══════════════════════════════════════════════════════════════════════════
  // Error Page
  // ═══════════════════════════════════════════════════════════════════════════
  String get pageNotFound;
  String get goToHome;

  // ═══════════════════════════════════════════════════════════════════════════
  // Cancel Order
  // ═══════════════════════════════════════════════════════════════════════════
  String get cancelOrderConfirmation;
  String get yesCancelOrder;
  String get orderCancelledSuccessfully;
  String get orderCancellationFailed;
  String get cancelledByCustomer;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get selectFabricFirst;
  String get selectDesignFirst;
  String get enterMeasurementsFirst;
  String get fabricPrice;
  String get tailoringCost;
  String get embroideryCost;
  String get orderReview;
  String get selectedFabric;
  String get selectedDesign;
  String get embroideryType;

  // ═══════════════════════════════════════════════════════════════════════════
  // Forgot Password Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get emailSent;
  String get resetLinkSentDescription;
  String get enterEmailForReset;
  String get sendResetLinkButton;
  String get backToLogin;
  String get resend;
  String get emailSendFailed;

  // ═══════════════════════════════════════════════════════════════════════════
  // Edit Profile Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get noUserLoggedIn;
  String get emailCannotBeChanged;
  String get errorOccurred;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Details Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get muscat;
  String get type;
  String get lines;
  String get fastDeliveryLabel;
  String get menDishdashaTailoring;
  String get serviceFee;
  String get time;
  String get minutes;
  String get availableServices;
  String get loginRequired;
  String get loginToOrderService;
  String get orderNowButton;
  String get duration;
  String get menDishdashaTailoringService;
  String get shorteningAlteration;
  String get wideningNarrowing;
  String get days;
  String get sameDay;
  String get oneDay;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get cmLabel;
  String get inchLabel;
  String get pleaseSelectFabricType;
  String get pleaseEnterMeasurementsCorrectly;
  String get pleaseSelectFabric;
  String get pleaseLoginToOrder;
  String get orderSubmissionError;
  String get fabricStep;
  String get measurementsAndColor;
  String get embroideryStep;
  String get viewOrder;
  String get continueText;
  String get selectFabricType;
  String get browseFabricsAvailable;
  String get noFabricsAvailableNow;
  String get fabric;
  String get change;
  String get measurementUnit;
  String get additionalNotesLabel;
  String get enterAdditionalDetails;
  String get embroideryThreadColor;
  String get decorativeLines;
  String get noDesignsAvailable;
  String get embroideryDesigns;
  String get selectEmbroideryDesign;
  String get none;
  String get orderSentSuccess;
  String get orderNumberLabel;
  String get tailorLabel;
  String get totalLabel;
  String get willContactYouSoon;
  String get okButton;
  String get reviewOrderTitle;
  String get nameLabel;
  String get cityLabel;
  String get fabricTypeLabel;
  String get designLabel;
  String get threadColorLabel;
  String get linesLabel;
  String get measurementsLabel;
  String get lengthLabel;
  String get shoulderLabel;
  String get neckLabel;
  String get armLengthLabel;
  String get wristWidthLabel;
  String get chestWidthWithSides;
  String get patternLength;
  String get backButton;
  String get confirmSubmit;

  // ═══════════════════════════════════════════════════════════════════════════
  // Color Names
  // ═══════════════════════════════════════════════════════════════════════════
  String get colorNavy;
  String get colorBlue;
  String get colorGray;
  String get colorGreen;
  String get colorGold;
  String get colorBrown;
  String get colorPurple;
  String get colorBlack;
  String get colorSilver;
  String get colorWhite;
  String get colorTeal;
  String get colorBurgundy;
  String get customColor;

  // ═══════════════════════════════════════════════════════════════════════════
  // Gift Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get giftLabel;
  String get giftRecipientData;
  String get selectFabricForGift;
  String get enterGiftRecipientMeasurements;
  String get canAskRecipientForMeasurements;
  String get required;
  String get enterValidNumber;
  String get selectThreadColorAndCount;
  String get threadColor;
  String get noColorsAvailable;
  String get threadCount;
  String get thread;
  String get threadsLimit;
  String get failedToLoadDesigns;
  String get retryButton;
  String get giftRecipientInfo;
  String get enterGiftRecipientDetails;
  String get recipientName;
  String get enterRecipientName;
  String get recipientNameRequired;
  String get recipientPhoneOptional;
  String get forDeliveryCoordination;
  String get giftMessageOptional;
  String get writeShortMessageToRecipient;
  String get deliveryNotesOptional;
  String get deliveryNotesExample;
  String get totalAmount;
  String get sending;
  String get sendGiftOrder;
  String get clickToSelect;
  String get totalPriceLabel;
  String get continueToRecipientData;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Store Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get tailoringServices;
  String get giftSection;
  String get menDishdashaTailoringTitle;
  String get childrenDishdashaTailoring;
  String get premiumSummerFabric;
  String get japaneseCottonFabric;
  String get searchInSection;
  String get priceLabel;
  String get quantityLabel;
  String get addedToCartMessage;
  String get addToCartButton;
  String get viewAllButton;

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Fabric Admin Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get manageFabricsFor;
  String get searchInFabrics;
  String get addFabric;
  String get fabricStatistics;
  String get totalFabrics;
  String get tailorFabrics;
  String get errorLoadingFabrics;
  String get noFabricsForTailor;
  String get addFirstFabric;
  String get searchError;
  String get noSearchResults;
  String get typeNotSpecified;
  String get perMeter;
  String get addFabricComingSoon;
  String get editFabricComingSoon;
  String get deleteFabric;
  String get confirmDeleteFabric;
  String get fabricDeletedSuccess;
  String get fabricDeleteFailed;

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get myFavoritesTitle;
  String get browseAndKeepFavorites;
  String get errorLoadingFavorites;
  String get noFavoritesCurrently;
  String get startAddingFavorites;
  String get tailorType;
  String get abayaType;
  String get favoriteType;

  // ═══════════════════════════════════════════════════════════════════════════
  // Abayas Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get allFilter;
  String get abayasFilter;
  String get fabricsFilter;
  String get setsFilter;
  String get accessoriesFilter;
  String get abayasTitle;
  String get modelTab;
  String get productTab;
  String get delivery;
  String get abayaFallback;
  String get lengthMeasure;
  String get sleeveMeasure;
  String get widthMeasure;
  String get productsAvailable;
  String get productDetails;
  String get results;
  String get measurementGuide;
  String get lengthTip;
  String get sleeveTip;
  String get widthTip;
  String get basicMeasurements;
  String get allMeasurementsInInch;
  String get exampleLength;
  String get exampleSleeve;
  String get exampleWidth;
  String get sleeveLengthLabel;
  String get noShopsAvailable;
  String get abayaShopsTitle;
  String get searchForShop;
  String get noDelivery;
  String get deliveryAvailable;
  String servicesCount(int count);
  String get noProductsAvailable;
  String get tryCategoryOrSearch;
  String addedItemToCart(String item);
  String errorWithDetails(String error);
  String get pleaseSignInFirst;
  String get ratingFilterLabel;
  String get productNotFound;
  String get errorLoadingProduct;
  String get selectColorFirst;
  String get taxIncluded;
  String get availableColors;
  String get qualityGuaranteed;
  String get returnWithinDays;
  String get abayaLabel;
  String get menSuppliesShops;
  String get searchMenShop;
  String get failedToLoadStores;
  String get noStoresAvailable;
  String get tryChangingSearchCriteria;
  String searchInShop(String shopName);
  String get sortLabel;
  String get failedToLoadProducts;
  String get productLabel;
  String get clothes;
  String get shoes;
  String get accessories;
  String get sandals;
  String get headwear;
  String get abayaStore;
  String measurementsInInch(String length, String sleeve, String width);
  String get failedToSendOrder;
  String get unexpectedError;
  String addedWithMeasurements(String item);
  String get abayaMeasurements;
  String get enterMeasurementsInInch;
  String get guideImageNotAvailable;
  String get pleaseEnterValidValue;
  String get valueTooLarge;
  String get optionalLabel;
  String get measurementsHintExample;
  String get confirmMeasurementsAddCart;
  String get confirmMeasurementsProceed;
  String get ratingLabel;
  String get removeFromFavorites;
  String get item;

  // Order Success Dialog
  String get orderSubmittedSuccessfully;
  String get continueShopping;
  String get viewOrders;
  String get guest;

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get myAddressesTitle;
  String get pleaseLoginToManageAddresses;
  String get addAndEditAddresses;
  String get errorFetchingAddresses;
  String get noAddressesYetTitle;
  String get addAddressForDelivery;
  String get deleteAddressTitle;
  String get confirmDeleteAddressMessage;
  String get addressDeleted;
  String get addressAddedSuccess;
  String get addressUpdatedSuccess;
  String get addAddressButton;
  String get defaultLabel;
  String get editLabel;
  String get setAsDefaultLabel;
  String get deleteLabel;
  String get addNewAddressTitle;
  String get editAddressTitle;
  String get enterAccurateAddressData;
  String get addressLabelExample;
  String get recipientNameLabel;
  String get phoneNumberLabel;
  String get enterPhoneNumber;
  String get invalidPhoneNumber;
  String get cityProvinceLabel;
  String get areaWilayaLabel;
  String get streetApartmentLabel;
  String get buildingHouseNumberOptional;
  String get additionalDirectionsOptional;
  String get setAsDefaultAddress;
  String get saveAddress;
  String get updateAddress;
  String get thisFieldRequired;
  String get homeLabel;

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Tracking Screen
  // ═══════════════════════════════════════════════════════════════════════════
  String get orderReceivedWaiting;
  String get orderAcceptedPreparing;
  String get orderInProgressProcessing;
  String get orderCompletedSuccess;
  String get waitingStatus;
  String get acceptedStatus;
  String get inProgressStatus;
  String get completedStatus;

  // Additional Order Tracking Keys
  String get trackOrderTitle;
  String get errorLoadingOrder;
  String get cannotFindOrder;
  String get additionalInfo;
  String get completionDate;
  String get order;
  String get orderRejected;
  String get orderCancelled;
  String get tailor;

  // ═══════════════════════════════════════════════════════════════════════════
  // Gift Feature - Send as Gift
  // ═══════════════════════════════════════════════════════════════════════════
  String get sendAsGift;
  String get thisOrderIsAGift;
  String get recipientCity;
  String get recipientAddress;
  String get hidePriceFromRecipient;
  String get giftRecipientSummary;
  String get enterCityOrGovernorate;
  String get enterFullAddress;
  String get cityRequired;
  String get addressRequired;
  String get invalidPhoneFormat;
  String get editRecipient;
  String get saveRecipient;
  String get giftOptionEnabled;
  String get giftInfoSaved;

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional Keys for Remaining Hardcoded Strings
  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor names/labels
  String get tailorElegance;
  String get fineTailoring;
  
  // Shop/Store related
  String get failedToUpdateList;
  String get errorLoadingShops;
  String get noRegisteredShops;
  String get threeOMR;
  String get onTailoring;
  String get discoverNewTailors;
  String get currentlyClosed;
  String get theStore;
  String get callLabel;
  String get mapLabel;
  
  // Measurements form
  String get showTraditionalForm;
  String get showBodyMap;
  String get totalLength;
  String get upperSleeve;
  String get lowerSleeve;
  String get chest;
  String get waist;
  String get frontEmbroidery;
  String get addNotesHint;
  String get measurementsSavedSuccess;
  String get errorSaving;
  String get saveMeasurements;
  String get tapPartToEnterMeasurement;
  String get inch;
  String get measurementsForm;
  String get enterAtLeastOneMeasurement;
  String get bottomCircumference;
  
  // Embroidery
  String get selectEmbroideryColor;
  String get embroideryLinesCount;
  String get oneLine;
  String get twoLines;
  String get threeLines;
  String get errorLoadingEmbroideryDesigns;
  String get noEmbroideryDesignsAvailable;
  String get embroideryLabel;
  
  // Fabrics
  String get searchFabricHint;
  String get price;
  String get kidsDishdashaService;
  String get searchInside;
  String get specialButtons;
  String get readyCollars;
  String get classicCottonFabric;
  String get manageFabrics;
  String get colorsLabel;
  String get addColor;
  String get noFabricsRegistered;
  String get pressAddToAddFabric;
  String get errorLoadingColors;
  String get colorLabel;
  String get colorOliveGreen;
  
  // Abaya measurements
  String get notesExample;
  String get confirmMeasurementsAndProceed;
  String get imageNotFound;
  String get measurementGuideZoom;
  String get enlargeImage;
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
