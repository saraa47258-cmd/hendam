import 'app_localizations.dart';

// ignore_for_file: type=lint

/// English translations for AppLocalizations
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.locale = 'en']);

  // ═══════════════════════════════════════════════════════════════════════════
  // Basic App Info
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get appName => 'Hindam';
  @override
  String get hindam => 'Hindam';
  @override
  String get menTailoringShopsApp => 'Men\'s Tailoring & Merchants App';
  @override
  String get bestTailorsInOnePlace => 'The best tailors and shops in one place';

  // ═══════════════════════════════════════════════════════════════════════════
  // Navigation
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get home => 'Home';
  @override
  String get orders => 'Orders';
  @override
  String get cart => 'Cart';
  @override
  String get profile => 'Profile';
  @override
  String get more => 'More';
  @override
  String get catalog => 'Catalog';

  // ═══════════════════════════════════════════════════════════════════════════
  // Greetings
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get goodMorning => 'Good Morning';
  @override
  String get goodAfternoon => 'Good Afternoon';
  @override
  String get goodEvening => 'Good Evening';
  @override
  String get goodNight => 'Good Night';
  @override
  String get hello => 'Hello 👋';
  @override
  String get dearCustomer => 'Dear Customer';
  @override
  String get welcomeTitle => 'Welcome';
  @override
  String get welcomeBack => 'Welcome Back';

  // ═══════════════════════════════════════════════════════════════════════════
  // Auth
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get login => 'Login';
  @override
  String get logout => 'Logout';
  @override
  String get signup => 'Sign Up';
  @override
  String get createNewAccount => 'Create New Account';
  @override
  String get continueAsGuest => 'Continue as Guest';
  @override
  String get browseAsGuest => 'Browse as Guest';
  @override
  String get logoutFromAccount => 'End current session';
  @override
  String get logoutConfirmation => 'Do you want to logout from your account?';
  @override
  String get logoutSuccess => 'Logged out successfully';
  @override
  String get pleaseLoginFirst => 'Please login first';
  @override
  String get pleaseLoginToViewOrders => 'Please login to view your orders';
  @override
  String get joinUsAndEnjoy => 'Join us and enjoy a unique shopping experience';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get name => 'Name';
  @override
  String get phoneNumber => 'Phone Number';
  @override
  String get rememberMe => 'Remember Me';
  @override
  String get dontHaveAccount => 'Don\'t have an account?';
  @override
  String get alreadyHaveAccount => 'Already have an account?';

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get favorites => 'Favorites';
  @override
  String get myFavorites => 'My Favorites';
  @override
  String get favoriteProducts => 'Favorite Products';
  @override
  String get viewFavoriteProducts => 'View favorite products';
  @override
  String get noFavoritesYet => 'No favorites yet';
  @override
  String get addedToFavorites => 'Added to favorites';
  @override
  String get removedFromFavorites => 'Removed from favorites';

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myAddresses => 'My Addresses';
  @override
  String get manageSavedAddresses => 'Manage saved addresses';
  @override
  String get addAddress => 'Add Address';
  @override
  String get editAddress => 'Edit Address';
  @override
  String get deleteAddress => 'Delete Address';
  @override
  String get noAddressesYet => 'No saved addresses yet';
  @override
  String get addressTitle => 'Address Title';
  @override
  String get city => 'City';
  @override
  String get street => 'Street';
  @override
  String get building => 'Building';
  @override
  String get apartment => 'Apartment';
  @override
  String get defaultAddress => 'Default Address';
  @override
  String get setAsDefault => 'Set as default';

  // ═══════════════════════════════════════════════════════════════════════════
  // Orders
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myOrders => 'My Orders';
  @override
  String get allOrders => 'All';
  @override
  String get pendingOrders => 'Pending';
  @override
  String get acceptedOrders => 'Accepted';
  @override
  String get inProgressOrders => 'In Progress';
  @override
  String get completedOrdersTab => 'Completed';
  @override
  String get rejectedOrders => 'Rejected';
  @override
  String get noOrdersYet => 'No orders yet';
  @override
  String get startShoppingNow => 'Start shopping now!';
  @override
  String get browseProducts => 'Browse Products';
  @override
  String get orderDetails => 'Order Details';
  @override
  String get orderStatus => 'Order Status';
  @override
  String get orderDate => 'Order Date';
  @override
  String get orderNumber => 'Order Number';
  @override
  String get trackOrder => 'Track Order';
  @override
  String get cancelOrder => 'Cancel Order';
  @override
  String get reorder => 'Reorder';
  @override
  String customerOrdersTitle(String name) => '$name\'s orders';
  @override
  String get noOrdersCurrently => 'No orders at the moment';
  @override
  String get noOrdersYetDescription => 'You haven\'t placed any orders yet';
  @override
  String get latestOrder => 'Latest order';
  @override
  String get track => 'Track';
  @override
  String get orderStatistics => 'Order statistics';
  @override
  String get searchOrdersHint => 'Search orders...';
  @override
  String noOrdersForStatus(String status) => 'No $status orders';
  @override
  String ordersForStatusAppearHere(String status) =>
      '$status orders will appear here';
  @override
  String get revenue => 'Revenue';
  @override
  String get errorLoadingOrders => 'An error occurred while loading orders';
  @override
  String get featureComingSoon => 'This feature is coming soon';
  @override
  String get processingStatus => 'Processing';
  @override
  String get shippingStatus => 'Shipping';
  @override
  String get deliveredStatus => 'Delivered';
  @override
  String get accept => 'Accept';
  @override
  String get reject => 'Reject';
  @override
  String get startProcessing => 'Start processing';
  @override
  String get complete => 'Complete';
  @override
  String get orderAcceptedSuccess => 'Order accepted';
  @override
  String get orderAcceptedFailed => 'Failed to accept the order';
  @override
  String get rejectOrderTitle => 'Reject order';
  @override
  String get rejectOrderPrompt => 'Please enter the rejection reason:';
  @override
  String get orderRejectedSuccess => 'Order rejected';
  @override
  String get orderRejectedFailed => 'Failed to reject the order';
  @override
  String get orderStartedSuccess => 'Order processing started';
  @override
  String get orderStartedFailed => 'Failed to start order processing';
  @override
  String get orderCompletedFailed => 'Failed to complete the order';

  // ═══════════════════════════════════════════════════════════════════════════
  // Profile & Account
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get account => 'Account';
  @override
  String get myAccount => 'My Account';
  @override
  String get manageYourDataAndOrders => 'Manage your data and orders';
  @override
  String get personalInfo => 'Personal Info';
  @override
  String get editProfile => 'Edit Profile';
  @override
  String get editNameAndPhone => 'Edit name and phone';
  @override
  String get profilePhotoUpdated => 'Profile photo updated';
  @override
  String get failedToUploadPhoto => 'Failed to upload photo';
  @override
  String get changeProfilePhoto => 'Change Profile Photo';
  @override
  String get chooseFromGallery => 'Choose from Gallery';
  @override
  String get takePhoto => 'Take Photo';
  @override
  String get useCamera => 'Use Camera';

  // ═══════════════════════════════════════════════════════════════════════════
  // Statistics
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myStatistics => 'My Statistics';
  @override
  String get totalOrders => 'Total Orders';
  @override
  String get allOrdersMade => 'All orders you\'ve made';
  @override
  String get activeOrders => 'Active Orders';
  @override
  String get currentlyTracking => 'Currently tracking';
  @override
  String get completedOrders => 'Completed Orders';
  @override
  String get successfullyDelivered => 'Successfully delivered';
  @override
  String get cancelledRejected => 'Cancelled/Rejected';
  @override
  String get cancelledOrRejected => 'Cancelled or rejected';

  // ═══════════════════════════════════════════════════════════════════════════
  // Settings
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get settings => 'Settings';
    @override
    String get appearance => 'Appearance';
    @override
    String get themeSystem => 'System';
    @override
    String get themeSystemSubtitle => 'Follow device settings';
    @override
    String get themeLight => 'Light';
    @override
    String get themeLightSubtitle => 'Always use light mode';
    @override
    String get themeDark => 'Dark';
    @override
    String get themeDarkSubtitle => 'Always use dark mode';
  @override
  String get personalSettings => 'Personal Settings';
  @override
  String get notifications => 'Notifications';
  @override
  String get orderStatusAlerts => 'Order status alerts';
  @override
  String get orderStatusAndOffersAlerts => 'Order status and offers alerts';
  @override
  String get offersAndDiscounts => 'Offers & Discounts';
  @override
  String get receiveExclusiveOffers => 'Receive exclusive offers';
  @override
  String get language => 'Language';
  @override
  String get accountManagement => 'Account Management';
  @override
  String get viewAndTrackOrders => 'View and track orders';
  @override
  String get paymentMethods => 'Payment Methods';
  @override
  String get manageCardsAndPayment => 'Manage cards and payment';
  @override
  String get noSavedPaymentMethods => 'No saved payment methods';
  @override
  String get addPaymentMethodLater =>
      'Add a card or payment method during your next checkout';
  @override
  String get addPaymentMethod => 'Add payment method';
  @override
  String get privacyAndSecurity => 'Privacy & Security';
  @override
  String get securityAndPrivacySettings => 'Security and privacy settings';
  @override
  String get changePassword => 'Change password';
  @override
  String get updatePasswordRegularly => 'Update your password regularly';
  @override
  String get dataWeCollect => 'Data we collect';
  @override
  String get howWeUseYourData => 'How we use your data';
  @override
  String get privacyPolicy => 'Privacy policy';
  @override
  String get readFullPrivacyPolicy => 'Read the full privacy policy';
  @override
  String get helpAndSupport => 'Help & Support';
  @override
  String get helpCenter => 'Help Center';
  @override
  String get faqAndSupport => 'FAQ and support';
  @override
  String get faqTitle => 'FAQs';
  @override
  String get faqSubtitle => 'Answers to the most common questions';
  @override
  String get contactUs => 'Contact us';
  @override
  String get supportAndInquiries => 'Technical support and inquiries';
  @override
  String get phone => 'Phone';
  @override
  String get supportAvailableAnytime => 'We are happy to help 24/7';
  @override
  String get aboutApp => 'About App';
  @override
  String get appVersionAndInfo => 'App version and info';
  @override
  String get appVersionLabel => 'Version';
  @override
  String appVersion(String version) => 'Version $version';
  @override
  String get aboutAppDescription =>
      'Hindam connects you with the best men\'s tailoring shops in the Sultanate. '
      'Order your dishdashas, abayas, and custom tailoring with easy order tracking and delivery.';
  @override
  String get website => 'Website';
  @override
  String get infoAndAccount => 'Info & Account';
  @override
  String get notificationsAndOffers => 'Notifications & Offers';
  @override
  String get appLanguage => 'App Language';

  // ═══════════════════════════════════════════════════════════════════════════
  // Language
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get chooseLanguage => 'Choose Language';
  @override
  String get automatic => 'Automatic';
  @override
  String get useDeviceLanguage => 'Use device language';
  @override
  String get languageChangedToDevice => 'Language changed to device language';
  @override
  String get arabic => 'العربية';
  @override
  String get english => 'English';
  @override
  String get languageChangedToArabic => 'تم تغيير اللغة إلى العربية';
  @override
  String get languageChangedToEnglish => 'Language changed to English';

  // ═══════════════════════════════════════════════════════════════════════════
  // Measurements
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get enterMeasurements => 'Enter measurements';
  @override
  String get saveExperimental => 'Save (experimental)';

  // ═══════════════════════════════════════════════════════════════════════════
  // Home Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get categories => 'Categories';
  @override
  String get menTailor => 'Men\'s Tailor';
  @override
  String get abayas => 'Abayas';
  @override
  String get merchants => 'Merchants';
  @override
  String get nearbyTailors => 'Nearby Tailors';
  @override
  String get viewAll => 'View All';
  @override
  String get searchTailorOrService => 'Search for tailor or service...';
  @override
  String get discount40 => '40% Off';
  @override
  String get onAllMensTailoring => 'On all men\'s tailoring services';
  @override
  String get limitedOffer => 'Limited Offer';
  @override
  String get freeDelivery => 'Free Delivery';
  @override
  String get forOrdersAbove50 => 'For orders above 50 OMR';
  @override
  String get newLabel => 'New';
  @override
  String get eidThobe => 'Eid Thobe';
  @override
  String get exclusiveCollection => 'Exclusive collection with finest fabrics';
  @override
  String get exclusive => 'Exclusive';
  @override
  String get menTailoring => 'Men\'s Tailoring';
  @override
  String get exclusiveOffer => 'Exclusive Offer';
  @override
  String get saveUpTo => 'Save up to';
  @override
  String get discoverNow => 'Discover Now';
  @override
  String get noTailorShopsRegistered => 'No tailor shops registered';
  @override
  String get unableToLoadTailorShops => 'Unable to load tailor shops';
  @override
  String get onThobeTailoring => 'on thobe tailoring';
  @override
  String get discoverNewShopsOrTry =>
      'Discover new shops or try tailors you haven\'t ordered from in a while';
  @override
  String get riyal3 => '3 OMR';
  @override
  String get rating4Plus => '4.0+ Rating';
  @override
  String get refreshing => 'Refreshing...';
  @override
  String shopsListUpdatedSuccess(int count) =>
      'Shops list updated successfully ($count shops)';
  @override
  String get failedToRefreshList => 'Failed to refresh list';
  @override
  String get store => 'Store';
  @override
  String get refreshList => 'Refresh List';
  @override
  String get yesCancel => 'Yes, Cancel';
  @override
  String get continueToRecipientInfo => 'Continue to recipient info';
  @override
  String get sendingOrder => 'Sending...';
  @override
  String get sendGiftRequest => 'Send gift request';
  @override
  String get addNewFabricSoon => 'Add new fabric feature coming soon';
  @override
  String get editFabricSoon => 'Edit fabric feature coming soon';
  @override
  String get openNowFilter => 'Open Now';
  @override
  String get deliveryFilter => 'Delivery';
  @override
  String get priceUp => 'Price ↑';
  @override
  String get priceDown => 'Price ↓';
  @override
  String get productAddedToCart => 'Product added to cart';
  @override
  String get confirmCancelOrder =>
      'Are you sure you want to cancel this order?';
  @override
  String get chooseFabricType => 'Choose Fabric Type';
  @override
  String get browseAvailableFabrics => 'Browse available fabrics';

  // ═══════════════════════════════════════════════════════════════════════════
  // Features
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get fastDelivery => 'Fast Delivery';
  @override
  String get toAllOman => 'To all of Oman';
  @override
  String get guaranteedQuality => 'Guaranteed Quality';
  @override
  String get originalProducts100 => '100% Original Products';
  @override
  String get continuousSupport => 'Continuous Support';
  @override
  String get customerService247 => '24/7 Customer Service';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Details
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get tailorDetails => 'Tailor Details';
  @override
  String get services => 'Services';
  @override
  String get fabrics => 'Fabrics';
  @override
  String get reviews => 'Reviews';
  @override
  String get open => 'Open';
  @override
  String get closed => 'Closed';
  @override
  String get openNow => 'Open Now';
  @override
  String get closedNow => 'Closed Now';
  @override
  String get km => 'km';
  @override
  String get fastDeliveryTag => 'Fast Delivery';
  @override
  String get menDishdasha => 'Men\'s Dishdasha';
  @override
  String get omaniEmbroidery => 'Omani Embroidery';
  @override
  String get homeMeasurement => 'Home Measurement';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get tailoringDesign => 'Tailoring Design';
  @override
  String get chooseFabric => 'Choose Fabric';
  @override
  String get chooseDesign => 'Choose Design';
  @override
  String get reviewOrder => 'Review Order';
  @override
  String get measurements => 'Measurements';
  @override
  String get length => 'Length';
  @override
  String get shoulder => 'Shoulder';
  @override
  String get neck => 'Neck';
  @override
  String get armLength => 'Arm Length';
  @override
  String get wristWidth => 'Wrist Width';
  @override
  String get chestWidth => 'Chest Width';
  @override
  String get bottomWidth => 'Bottom Width';
  @override
  String get embroideryLength => 'Embroidery Length';
  @override
  String get embroideryDesign => 'Embroidery Type';
  @override
  String get selectEmbroidery => 'Select Embroidery';
  @override
  String get noEmbroidery => 'No Embroidery';
  @override
  String get continueButton => 'Continue';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
  @override
  String get estimatedCost => 'Estimated Cost';
  @override
  String get submitOrder => 'Submit Order';

  // ═══════════════════════════════════════════════════════════════════════════
  // Cart
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get shoppingCart => 'Shopping Cart';
  @override
  String get cartEmpty => 'Cart is Empty';
  @override
  String get cartEmptyMessage => 'You haven\'t added any products yet';
  @override
  String get startShopping => 'Start Shopping';
  @override
  String get total => 'Total';
  @override
  String get subtotal => 'Subtotal';
  @override
  String get deliveryFee => 'Delivery Fee';
  @override
  String get checkout => 'Checkout';
  @override
  String get removeFromCart => 'Remove from Cart';
  @override
  String get quantity => 'Quantity';
  @override
  String get updateCart => 'Update Cart';

  // ═══════════════════════════════════════════════════════════════════════════
  // Common Actions
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get done => 'Done';
  @override
  String get ok => 'OK';
  @override
  String get close => 'Close';
  @override
  String get retry => 'Retry';
  @override
  String get loading => 'Loading...';
  @override
  String get search => 'Search';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Sort';
  @override
  String get apply => 'Apply';
  @override
  String get reset => 'Reset';
  @override
  String get clear => 'Clear';
  @override
  String get refresh => 'Refresh';
  @override
  String get seeMore => 'See More';
  @override
  String get seeLess => 'See Less';
  @override
  String get select => 'Select';
  @override
  String get selected => 'Selected';
  @override
  String get details => 'Details';
  @override
  String get bookAppointment => 'Book Appointment';
  @override
  String get add => 'Add';
  @override
  String get remove => 'Remove';
  @override
  String get update => 'Update';
  @override
  String get submit => 'Submit';
  @override
  String get send => 'Send';
  @override
  String get share => 'Share';
  @override
  String get copy => 'Copy';
  @override
  String get copied => 'Copied';

  // ═══════════════════════════════════════════════════════════════════════════
  // Errors & Messages
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get warning => 'Warning';
  @override
  String get info => 'Info';
  @override
  String get noData => 'No data available';
  @override
  String get noResults => 'No results found';
  @override
  String get somethingWentWrong => 'Something went wrong';
  @override
  String get tryAgain => 'Try again';
  @override
  String get connectionError => 'Connection error';
  @override
  String get noInternet => 'No internet connection';
  @override
  String get serverError => 'Server error';
  @override
  String get sessionExpired => 'Session expired';
  @override
  String get invalidInput => 'Invalid input';
  @override
  String get requiredField => 'This field is required';
  @override
  String get invalidEmail => 'Invalid email address';
  @override
  String get invalidPhone => 'Invalid phone number';
  @override
  String get passwordTooShort => 'Password is too short';
  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  // ═══════════════════════════════════════════════════════════════════════════
  // Time
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String minutesAgo(int n) {
    if (n == 1) return '1 minute ago';
    return '$n minutes ago';
  }

  @override
  String hoursAgo(int n) {
    if (n == 1) return '1 hour ago';
    return '$n hours ago';
  }

  @override
  String get yesterday => 'Yesterday';
  @override
  String daysAgo(int n) {
    if (n == 1) return '1 day ago';
    return '$n days ago';
  }

  @override
  String get justNow => 'Just now';
  @override
  String get today => 'Today';
  @override
  String get tomorrow => 'Tomorrow';

  // ═══════════════════════════════════════════════════════════════════════════
  // Currency
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String currency(String value) => '$value OMR';
  @override
  String get omr => 'OMR';

  // ═══════════════════════════════════════════════════════════════════════════
  // Validation
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get pleaseEnterValue => 'Please enter a value';
  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';
  @override
  String get pleaseEnterValidPhone => 'Please enter a valid phone number';
  @override
  String get pleaseEnterValidPassword => 'Please enter a valid password';
  @override
  String get pleaseEnterName => 'Please enter your name';
  @override
  String get enterValidMeasurement => 'Enter a valid measurement';

  // ═══════════════════════════════════════════════════════════════════════════
  // Confirmation Dialogs
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get confirmLogout => 'Confirm Logout';
  @override
  String get confirmDelete => 'Confirm Delete';
  @override
  String get confirmCancel => 'Confirm Cancel';
  @override
  String get areYouSure => 'Are you sure?';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';

  // ═══════════════════════════════════════════════════════════════════════════
  // Empty States
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get emptyCart => 'Your cart is empty';
  @override
  String get emptyOrders => 'No orders yet';
  @override
  String get emptyFavorites => 'No favorites yet';
  @override
  String get emptyAddresses => 'No saved addresses';
  @override
  String get noTailorsNearby => 'No tailors nearby';
  @override
  String get noServicesAvailable => 'No services available';
  @override
  String get noFabricsAvailable => 'No fabrics available';

  // ═══════════════════════════════════════════════════════════════════════════
  // Login Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get welcomeBackTitle => 'Welcome Back!';
  @override
  String get loginToAccessAccount => 'Log in to access your account';
  @override
  String get enterYourEmail => 'Enter your email';
  @override
  String get enterYourPassword => 'Enter your password';
  @override
  String get loginSuccessful => 'Login successful!';
  @override
  String get loginFailed => 'Login failed';

  // ═══════════════════════════════════════════════════════════════════════════
  // Signup Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get joinHindam => 'Join Hindam!';
  @override
  String get createAccountAndEnjoy =>
      'Create your account and enjoy a unique shopping experience';
  @override
  String get fullName => 'Full Name';
  @override
  String get enterFullName => 'Enter your full name';
  @override
  String get phoneOptional => 'Phone Number (Optional)';
  @override
  String get reEnterPassword => 'Re-enter password';
  @override
  String get accountCreatedSuccessfully => 'Account created successfully!';
  @override
  String get accountCreationFailed => 'Account creation failed';
  @override
  String get pleaseEnterFullName => 'Please enter your full name';
  @override
  String get passwordMinLength => 'Password must be at least 6 characters';
  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  // ═══════════════════════════════════════════════════════════════════════════
  // Cart Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get clearAll => 'Clear All';
  @override
  String get addProductsToStart => 'Add some products to start shopping';
  @override
  String get completeOrder => 'Complete Order';
  @override
  String get clearCart => 'Clear Cart';
  @override
  String get clearCartConfirmation =>
      'Are you sure you want to clear all items from the cart?';
  @override
  String get cartCleared => 'Cart cleared';
  @override
  String get orderTotalAmount => 'Order Total';
  @override
  String get confirmOrder => 'Confirm Order';
  @override
  String get orderSentSuccessfully => 'Order sent successfully';
  @override
  String get color => 'Color';
  @override
  String get notes => 'Notes';

  // ═══════════════════════════════════════════════════════════════════════════
  // Forgot Password Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get resetPassword => 'Reset Password';
  @override
  String get enterEmailToReset => 'Enter your email to reset your password';
  @override
  String get sendResetLink => 'Send Reset Link';
  @override
  String get resetLinkSent => 'Reset link sent to your email';
  @override
  String get resetLinkFailed => 'Failed to send reset link';

  // ═══════════════════════════════════════════════════════════════════════════
  // Edit Profile Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get saveChanges => 'Save Changes';
  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';
  @override
  String get profileUpdateFailed => 'Failed to update profile';

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get addNewAddress => 'Add New Address';
  @override
  String get addressName => 'Address Name';
  @override
  String get fullAddress => 'Full Address';
  @override
  String get addressAddedSuccessfully => 'Address added successfully';
  @override
  String get addressDeletedSuccessfully => 'Address deleted successfully';
  @override
  String get confirmDeleteAddress =>
      'Are you sure you want to delete this address?';
  @override
  String get addressSavedSuccessfully => 'Address saved successfully';

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get addToCart => 'Add to Cart';
  @override
  String get itemRemovedFromFavorites => 'Item removed from favorites';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Status Labels
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get pending => 'Pending';
  @override
  String get accepted => 'Accepted';
  @override
  String get inProgress => 'In Progress';
  @override
  String get completed => 'Completed';
  @override
  String get rejected => 'Rejected';
  @override
  String get cancelled => 'Cancelled';
  @override
  String get orderRejectionReason => 'Rejection Reason';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Details
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get fabricDetails => 'Fabric Details';
  @override
  String get fabricName => 'Fabric Name';
  @override
  String get fabricType => 'Fabric Type';
  @override
  String get fabricColor => 'Fabric Color';
  @override
  String get totalPrice => 'Total Price';
  @override
  String get tailorInfo => 'Tailor Information';
  @override
  String get shopName => 'Shop Name';
  @override
  String get customerName => 'Customer Name';
  @override
  String get additionalNotes => 'Additional Notes';
  @override
  String get rejectionReason => 'Rejection Reason';
  @override
  String get lastUpdate => 'Last Update';
  @override
  String get orderNotFound => 'Order not found';

  // ═══════════════════════════════════════════════════════════════════════════
  // Measurements
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get shoulderWidth => 'Shoulder Width';
  @override
  String get chestCircumference => 'Chest Circumference';
  @override
  String get waistCircumference => 'Waist Circumference';
  @override
  String get hipCircumference => 'Hip Circumference';
  @override
  String get sleeveLength => 'Sleeve Length';
  @override
  String get neckCircumference => 'Neck Circumference';
  @override
  String get armLength2 => 'Arm Length';
  @override
  String get cm => 'cm';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get eleganceTailor => 'Elegance Tailor';
  @override
  String get eliteCenter => 'Elite Center';
  @override
  String get fashionTouch => 'Fashion Touch';
  @override
  String get softTailoring => 'Soft Tailoring';

  // ═══════════════════════════════════════════════════════════════════════════
  // Product & Service Actions
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get addedToCart => 'Added to cart';
  @override
  String get orderNow => 'Order Now';
  @override
  String get buyNow => 'Buy Now';
  @override
  String get sortBy => 'Sort By';
  @override
  String get priceHighToLow => 'Price: High to Low';
  @override
  String get priceLowToHigh => 'Price: Low to High';
  @override
  String get newest => 'Newest';
  @override
  String get rating => 'Rating';

  // ═══════════════════════════════════════════════════════════════════════════
  // Permission Dialogs
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cameraPermissionRequired => 'Camera permission required';
  @override
  String get cameraAccessNeeded => 'We need camera access to take a photo for your profile.';
  @override
  String get galleryPermissionRequired => 'Gallery access permission required';
  @override
  String get galleryAccessNeeded => 'We need gallery access to select a photo for your profile.';
  @override
  String get permissionDenied => 'Permission denied';
  @override
  String get openSettings => 'Open Settings';

  // ═══════════════════════════════════════════════════════════════════════════
  // Error Page
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get pageNotFound => 'Page not found';
  @override
  String get goToHome => 'Go to Home';

  // ═══════════════════════════════════════════════════════════════════════════
  // Cancel Order
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cancelOrderConfirmation =>
      'Are you sure you want to cancel this order?';
  @override
  String get yesCancelOrder => 'Yes, Cancel Order';
  @override
  String get orderCancelledSuccessfully => 'Order cancelled successfully';
  @override
  String get orderCancellationFailed => 'Failed to cancel order';
  @override
  String get cancelledByCustomer => 'Cancelled by customer';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get selectFabricFirst => 'Please select a fabric first';
  @override
  String get selectDesignFirst => 'Please select a design first';
  @override
  String get enterMeasurementsFirst => 'Please enter measurements first';
  @override
  String get fabricPrice => 'Fabric Price';
  @override
  String get tailoringCost => 'Tailoring Cost';
  @override
  String get embroideryCost => 'Embroidery Cost';
  @override
  String get orderReview => 'Order Review';
  @override
  String get selectedFabric => 'Selected Fabric';
  @override
  String get selectedDesign => 'Selected Design';
  @override
  String get embroideryType => 'Embroidery Type';

  // ═══════════════════════════════════════════════════════════════════════════
  // Forgot Password Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get emailSent => 'Email Sent!';
  @override
  String get resetLinkSentDescription =>
      'A password reset link has been sent to your email. Please check your inbox.';
  @override
  String get enterEmailForReset =>
      'Enter your email and we will send you a link to reset your password';
  @override
  String get sendResetLinkButton => 'Send Reset Link';
  @override
  String get backToLogin => 'Back to Login';
  @override
  String get resend => 'Resend';
  @override
  String get emailSendFailed => 'Failed to send email';

  // ═══════════════════════════════════════════════════════════════════════════
  // Edit Profile Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get noUserLoggedIn => 'No user logged in';
  @override
  String get emailCannotBeChanged => 'Email cannot be changed';
  @override
  String get errorOccurred => 'An error occurred';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Details Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get muscat => 'Muscat';
  @override
  String get type => 'Type';
  @override
  String get lines => 'Lines';
  @override
  String get fastDeliveryLabel => 'Fast Delivery';
  @override
  String get menDishdashaTailoring => "Men's Dishdasha";
  @override
  String get serviceFee => 'Service Fee';
  @override
  String get time => 'Time';
  @override
  String get minutes => 'minutes';
  @override
  String get availableServices => 'Available Services';
  @override
  String get loginRequired => 'Login Required';
  @override
  String get loginToOrderService =>
      'To order the service, please log in first.\nYou can create a new account in seconds.';
  @override
  String get orderNowButton => 'Order Now';
  @override
  String get duration => 'Duration';
  @override
  String get menDishdashaTailoringService => "Men's Dishdasha Tailoring";
  @override
  String get shorteningAlteration => 'Shortening/Simple Alteration';
  @override
  String get wideningNarrowing => 'Widening/Narrowing';
  @override
  String get days => 'days';
  @override
  String get sameDay => 'Same Day';
  @override
  String get oneDay => 'One Day';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get cmLabel => 'cm';
  @override
  String get inchLabel => 'inch';
  @override
  String get pleaseSelectFabricType => 'Please select fabric type';
  @override
  String get pleaseEnterMeasurementsCorrectly =>
      'Please enter measurements correctly';
  @override
  String get pleaseSelectFabric => 'Please select fabric';
  @override
  String get pleaseLoginToOrder => 'Please log in';
  @override
  String get orderSubmissionError => 'Error submitting order';
  @override
  String get fabricStep => 'Fabric';
  @override
  String get measurementsAndColor => 'Measurements & Color';
  @override
  String get embroideryStep => 'Embroidery';
  @override
  String get viewOrder => 'View Order';
  @override
  String get continueText => 'Continue';
  @override
  String get selectFabricType => 'Select Fabric Type';
  @override
  String get browseFabricsAvailable => 'Browse available fabrics';
  @override
  String get noFabricsAvailableNow => 'No fabrics available';
  @override
  String get fabric => 'Fabric';
  @override
  String get change => 'Change';
  @override
  String get measurementUnit => 'Measurement Unit';
  @override
  String get additionalNotesLabel => 'Additional Notes';
  @override
  String get enterAdditionalDetails => 'Enter any additional details...';
  @override
  String get embroideryThreadColor => 'Embroidery Thread Color';
  @override
  String get decorativeLines => 'Decorative Lines';
  @override
  String get noDesignsAvailable => 'No designs available';
  @override
  String get embroideryDesigns => 'Embroidery Designs';
  @override
  String get selectEmbroideryDesign => 'Select Embroidery Design';
  @override
  String get none => 'None';
  @override
  String get orderSentSuccess => 'Order sent successfully';
  @override
  String get orderNumberLabel => 'Order Number';
  @override
  String get tailorLabel => 'Tailor';
  @override
  String get totalLabel => 'Total';
  @override
  String get willContactYouSoon => 'We will contact you soon';
  @override
  String get okButton => 'OK';
  @override
  String get reviewOrderTitle => 'Review Order';
  @override
  String get nameLabel => 'Name';
  @override
  String get cityLabel => 'City';
  @override
  String get fabricTypeLabel => 'Type';
  @override
  String get designLabel => 'Design';
  @override
  String get threadColorLabel => 'Thread Color';
  @override
  String get linesLabel => 'Lines';
  @override
  String get measurementsLabel => 'Measurements';
  @override
  String get lengthLabel => 'Length';
  @override
  String get shoulderLabel => 'Shoulder';
  @override
  String get neckLabel => 'Neck';
  @override
  String get armLengthLabel => 'Arm Length';
  @override
  String get wristWidthLabel => 'Wrist Width';
  @override
  String get chestWidthWithSides => 'Chest Width with Sides';
  @override
  String get patternLength => 'Pattern Length';
  @override
  String get backButton => 'Back';
  @override
  String get confirmSubmit => 'Confirm Submit';
  @override
  String get selectionMade => 'Selected';
  @override
  String get chestLabel => 'Chest';
  @override
  String get waistLabel => 'Waist';
  @override
  String get armLabel => 'Arm';
  @override
  String get perLinePrice => '+0.250 OMR per line';

  // ═══════════════════════════════════════════════════════════════════════════
  // Color Names
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get colorNavy => 'Navy';
  @override
  String get colorBlue => 'Blue';
  @override
  String get colorGray => 'Gray';
  @override
  String get colorGreen => 'Green';
  @override
  String get colorGold => 'Gold';
  @override
  String get colorBrown => 'Brown';
  @override
  String get colorPurple => 'Purple';
  @override
  String get colorBlack => 'Black';
  @override
  String get colorSilver => 'Silver';
  @override
  String get colorWhite => 'White';
  @override
  String get colorTeal => 'Teal';
  @override
  String get colorBurgundy => 'Burgundy';
  @override
  String get customColor => 'Custom Color';

  // ═══════════════════════════════════════════════════════════════════════════
  // Gift Design Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get giftLabel => 'Gift';
  @override
  String get giftRecipientData => 'Recipient Data';
  @override
  String get selectFabricForGift => 'Select fabric type for gift';
  @override
  String get enterGiftRecipientMeasurements =>
      'Enter gift recipient measurements';
  @override
  String get canAskRecipientForMeasurements =>
      'You can ask the recipient for measurements or estimate them';
  @override
  String get required => 'Required';
  @override
  String get enterValidNumber => 'Enter a valid number';
  @override
  String get selectThreadColorAndCount =>
      'Please select thread color and count to continue';
  @override
  String get threadColor => 'Thread Color';
  @override
  String get noColorsAvailable => 'No colors available';
  @override
  String get threadCount => 'Thread Count';
  @override
  String get thread => 'thread';
  @override
  String get threadsLimit => 'Limit';
  @override
  String get failedToLoadDesigns => 'Failed to load designs';
  @override
  String get retryButton => 'Retry';
  @override
  String get giftRecipientInfo => 'Gift Recipient Info';
  @override
  String get enterGiftRecipientDetails =>
      'Enter the information of the person receiving the gift';
  @override
  String get recipientName => 'Recipient Name';
  @override
  String get enterRecipientName => 'Enter recipient name';
  @override
  String get recipientNameRequired => 'Recipient name is required';
  @override
  String get recipientPhoneOptional => 'Recipient Phone (Optional)';
  @override
  String get forDeliveryCoordination => 'For delivery coordination';
  @override
  String get giftMessageOptional => 'Gift Message (Optional)';
  @override
  String get writeShortMessageToRecipient =>
      'Write a short message to the recipient...';
  @override
  String get deliveryNotesOptional => 'Delivery Notes (Optional)';
  @override
  String get deliveryNotesExample =>
      'Example: Delivery on a specific date, special packaging...';
  @override
  String get totalAmount => 'Total';
  @override
  String get sending => 'Sending...';
  @override
  String get sendGiftOrder => 'Send Gift Order';
  @override
  String get clickToSelect => 'Click to select';
  @override
  String get totalPriceLabel => 'Total Price';
  @override
  String get continueToRecipientData => 'Continue to Recipient Data';
  @override
  String get pleaseSelectFabricTypeFirst => 'Please select fabric type first';
  @override
  String get pleaseSelectThreadColor => 'Please select thread color';
  @override
  String get pleaseSpecifyThreadCount => 'Please specify thread count';
  @override
  String get giftOrderSentSuccess => 'Gift order sent successfully!';
  @override
  String get threadDetails => 'Thread Details';
  @override
  String get specifyEmbroideryAndColors => 'Select embroidery type and thread colors';
  @override
  String get threads => 'threads';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Store Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get tailoringServices => 'Services';
  @override
  String get giftSection => 'Gift';
  @override
  String get menDishdashaTailoringTitle => "Men's Dishdasha Tailoring";
  @override
  String get childrenDishdashaTailoring => "Children's Dishdasha Tailoring";
  @override
  String get premiumSummerFabric => 'Premium Summer Fabric';
  @override
  String get japaneseCottonFabric => 'Japanese Cotton Fabric';
  @override
  String get searchInSection => 'Search in';
  @override
  String get priceLabel => 'Price';
  @override
  String get quantityLabel => 'Quantity';
  @override
  String get addedToCartMessage => 'Added to cart';
  @override
  String get addToCartButton => 'Add to Cart';
  @override
  String get viewAllButton => 'View All';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Fabric Admin Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get manageFabricsFor => 'Manage Fabrics for';
  @override
  String get searchInFabrics => 'Search in fabrics...';
  @override
  String get addFabric => 'Add Fabric';
  @override
  String get fabricStatistics => 'Fabric Statistics';
  @override
  String get totalFabrics => 'Total Fabrics';
  @override
  String get tailorFabrics => "This Tailor's Fabrics";
  @override
  String get errorLoadingFabrics => 'Error loading fabrics';
  @override
  String get noFabricsForTailor => 'No fabrics for this tailor';
  @override
  String get addFirstFabric => 'Add First Fabric';
  @override
  String get searchError => 'Search error';
  @override
  String get noSearchResults => 'No search results';
  @override
  String get typeNotSpecified => 'Not specified';
  @override
  String get perMeter => '/meter';
  @override
  String get addFabricComingSoon => 'Adding new fabric coming soon';
  @override
  String get editFabricComingSoon => 'Editing fabric coming soon';
  @override
  String get deleteFabric => 'Delete Fabric';
  @override
  String get confirmDeleteFabric => 'Are you sure you want to delete';
  @override
  String get fabricDeletedSuccess => 'Fabric deleted successfully';
  @override
  String get fabricDeleteFailed => 'Failed to delete fabric';

  // ═══════════════════════════════════════════════════════════════════════════
  // Favorites Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myFavoritesTitle => 'My Favorites';
  @override
  String get browseAndKeepFavorites => 'Browse and keep items you love';
  @override
  String get errorLoadingFavorites => 'Error loading favorites';
  @override
  String get noFavoritesCurrently => 'No favorites currently';
  @override
  String get startAddingFavorites => 'Start adding products to favorites';
  @override
  String get tailorType => 'Tailor';
  @override
  String get abayaType => 'Abaya';
  @override
  String get favoriteType => 'Favorite';
  @override
  String get ratingLabel => 'Rating';
  @override
  String get removeFromFavorites => 'Remove from favorites';
  @override
  String get item => 'Item';

  // ═══════════════════════════════════════════════════════════════════════════
  // Abayas Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get allFilter => 'All';
  @override
  String get abayasFilter => 'Abayas';
  @override
  String get fabricsFilter => 'Fabrics';
  @override
  String get setsFilter => 'Sets';
  @override
  String get accessoriesFilter => 'Accessories';
  @override
  String get abayasTitle => 'Abayas';
  @override
  String get modelTab => 'Model';
  @override
  String get productTab => 'Product';
  @override
  String get delivery => 'Delivery';
  @override
  String get abayaFallback => 'Abaya';
  @override
  String get lengthMeasure => 'Length';
  @override
  String get sleeveMeasure => 'Sleeve';
  @override
  String get widthMeasure => 'Width';
  @override
  String get productsAvailable => 'products available';
  @override
  String get productDetails => 'Product Details';
  @override
  String get results => 'results';
  @override
  String get measurementGuide => 'Measurement Guide';
  @override
  String get lengthTip =>
      'Length: Measure from the top of the shoulder to the desired abaya hem.';
  @override
  String get sleeveTip =>
      'Sleeve: From the neckline opening, across the shoulder to the end of the sleeve.';
  @override
  String get widthTip =>
      'Width: The horizontal distance between the sides at chest level.';
  @override
  String get basicMeasurements => 'Basic Measurements';
  @override
  String get allMeasurementsInInch => 'All measurements in inches';
  @override
  String get exampleLength => 'e.g. 54';
  @override
  String get exampleSleeve => 'e.g. 23';
  @override
  String get exampleWidth => 'e.g. 24';
  @override
  String get sleeveLengthLabel => 'Sleeve Length';
  @override
  String get noShopsAvailable => 'No shops available';
  @override
  String get abayaShopsTitle => 'Abaya Shops';
  @override
  String get searchForShop => 'Search for shop...';
  @override
  String get noDelivery => 'No delivery';
  @override
  String get deliveryAvailable => 'Delivery available';
  @override
  String servicesCount(int count) => '$count services';
  @override
  String get noProductsAvailable => 'No products available';
  @override
  String get tryCategoryOrSearch => 'Try changing the category or search';
  @override
  String addedItemToCart(String item) => 'Added $item to cart';
  @override
  String errorWithDetails(String error) => 'Error: $error';
  @override
  String get pleaseSignInFirst => 'Please sign in first';
  @override
  String get ratingFilterLabel => '4.0+ Rating';
  @override
  String get productNotFound => 'Product not found';
  @override
  String get errorLoadingProduct => 'Error loading product';
  @override
  String get selectColorFirst => 'Please select a color first';
  @override
  String get taxIncluded => 'Tax included';
  @override
  String get availableColors => 'Available colors';
  @override
  String get qualityGuaranteed => 'Guaranteed high quality';
  @override
  String get returnWithinDays => 'Return within 14 days';
  @override
  String get abayaLabel => 'Abaya';
  @override
  String get menSuppliesShops => 'Men\'s Supplies Shops';
  @override
  String get searchMenShop => 'Search for men\'s shop...';
  @override
  String get failedToLoadStores => 'Failed to load stores';
  @override
  String get noStoresAvailable => 'No stores available';
  @override
  String get tryChangingSearchCriteria => 'Try changing search criteria';
  @override
  String searchInShop(String shopName) => 'Search in $shopName...';
  @override
  String get sortLabel => 'Sort';
  @override
  String get failedToLoadProducts => 'Failed to load products';
  @override
  String get productLabel => 'Product';
  @override
  String get clothes => 'Clothes';
  @override
  String get shoes => 'Shoes';
  @override
  String get accessories => 'Accessories';
  @override
  String get sandals => 'Sandals';
  @override
  String get headwear => 'Headwear';
  @override
  String get abayaStore => 'Abaya Store';
  @override
  String measurementsInInch(String length, String sleeve, String width) =>
      'Measurements in inches: Length $length in, Sleeve $sleeve in, Width $width in';
  @override
  String get failedToSendOrder => 'Failed to send order. Please try again.';
  @override
  String get unexpectedError => 'An unexpected error occurred';
  @override
  String addedWithMeasurements(String item) =>
      'Added $item to cart with color and measurements';
  @override
  String get abayaMeasurements => 'Abaya Measurements';
  @override
  String get enterMeasurementsInInch => 'Enter measurements in inches';
  @override
  String get guideImageNotAvailable => 'Guide image not available';
  @override
  String get pleaseEnterValidValue => 'Please enter a valid value';
  @override
  String get valueTooLarge => 'Value is too large';
  @override
  String get optionalLabel => '(Optional)';
  @override
  String get measurementsHintExample =>
      'Example: I want it a bit looser from the sleeves...';
  @override
  String get confirmMeasurementsAddCart =>
      'Confirm measurements and add to cart';
  @override
  String get confirmMeasurementsProceed => 'Confirm measurements and proceed';

  // ═══════════════════════════════════════════════════════════════════════════
  // Addresses Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get myAddressesTitle => 'My Addresses';
  @override
  String get pleaseLoginToManageAddresses =>
      'Please log in to manage your addresses';
  @override
  String get addAndEditAddresses =>
      'Add and edit shipping and delivery addresses';
  @override
  String get errorFetchingAddresses => 'Error fetching addresses';
  @override
  String get noAddressesYetTitle => 'No addresses yet';
  @override
  String get addAddressForDelivery =>
      'Add your address to facilitate delivery and payment';
  @override
  String get deleteAddressTitle => 'Delete Address';
  @override
  String get confirmDeleteAddressMessage =>
      'Are you sure you want to delete this address?';
  @override
  String get addressDeleted => 'Address deleted';
  @override
  String get addressAddedSuccess => 'Address added successfully';
  @override
  String get addressUpdatedSuccess => 'Address updated successfully';
  @override
  String get addAddressButton => 'Add Address';
  @override
  String get defaultLabel => 'Default';
  @override
  String get editLabel => 'Edit';
  @override
  String get setAsDefaultLabel => 'Set as Default';
  @override
  String get deleteLabel => 'Delete';
  @override
  String get addNewAddressTitle => 'Add New Address';
  @override
  String get editAddressTitle => 'Edit Address';
  @override
  String get enterAccurateAddressData => 'Please enter accurate address data';
  @override
  String get addressLabelExample => 'Address Label (e.g., Home, Office)';
  @override
  String get recipientNameLabel => 'Recipient Name';
  @override
  String get phoneNumberLabel => 'Phone Number';
  @override
  String get enterPhoneNumber => 'Enter phone number';
  @override
  String get invalidPhoneNumber => 'Invalid number';
  @override
  String get cityProvinceLabel => 'City / Province';
  @override
  String get areaWilayaLabel => 'Area / Wilaya';
  @override
  String get streetApartmentLabel => 'Street / Apartment';
  @override
  String get buildingHouseNumberOptional =>
      'Building / House Number (Optional)';
  @override
  String get additionalDirectionsOptional => 'Additional Directions (Optional)';
  @override
  String get setAsDefaultAddress => 'Set as default address';
  @override
  String get saveAddress => 'Save Address';
  @override
  String get updateAddress => 'Update Address';
  @override
  String get thisFieldRequired => 'This field is required';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Tracking Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get orderReceivedWaiting => 'Order received and waiting for review';
  @override
  String get orderAcceptedPreparing => 'Order accepted and preparation started';
  @override
  String get orderInProgressProcessing =>
      'Order in progress and being processed';
  @override
  String get orderCompletedSuccess => 'Order completed successfully';
  @override
  String get waitingStatus => 'Waiting';
  @override
  String get acceptedStatus => 'Accepted';
  @override
  String get inProgressStatus => 'In Progress';
  @override
  String get completedStatus => 'Completed';

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional Order Tracking Keys
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get trackOrderTitle => 'Track Order';
  @override
  String get errorLoadingOrder => 'Error loading order data';
  @override
  String get cannotFindOrder => 'Cannot find the requested order';
  @override
  String get additionalInfo => 'Additional Information';
  @override
  String get completionDate => 'Completion Date';
  @override
  String get order => 'Order';
  @override
  String get orderRejected => 'Order Rejected';
  @override
  String get orderCancelled => 'Order Cancelled';
  @override
  String get tailor => 'Tailor';
  @override
  String get homeLabel => 'Home';

  // ═══════════════════════════════════════════════════════════════════════════
  // Order Success Dialog
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get orderSubmittedSuccessfully =>
      'Your order has been submitted successfully!';
  @override
  String get continueShopping => 'Continue Shopping';
  @override
  String get viewOrders => 'View Orders';
  @override
  String get guest => 'Guest';

  // ═══════════════════════════════════════════════════════════════════════════
  // Gift Feature - Send as Gift
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get sendAsGift => 'Send as Gift';
  @override
  String get thisOrderIsAGift => 'This order is a gift';
  @override
  String get recipientCity => 'City / Governorate';
  @override
  String get recipientAddress => 'Full Address';
  @override
  String get hidePriceFromRecipient => 'Hide price from recipient (surprise)';
  @override
  String get giftRecipientSummary => 'Gift Recipient';
  @override
  String get enterCityOrGovernorate => 'Enter city or governorate';
  @override
  String get enterFullAddress => 'Enter full address';
  @override
  String get cityRequired => 'City is required';
  @override
  String get addressRequired => 'Address is required';
  @override
  String get invalidPhoneFormat => 'Invalid phone format';
  @override
  String get editRecipient => 'Edit';
  @override
  String get saveRecipient => 'Save Recipient Info';
  @override
  String get giftOptionEnabled => 'Gift option enabled';
  @override
  String get giftInfoSaved => 'Recipient info saved';

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional Keys for Remaining Hardcoded Strings
  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor names/labels
  @override
  String get tailorElegance => 'Elegance Tailor';
  @override
  String get fineTailoring => 'Fine Tailoring';
  
  // Shop/Store related
  @override
  String get failedToUpdateList => 'Failed to update list';
  @override
  String get errorLoadingShops => 'Error loading shops';
  @override
  String get noRegisteredShops => 'No registered shops currently';
  @override
  String get threeOMR => '3 OMR';
  @override
  String get onTailoring => 'on tailoring';
  @override
  String get discoverNewTailors => 'Discover new tailors or try shops you haven\'t ordered from';
  @override
  String get currentlyClosed => 'Currently Closed';
  @override
  String get theStore => 'Store';
  @override
  String get callLabel => 'Call';
  @override
  String get mapLabel => 'Map';
  
  // Measurements form
  @override
  String get showTraditionalForm => 'Show Traditional Form';
  @override
  String get showBodyMap => 'Show Body Map';
  @override
  String get totalLength => 'Total Length';
  @override
  String get upperSleeve => 'Upper Sleeve';
  @override
  String get lowerSleeve => 'Lower Sleeve';
  @override
  String get chest => 'Chest';
  @override
  String get waist => 'Waist';
  @override
  String get frontEmbroidery => 'Front Embroidery';
  @override
  String get addNotesHint => 'Add any notes or special requirements...';
  @override
  String get measurementsSavedSuccess => 'Measurements saved successfully';
  @override
  String get errorSaving => 'Error saving';
  @override
  String get saveMeasurements => 'Save Measurements';
  @override
  String get tapPartToEnterMeasurement => 'Tap the part to enter measurement';
  @override
  String get inch => 'inch';
  @override
  String get measurementsForm => 'Measurements Form';
  @override
  String get enterAtLeastOneMeasurement => 'Please enter at least one measurement';
  @override
  String get bottomCircumference => 'Bottom Circumference';
  
  // Embroidery
  @override
  String get selectEmbroideryColor => 'Select Embroidery Color';
  @override
  String get embroideryLinesCount => 'Embroidery Lines Count';
  @override
  String get oneLine => 'One Line';
  @override
  String get twoLines => 'Two Lines';
  @override
  String get threeLines => 'Three Lines';
  @override
  String get errorLoadingEmbroideryDesigns => 'Error loading embroidery designs';
  @override
  String get noEmbroideryDesignsAvailable => 'No embroidery designs available';
  @override
  String get embroideryLabel => 'Embroidery';
  
  // Fabrics
  @override
  String get searchFabricHint => 'Search for fabric type or name';
  @override
  String get price => 'Price';
  @override
  String get kidsDishdashaService => 'Children\'s Dishdasha Tailoring';
  @override
  String get searchInside => 'Search inside';
  @override
  String get specialButtons => 'Special Buttons';
  @override
  String get readyCollars => 'Ready Collars';
  @override
  String get classicCottonFabric => 'Classic Cotton Fabric';
  @override
  String get manageFabrics => 'Manage Fabrics';
  @override
  String get colorsLabel => 'Colors';
  @override
  String get addColor => 'Add Color';
  @override
  String get noFabricsRegistered => 'No fabrics registered';
  @override
  String get pressAddToAddFabric => 'Press the add button to add a new fabric';
  @override
  String get errorLoadingColors => 'Error loading colors';
  @override
  String get colorLabel => 'Color';
  @override
  String get colorOliveGreen => 'Olive Green';
  
  // Abaya measurements
  @override
  String get notesExample => 'Example: I want it a bit wider, with internal pockets';
  @override
  String get confirmMeasurementsAndProceed => 'Confirm measurements and proceed';
  @override
  String get imageNotFound => 'Image not found';
  @override
  String get measurementGuideZoom => 'Measurement Guide — Zoom';
  @override
  String get enlargeImage => 'Enlarge Image';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailor Orders Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String tailorOrdersTitle(String name) => '$name\'s Orders';
  @override
  String get newOrders => 'New';
  @override
  String get acceptedTab => 'Accepted';
  @override
  String get inProgressTab => 'In Progress';
  @override
  String get completedTab => 'Completed';
  @override
  String get searchOrders => 'Search orders...';
  @override
  String get orderStatisticsTitle => 'Order Statistics';
  @override
  String get totalOrdersLabel => 'Total Orders';
  @override
  String get waitingLabel => 'Waiting';
  @override
  String get completedLabel => 'Completed';
  @override
  String get revenueLabel => 'Revenue';
  @override
  String get errorLoadingOrdersList => 'Error loading orders';
  @override
  String get retryLabel => 'Retry';
  @override
  String orderHashLabel(String id) => 'Order #$id';
  @override
  String get orderDateLabel => 'Order Date';
  @override
  String get noNewOrders => 'No new orders';
  @override
  String get noAcceptedOrders => 'No accepted orders';
  @override
  String get noInProgressOrders => 'No orders in progress';
  @override
  String get noCompletedOrders => 'No completed orders';
  @override
  String get noOrdersGeneric => 'No orders';
  @override
  String get newOrdersAppearHere => 'New orders will appear here';
  @override
  String get acceptedOrdersAppearHere => 'Accepted orders will appear here';
  @override
  String get inProgressOrdersAppearHere => 'Orders in progress will appear here';
  @override
  String get completedOrdersAppearHere => 'Completed orders will appear here';
  @override
  String get orderAccepted => 'Order accepted';
  @override
  String get orderAcceptFailed => 'Failed to accept order';
  @override
  String get rejectOrderDialogTitle => 'Reject Order';
  @override
  String get enterRejectionReason => 'Please enter the rejection reason:';
  @override
  String get rejectionReasonLabel => 'Rejection reason';
  @override
  String get orderRejectedSnack => 'Order rejected';
  @override
  String get orderRejectFailed => 'Failed to reject order';
  @override
  String get orderStarted => 'Order processing started';
  @override
  String get orderStartFailed => 'Failed to start processing';
  @override
  String get orderCompleted => 'Order completed';
  @override
  String get orderCompleteFailed => 'Failed to complete order';

  // ═══════════════════════════════════════════════════════════════════════════
  // Fabric Management Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get noColorsRegistered => 'No colors registered';
  @override
  String get pressAddToAddColor => 'Press the add button to add a new color';
  @override
  String get editLabel2 => 'Edit';
  @override
  String get deleteLabel2 => 'Delete';
  @override
  String get confirmDeleteTitle => 'Confirm Delete';
  @override
  String confirmDeleteFabricMessage(String name) => 'Are you sure you want to delete "$name"?';
  @override
  String get fabricDeletedSnack => 'Fabric deleted successfully';
  @override
  String get addNewFabric => 'Add New Fabric';
  @override
  String get tapToAddImage => 'Tap to add image';
  @override
  String get fabricNameLabel => 'Fabric Name';
  @override
  String get fabricDescriptionLabel => 'Fabric Description';
  @override
  String get fabricTypeFieldLabel => 'Fabric Type';
  @override
  String get seasonLabel => 'Season';
  @override
  String get pricePerMeterLabel => 'Price per meter (OMR)';
  @override
  String get pleaseEnterFabricName => 'Please enter fabric name';
  @override
  String get pleaseEnterFabricDescription => 'Please enter fabric description';
  @override
  String get pleaseEnterPrice => 'Please enter price';
  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';
  @override
  String get pleaseSelectImage => 'Please select a fabric image';
  @override
  String get fabricAddedSuccess => 'Fabric added successfully';
  @override
  String get fabricAddFailed => 'Failed to add fabric';
  @override
  String get addNewColor => 'Add New Color';
  @override
  String get selectFabricLabel => 'Select Fabric';
  @override
  String get colorNameLabel => 'Color Name';
  @override
  String get colorCodeLabel => 'Color Code (e.g. #FF5733)';
  @override
  String get colorCodeHint => '#FF5733';
  @override
  String get pleaseEnterColorName => 'Please enter color name';
  @override
  String get pleaseEnterColorCode => 'Please enter color code';
  @override
  String get invalidColorCode => 'Please enter a valid color code (e.g. #FF5733)';
  @override
  String get pleaseSelectFabricField => 'Please select a fabric';
  @override
  String get noFabricsAvailableLabel => 'No fabrics available';
  @override
  String get colorPreview => 'Color preview';
  @override
  String get colorAddedSuccess => 'Color added successfully';
  @override
  String get colorAddFailed => 'Failed to add color';
  @override
  String get cottonFabric => 'Cotton';
  @override
  String get silkFabric => 'Silk';
  @override
  String get woolFabric => 'Wool';
  @override
  String get linenFabric => 'Linen';
  @override
  String get polyesterFabric => 'Polyester';
  @override
  String get summerSeason => 'Summer';
  @override
  String get winterSeason => 'Winter';
  @override
  String get allSeasonLabel => 'All Seasons';

  // ═══════════════════════════════════════════════════════════════════════════
  // Profile Screens (Settings, Privacy, Payment, Help, About)
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get securityAndPrivacyData => 'Security settings and your personal data';
  @override
  String get updatePasswordPeriodically => 'Update your password periodically';
  @override
  String get noSavedPaymentMethodsLabel => 'No saved payment methods';
  @override
  String get addPaymentWhenOrdering => 'Add a card or payment method when completing your next order';
  @override
  String get addPaymentMethodButton => 'Add Payment Method';
  @override
  String get faqAnswers => 'Answers to the most common questions';
  @override
  String get supportAndInquiriesLabel => 'Technical support and inquiries';
  @override
  String get happyToHelp247 => 'Happy to help you around the clock';
  @override
  String get hendamLabel => 'Hindam';
  @override
  String get version100 => 'Version 1.0.0';
  @override
  String get hendamAppDescription => 'Hindam app connects you with the best men\'s tailoring shops in the Sultanate. Order your dishdashas, abayas, and tailoring with ease while tracking orders and delivery.';
  @override
  String get versionLabel => 'Version';
  @override
  String get emailLabel => 'Email';
  @override
  String get websiteLabel => 'Website';

  // ═══════════════════════════════════════════════════════════════════════════
  // Catalog / Services Screens
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get noItemsToShow => 'No items to show';
  @override
  String get addButton => 'Add';
  @override
  String get shareLabel => 'Share';
  @override
  String get productDetailsLabel => 'Product Details';
  @override
  String selectedServiceSnack(String name) => 'Selected: $name';
  @override
  String get menTailoringSection => 'Men\'s Tailoring';
  @override
  String get abayasSection => 'Abayas';
  @override
  String get smallMerchantSection => 'Small Merchant';
  @override
  String get allTab => 'All';
  @override
  String get menTab => 'Men';
  @override
  String get womenTab => 'Women';
  @override
  String get searchServiceHint => 'Search for a service (e.g. abaya, dishdasha, alteration)';
  @override
  String get allCategoriesChip => 'All Categories';
  @override
  String get noMatchingServices => 'No matching services found';

  // Tailoring Design Responsive - Additional Keys
  @override
  String get colorStep => 'Color';
  @override
  String get measurementsStep => 'Measurements';
  @override
  String get selectFabricColor => 'Select fabric color';
  @override
  String get sendOrderButton => 'Send Order';

  // ═══════════════════════════════════════════════════════════════════════════
  // Measurement Form Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get enterMeasurementsTitle => 'Enter Measurements';
  @override
  String get saveExperimentalButton => 'Save (Experimental)';

  // ═══════════════════════════════════════════════════════════════════════════
  // Tailoring Design Responsive Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get orderSentTitle => 'Order Sent';
  @override
  String get willContactSoon => 'We will contact you soon to confirm details';
  @override
  String get okLabel => 'OK';
  @override
  String get previousLabel => 'Previous';
  @override
  String get nameEmbroideryOnThobe => 'Name embroidery on thobe';
  @override
  String get embroideryOptions => 'Embroidery Options';
  @override
  String get addNameLabel => 'Add Name';
  @override
  String get invalidValue => 'Invalid value';
  @override
  String get colorRed => 'Red';
  @override
  String get additionalNotesOptional => 'Additional Notes (Optional)';
  @override
  String get confirmSubmission => 'Confirm Submission';
  @override
  String get noDesignSelected => 'None';

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional Shared Keys
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get errorOccurredWithDetails => 'An error occurred';
  @override
  String errorWithMessage(String error) => 'Error: $error';
  @override
  String get paymentMethodsTitle => 'Payment Methods';
  @override
  String get pricePerMeter => 'meter';

  // ═══════════════════════════════════════════════════════════════════════════
  // Abaya Services Screen
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get newBadge => 'New';
  @override
  String get modelViewLabel => 'Model';
  @override
  String get productViewLabel => 'Product';
  @override
  String get tryChangingCategoryOrSearch => 'Try changing the category or search';

  // ═══════════════════════════════════════════════════════════════════════════
  // Auth Error Messages (Firebase)
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get authErrorWeakPassword => 'Password is too weak';
  @override
  String get authErrorEmailInUse => 'Email is already in use';
  @override
  String get authErrorInvalidEmail => 'Invalid email address';
  @override
  String get authErrorUserDisabled => 'This account has been disabled';
  @override
  String get authErrorUserNotFound => 'No account found with this email';
  @override
  String get authErrorWrongPassword => 'Incorrect password';
  @override
  String get authErrorTooManyRequests => 'Too many login attempts, please try again later';
  @override
  String get authErrorOperationNotAllowed => 'This operation is not allowed';
  @override
  String get authErrorNetworkFailed => 'Network connection failed';
  @override
  String get authErrorUnexpected => 'An unexpected error occurred';
  @override
  String get authErrorAccountCreation => 'Account creation failed';
  @override
  String get authErrorSignIn => 'Sign in failed';
  @override
  String get authErrorNotSignedIn => 'Not signed in';
  @override
  String get newUserDefaultName => 'New User';

  // ═══════════════════════════════════════════════════════════════════════════
  // Core Widget Labels
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get searchHint => 'Search...';
  @override
  String get showMore => 'Show more';
  @override
  String get showLess => 'Show less';
  @override
  String get addImage => 'Add image';
  @override
  String get errorOccurredTitle => 'An error occurred';
  @override
  String colorsAvailableCount(int count) => '$count colors available';

  // ═══════════════════════════════════════════════════════════════════════════
  // General UI Labels
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  String get orLabel => 'or';
}
